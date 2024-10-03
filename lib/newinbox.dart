import 'dart:convert';
import 'package:flutter/material.dart';
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

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();

    // Save specific messages for the current recipient
    await prefs.setStringList('chatMessages_${widget.recipientId}', _messages);

    // Store or update the conversation summary in 'conversations'
    List<String> storedConversations = prefs.getStringList('conversations') ?? [];

    // Create a conversation object (or find and update it)
    Map<String, dynamic> conversation = {
      'recipientId': widget.recipientId,
      'recipientUserName': widget.recipientUserName,
      'lastMessage': _messages.isNotEmpty ? _messages[0] : '', // The most recent message
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Update or add the conversation
    bool conversationExists = false;
    for (int i = 0; i < storedConversations.length; i++) {
      Map<String, dynamic> existingConversation = json.decode(storedConversations[i]);
      if (existingConversation['recipientId'] == widget.recipientId) {
        // Update the existing conversation
        storedConversations[i] = json.encode(conversation);
        conversationExists = true;
        break;
      }
    }

    if (!conversationExists) {
      storedConversations.add(json.encode(conversation));
    }

    // Save the updated conversation list
    await prefs.setStringList('conversations', storedConversations);
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
    final receiverId = parsedMessage['to'];  // The ID of the recipient (User1 in this case)
    final content = parsedMessage['content'];
    final error = parsedMessage['error'];

    // Retrieve the logged-in user's UID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final loggedInUserId = prefs.getString('userId');

    if (error != null) {
      print("Error from server: $error");
    } else if (senderId != null && content != null) {
      // Prepare the message for storage and display
      String messageDisplay = "$senderId: $content";

      // Save the message to the sender's message list, whether it's displayed or not
      List<String> storedMessages = prefs.getStringList('chatMessages_$senderId') ?? [];
      storedMessages.insert(0, messageDisplay);
      await prefs.setStringList('chatMessages_$senderId', storedMessages);

      // Check if the message is meant for the logged-in user
      if (loggedInUserId != null && receiverId.toString() == loggedInUserId) {
        // Display the message only if the active chat partner is the sender
        if (senderId.toString() == widget.recipientId) {
          setState(() {
            _messages.insert(0, messageDisplay);  // Insert the new message at the top
            _scrollToTop();
          });
        } else {
          // Message is from another user but stored for later retrieval
          print("Message from $senderId stored but not displayed (not from active chat).");
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
    }
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
                  final message = _messages[index];
                  final isSentByMe = message.startsWith('You:');
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
                          message,
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