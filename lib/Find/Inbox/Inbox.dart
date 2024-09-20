import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InboxChat extends StatefulWidget {
  final String userId;
  final String userName;

  const InboxChat({Key? key, required this.userId, required this.userName}) : super(key: key);

  @override
  _InboxChatState createState() => _InboxChatState();
}

class _InboxChatState extends State<InboxChat> {

  final _channel = WebSocketChannel.connect(Uri.parse('ws://202.21.32.153:8081'));
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];
  String? _loggedInUserId;

  @override
  void initState() {
    super.initState();
    _loadUserId();

    // Listen for incoming messages from the WebSocket channel
    _channel.stream.listen((message) {
      final decodedMessage = json.decode(message);
      if (decodedMessage['to'] == widget.userId || decodedMessage['from'] == _loggedInUserId) {
        setState(() {
          _messages.add('${decodedMessage['from']}: ${decodedMessage['message']}');
        });
      }
    });
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('userId');
    setState(() {
      _loggedInUserId = storedUserId;
    });

    print('Retrieved User ID: $storedUserId'); // Ensure it’s printed
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  void _sendMessage() {
    if (_textController.text.isNotEmpty && _loggedInUserId != null) {
      final message = {
        'to': widget.userId,
        'from': _loggedInUserId!,
        'message': _textController.text,
      };

      // Print message details
      print('Sending message:');
      print('From: ${message['from']}');
      print('To: ${message['to']}');
      print('Message: ${message['message']}');

      _channel.sink.add(json.encode(message));
      setState(() {
        _messages.add('Me: ${_textController.text}');
      });
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.userName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
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
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Send a message',
                    ),
                    onSubmitted: (value) => _sendMessage(),
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