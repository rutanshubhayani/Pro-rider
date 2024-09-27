import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final String recipientId; // The user ID of the recipient you're chatting with
  final String recipientUserName;

  ChatScreen({required this.recipientId,required this.recipientUserName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late WebSocketChannel _channel;
  TextEditingController _messageController = TextEditingController();
  List<String> messages = [];

  String? _authToken;

  @override
  void initState() {
    super.initState();
    print('Receiver\'s user ID: ${widget.recipientId}');
    print('User name: ${widget.recipientUserName}'); // Print the user name
    _getAuthTokenAndConnect();
  }

  // Get token from SharedPreferences and connect to WebSocket
  Future<void> _getAuthTokenAndConnect() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _authToken = prefs.getString('authToken'); // Retrieve the token
    });

    if (_authToken != null) {
      _connectToWebSocket(_authToken!); // Connect with token
    } else {
      print('No Auth Token found');
    }
  }

  // WebSocket connection using the token
  void _connectToWebSocket(String token) {
    final url = 'ws://202.21.32.153:8081?token=$token'; // Pass token in URL

    _channel = WebSocketChannel.connect(
      Uri.parse(url),
    );

    // Listen for incoming messages
    _channel.stream.listen((message) {
      setState(() {
        messages.add(message); // Add received message to the list
      });
    });
  }

  // Send message over WebSocket
  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      // Prepare the message object
      final messageContent = _messageController.text.trim();
      final message = jsonEncode({
        'to': widget.recipientId,
        'content': messageContent,
      });

      // Print the message details to the terminal
      print('To: ${widget.recipientId}'); // Recipient
      print('Message: $messageContent'); // Message content

      // Send the message over the WebSocket
      _channel.sink.add(message);

      setState(() {
        messages.add('Me: $messageContent'); // Add sent message to the list
        _messageController.clear(); // Clear the input field after sending
      });
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat with ${widget.recipientUserName}")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: "Type your message"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage, // Handle sending the message
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
