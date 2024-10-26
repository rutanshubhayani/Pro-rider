import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel/widget/configure.dart';
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

class Message {
  final String content;
  final String type;
  final DateTime timestamp;
  final bool read; // Add read status

  Message(this.content, this.type, String formattedTime, this.read)
      : timestamp = _parseFormattedTime(formattedTime);

  static DateTime _parseFormattedTime(String formattedTime) {
    if (formattedTime.contains('T')) {
      return DateTime.parse(formattedTime);
    } else {
      return DateFormat('MM/dd/yyyy, hh:mm:ss a').parse(formattedTime);
    }
  }
}

class _ChatScreenState extends State<ChatScreen> {
  late WebSocketChannel _channel;
  final TextEditingController _messageController = TextEditingController();
  List<Message> _messages = [];
  String? _token;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isAtBottom = true;
  bool _hasFetchedOldMessages = false; // Flag to check if old messages have been fetched
  bool _noMessagesFound = false;
  int consecutiveMessagesWithNumbers = 0;


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _isAtBottom) {
        // Only scroll if the user is already at the bottom
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // Update _isAtBottom based on scroll position
      setState(() {
        _isAtBottom = _scrollController.offset >=
            _scrollController.position.maxScrollExtent - 50;
      });
    });
    _getToken();
  }

  Future<void> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('authToken');
      _connectWebSocket();
    });
  }

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('ws://202.21.32.153:8081'));

      if (_token != null) {
        print('WebSocket connected');
        _channel.sink.add(jsonEncode({
          'token': _token,
          'to': int.parse(widget.recipientId),
          'action': 'open_chat',
        }));
      }

      _channel.stream.listen(
        (message) {
          print("Server response:$message");
          _handleIncomingMessage(message);
        },
        onError: (error) {
          _reconnectWebSocket();
          print("WebSocket error: $error");
        },
        onDone: () {
          _reconnectWebSocket();
        },
      );
    } catch (e) {
      print("WebSocket connection error: $e");
      _showSnackbar("Unable to establish WebSocket connection.");
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
    final prefs = await SharedPreferences.getInstance();
    final loggedInUserId = prefs.getString('userId');

    if (parsedMessage.containsKey('error')) {
      if (parsedMessage['error'] == "No messages found between these users") {
        setState(() {
          _noMessagesFound = true; // Set flag for no messages
          _isLoading = false; // Stop loading
        });
      } else if (parsedMessage['error'] == "Message content is required") {
        // Handle message content error if needed
      }
    } else if (parsedMessage.containsKey('all_messages') && !_hasFetchedOldMessages) {
      List<dynamic> allMessages = parsedMessage['all_messages'];

      setState(() {
        for (var msg in allMessages) {
          final senderId = msg['from'];
          final content = msg['content'];
          final type = msg['type'];
          final formattedTime = msg['formatted_time'];
          bool isRead = msg['read'] ?? false; // Set read status from the server response

          if (senderId == widget.recipientId || senderId == loggedInUserId) {
            _messages.add(Message(content, type, formattedTime, isRead));
          }
        }
        _isLoading = false;
        _hasFetchedOldMessages = true; // Set the flag to true after fetching messages
        _noMessagesFound = false; // Reset no messages found flag
      });
      _scrollToBottom();
    } else if (parsedMessage.containsKey('from')) {
      // Handle individual new message
      final senderId = parsedMessage['from'];
      final receiverId = parsedMessage['to'];
      final content = parsedMessage['content'];
      final formattedTime = parsedMessage['formatted_time'];
      final messageType = parsedMessage['type'];
      bool isRead = parsedMessage['read'] ?? false; // Get read status for the new message

      // Reset no messages found flag when a message is received
      setState(() {
        _noMessagesFound = false;
      });

      // Check if the message is sent by the logged-in user and matches the current recipient
      if (loggedInUserId != null &&
          senderId.toString() == loggedInUserId &&
          receiverId.toString() == widget.recipientId &&
          messageType == 'sent') {
        setState(() {
          _messages.add(Message(content, 'sent', formattedTime, isRead));
          _isLoading = false; // Hide loading if a new message is received
        });
        _scrollToBottom();
      } else if (loggedInUserId != null &&
          receiverId.toString() == loggedInUserId &&
          senderId.toString() == widget.recipientId) {
        setState(() {
          _messages.add(Message(content, 'received', formattedTime, isRead));
          _isLoading = false; // Hide loading if a new message is received
        });
        _scrollToBottom();
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
      /*final newMessage = Message(
          messageText, 'sent', DateTime.now().toIso8601String());
*/
      // Update state immediately
      setState(() {
        // _messages.add( newMessage); // Append sent message to the end
        _messageController.clear();
        _isLoading = false; // Hide loading if a new message is sent
      });


      // Scroll to the bottom after sending a message

      // Prepare the message data for WebSocket
      final messageData = {
        'token': _token,
        'to': int.parse(widget.recipientId),
        'content': messageText,
      };

      // Send the message via WebSocket
      _channel.sink.add(jsonEncode(messageData));
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
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _scrollController.removeListener(() {}); // Remove the listener
    _channel.sink.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _noMessagesFound // Check if no messages found
                  ? Center(child: Text('No messages found.'))
                  : ListView.builder(
                controller: _scrollController,
                      itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isSentByMe = message.type == 'sent';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Align(
                      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: 250),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSentByMe ? kPrimaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  message.content,
                                  style: TextStyle(color: isSentByMe ? Colors.white : Colors.black),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('hh:mm a').format(message.timestamp),
                                style: TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                              if (isSentByMe) // Only show icon for sent messages
                                Padding(
                                  padding: const EdgeInsets.only(left: 4), // Minimal left padding
                                  child: Icon(
                                    message.read ? Icons.check_circle : Icons.check,
                                    color: message.read ? Colors.grey  : Colors.grey, // Different colors for read and unread
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    maxLines: null,
                    controller: _messageController,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
