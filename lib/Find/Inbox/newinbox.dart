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
    _connectWebSocket();
  }

  Future<void> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('authToken');
    });
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMessages = prefs.getStringList('chatMessages_${widget.recipientId}') ?? [];
    setState(() {
      _messages = storedMessages;
    });
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('chatMessages_${widget.recipientId}', _messages);
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(Uri.parse('ws://202.21.32.153:8081'));
    if (_token != null) {
      _channel.sink.add(jsonEncode({'token': _token}));
    }

    _channel.stream.listen(
          (message) {
        _handleIncomingMessage(message);
      },
      onError: (error) => print("WebSocket error: $error"),
      onDone: () {
        print("WebSocket connection closed");
        _connectWebSocket();
      },
    );
  }

  void _handleIncomingMessage(String message) {
    final parsedMessage = json.decode(message);
    final sender = parsedMessage['from'];
    final content = parsedMessage['content'];
    if (sender != null && content != null) {
      setState(() {
        _messages.insert(0, "$sender: $content"); // Add new messages to the top
        _scrollToTop();
      });
      _saveMessages();
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
        _messages.insert(0, '$messageText'); // Add sent messages to the top
        _messageController.clear();
        _scrollToTop();
      });

      _channel.sink.add(jsonEncode({'token': _token, 'to': int.parse(widget.recipientId), 'content': messageText}));
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
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Warning', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Text(message),
        actions: <Widget>[
          TextButton(child: Text('OK'), onPressed: () => Navigator.of(context).pop()),
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
