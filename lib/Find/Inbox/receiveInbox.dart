import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceiveInbox extends StatefulWidget {
  const ReceiveInbox({Key? key}) : super(key: key);

  @override
  State<ReceiveInbox> createState() => _ReceiveInboxState();
}

class _ReceiveInboxState extends State<ReceiveInbox> {
  late WebSocketChannel _channel;
  final List<String> _messages = [];
  String? _loggedInUserId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _channel = WebSocketChannel.connect(Uri.parse('ws://202.21.32.153:8081'));

    _channel.stream.listen((message) {
      final decodedMessage = json.decode(message);
      if (decodedMessage['to'] == _loggedInUserId || decodedMessage['from'] == _loggedInUserId) {
        // Print the sender ID
        print('Message received from user ID: ${decodedMessage['from']}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Messages'),
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
        ],
      ),
    );
  }
}
