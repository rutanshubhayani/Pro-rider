import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final String recipientId;
  final String recipientUserName;
  final String recipientUserImage;

  const ChatScreen({
    Key? key,
    required this.recipientId,
    required this.recipientUserName,
    required this.recipientUserImage,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late WebSocketChannel _channel;
  final TextEditingController _messageController = TextEditingController();
  List<String> _messages = [];
  String? _token;
  final ScrollController _scrollController = ScrollController();
  int consecutiveMessagesWithNumbers = 0;

  @override
  void initState() {
    super.initState();
    _getToken();
    _loadMessages();
  }

  Future<void> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('authToken');
      _connectWebSocket();
    });
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    // Load the stored messages for the current recipient (active chat partner)
    final storedMessages = prefs.getStringList('chatMessages_${widget.recipientId}') ?? [];
    setState(() {
      _messages = storedMessages;
    });
  }



  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('ws://202.21.32.153:8081'));
      if (_token != null) {
        print('WebSocket connected');
        _channel.sink.add(jsonEncode({'token': _token}));
      }

      _channel.stream.listen(
            (message) {
          print("Message received: $message"); // Log the message
          _handleIncomingMessage(message);
        },
        onError: (error) {
          _reconnectWebSocket();
          print("WebSocket error: $error"); // Log error
          // _showWarningDialog("Connection failed. Please check your network.");
        },
        onDone: () {
          print("WebSocket connection closed. Reconnecting...");
          _reconnectWebSocket(); // Reconnect if connection closes
        },
      );
    } catch (e) {
      print("WebSocket connection error: $e"); // Log connection error
      _showWarningDialog("Unable to establish WebSocket connection.");
    }
  }

  void _reconnectWebSocket() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _connectWebSocket();
      }
    });
  }

  void _handleIncomingMessage(String message) async {
    final parsedMessage = json.decode(message);
    final senderId = parsedMessage['from'];  // The ID of the sender
    final receiverId = parsedMessage['to'];  // The ID of the recipient
    final content = parsedMessage['content'];
    final error = parsedMessage['error'];

    // Retrieve the logged-in user's UID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final loggedInUserId = prefs.getString('userId');

    if (error != null) {
      print("Error from server: $error");
    } else if (senderId != null && content != null) {
      // Store only the content of the message
      String messageDisplay = content; // Only the content

      // Save the message to the sender's message list
      List<String> storedMessages = prefs.getStringList('chatMessages_$senderId') ?? [];
      storedMessages.insert(0, messageDisplay);
      await prefs.setStringList('chatMessages_$senderId', storedMessages);

      // Check if the message is meant for the logged-in user
      if (loggedInUserId != null && receiverId.toString() == loggedInUserId) {
        // Only display the message if it is from the current recipient
        if (senderId.toString() == widget.recipientId) {
          setState(() {
            _messages.insert(0, messageDisplay);  // Insert the content at the top
            _scrollToTop(); // Scroll to the top to show the new message
          });
        }
      } else {
        print("Message not for this user. Ignoring...");
      }
    }
  }


  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0); // Jump to the top of the list
    }
  }

  void _sendMessage() {
    String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty && _token != null) {
      bool containsIntegers = _hasIntegers(messageText);
      int countNumbers = _countNumbersInText(messageText);

      if (countNumbers > 6) {
        _showWarningDialog('Message cannot contain more than 6 numbers.');
        return;
      }

      if (containsIntegers) {
        consecutiveMessagesWithNumbers++;
        if (consecutiveMessagesWithNumbers > 1) {
          _showWarningDialog('You can\'t use consecutive messages with numbers.');
          return;
        }
      } else {
        consecutiveMessagesWithNumbers = 0;
      }

      setState(() {
        _messages.insert(0, 'You: $messageText'); // Add sent messages to the top
        _messageController.clear();
        _scrollToTop();
      });

      final messageData = {
        'token': _token,
        'to': int.parse(widget.recipientId),
        'content': messageText,
      };

      // Print the message that is being sent to WebSocket
      print("Sending message: $messageData");
      _channel.sink.add(jsonEncode(messageData));
      _saveMessages();
      _updateInboxConversation(widget.recipientId, messageText);
    }
  }


  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    // Save messages specific to the current recipient
    await prefs.setStringList('chatMessages_${widget.recipientId}', _messages);
  }

  void _updateInboxConversation(String recipientId, String content) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> conversations = prefs.getStringList('conversations') ?? [];

    bool conversationExists = conversations.any((conv) {
      final convMap = json.decode(conv) as Map<String, dynamic>;
      return convMap['recipientId'] == recipientId;
    });

    if (conversationExists) {
      conversations = conversations.map((conv) {
        final convMap = json.decode(conv) as Map<String, dynamic>;
        if (convMap['recipientId'] == recipientId) {
          convMap['lastMessage'] = content; // Update last message
          convMap['lastMessageUnread'] = true; // Mark as unread
          convMap['timestamp'] = DateFormat('HH:mm').format(DateTime.now()); // Update timestamp
        }
        return json.encode(convMap);
      }).toList();
    } else {
      // If the conversation doesn't exist, create a new one
      Map<String, dynamic> newConversation = {
        'recipientId': recipientId,
        'recipientUserName': widget.recipientUserName,
        'recipientUserImage': widget.recipientUserImage,
        'lastMessage': content,
        'lastMessageUnread': true,
        'timestamp': DateFormat('HH:mm').format(DateTime.now()),
      };
      conversations.add(json.encode(newConversation));
    }
    await prefs.setStringList('conversations', conversations);
    print('Saved conversations:$conversations');
  }


  bool _hasIntegers(String text) {
    return RegExp(r'\d').hasMatch(text);
  }

  int _countNumbersInText(String text) {
    return RegExp(r'\d').allMatches(text).length;
  }

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Warning', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Text(message),
        actions: <Widget>[
          TextButton(child: const Text('OK'), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.recipientUserImage),
              radius: 16,
            ),
            SizedBox(width: 8),
            Text(widget.recipientUserName, style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: ListView.builder(
                reverse: true,
                controller: _scrollController,
                itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index]; // This will now be just the content
                    final isSentByMe = message.startsWith('You:'); // Check if the message is sent by the user

                    return ListTile(
                      title: Align(
                        alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSentByMe ? Colors.blueGrey : Colors.white70,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            message, // This is now just the content
                            style: TextStyle(
                              color: isSentByMe ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'Type your message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}