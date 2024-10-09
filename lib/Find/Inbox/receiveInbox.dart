import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import '../../api/api.dart';
import 'newinbox.dart'; // Adjust import based on your structure

class InboxList extends StatefulWidget {
  const InboxList({Key? key}) : super(key: key);

  @override
  State<InboxList> createState() => _InboxListState();
}

class _InboxListState extends State<InboxList> {
  List<Map<String, dynamic>> _conversations = [];
  Set<int> _selectedIndices = {};
  bool _isMultiSelectMode = false;
  IOWebSocketChannel? _channel;

  bool get isWebSocketConnected => _channel != null && _channel!.closeCode == null;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
    _loadConversations();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }



  void _connectToWebSocket() async {
    String socketUrl = 'ws://202.21.32.153:8081/socket'; // Replace with your socket URL
    _channel = IOWebSocketChannel.connect(socketUrl);

    print('Attempting to connect to WebSocket...');

    // Retrieve the token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token != null) {
      // Send the token to the server
      _channel!.sink.add(jsonEncode({'token': token}));
      print('Token sent: $token');
    } else {
      print('No token found, unable to send.');
    }

    _channel!.stream.listen(
          (message) {
        print("Message received: $message");
        _handleIncomingMessage(message);
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed.');
      },
    );

    Future.delayed(Duration(milliseconds: 100), () {
      if (isWebSocketConnected) {
        print('WebSocket is connected.');
      } else {
        print('WebSocket is not connected.');
      }
    });
  }

  void _handleIncomingMessage(String message) async {
    print('Received message raw: $message');

    try {
      final parsedMessage = json.decode(message);
      print('Parsed message: $parsedMessage');

      if (parsedMessage.containsKey('content')) {
        final senderId = parsedMessage['from']; // Sender of the message
        final content = parsedMessage['content'];
        final recipientId = parsedMessage['to'];
        final isSentMessage = senderId == recipientId; // Assuming sender and receiver are the same for sent messages

        // Format the current time
        String formattedTime = DateFormat('HH:mm').format(DateTime.now());

        if (senderId != null && content != null && recipientId != null) {
          // Fetch user details based on senderId for incoming messages
          final userDetails = isSentMessage ? null : await _fetchUserDetails(senderId);

          if (userDetails != null || isSentMessage) {
            final userName = isSentMessage ? 'You' : userDetails?['uname'] ?? 'Unknown';
            final userImage = isSentMessage ? 'assets/images/default_avatar.png' : userDetails?['profile_photo'] ?? 'images/Userpfp.png';

            // Store message
            final prefs = await SharedPreferences.getInstance();
            List<String> storedMessages = prefs.getStringList('chatMessages_$senderId') ?? [];
            storedMessages.insert(0, content); // Store message content only
            await prefs.setStringList('chatMessages_$senderId', storedMessages);
            print('Stored messages: $storedMessages');

            // Update the conversation list
            List<String> conversations = prefs.getStringList('conversations') ?? [];
            Map<String, dynamic> conversationMap = {
              'recipientId': senderId,
              'recipientUserName': userName,
              'recipientUserImage': userImage,
              'lastMessage': content,
              'lastMessageUnread': !isSentMessage, // Mark as unread for received messages
              'timestamp': formattedTime,
            };

            // Check if conversation with this sender already exists
            bool conversationExists = conversations.any((conv) {
              final convMap = json.decode(conv) as Map<String, dynamic>;
              return convMap['recipientId'] == senderId;
            });

            if (conversationExists) {
              // Update existing conversation
              conversations = conversations.map((conv) {
                final convMap = json.decode(conv) as Map<String, dynamic>;
                if (convMap['recipientId'] == senderId) {
                  convMap['lastMessage'] = content;
                  convMap['lastMessageUnread'] = !isSentMessage;
                  convMap['timestamp'] = formattedTime;
                }
                return json.encode(convMap);
              }).toList();
            } else {
              // Create a new conversation
              conversations.add(json.encode(conversationMap));
            }

            await prefs.setStringList('conversations', conversations);
            _loadConversations(); // Refresh conversation list in the UI
          } else {
            print('User details could not be fetched for senderId: $senderId');
          }
        } else {
          print('Invalid conversation data, skipping this message.');
        }
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

// Method to fetch user details from the API
  Future<Map<String, dynamic>?> _fetchUserDetails(int uid) async {
    final prefs = await SharedPreferences.getInstance();
    final String baseUrl = '${API.api1}/user-details/$uid'; // Your API endpoint

    try {
      final response = await http.get(Uri.parse(baseUrl), headers: {
        'Authorization': 'Bearer ${prefs.getString('authToken')}', // Assuming you are using token-based authentication
      });

      if (response.statusCode == 200) {
        print('User details: ${response.body}');
        return json.decode(response.body);
      } else {
        print('Failed to load user details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }


  Future<void> _loadConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final storedConversations = prefs.getStringList('conversations') ?? [];

    setState(() {
      _conversations = storedConversations
          .map((conversation) => json.decode(conversation) as Map<String, dynamic>)
          .where((conv) =>
      conv['recipientId'] != null &&
          conv['recipientUserName'] != null &&
          conv['recipientUserImage'] != null &&
          conv['lastMessage'] != null)
          .toList();
    });
    print('Conversations: $_conversations');
  }



  Future<void> _refreshConversations() async {
    await _loadConversations();
  }



  void _navigateToChat(String recipientId, String recipientUserName, String recipientUserImage) {
    print('Navigating to chat with: $recipientUserName'); // Debug line
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          recipientId: recipientId.toString(),
          recipientUserName: recipientUserName,
          recipientUserImage: recipientUserImage,
        ),
      ),
    ).then((_) {
      // Optional: You can add any additional logic to execute after returning to InboxList
      print('Returned from chat screen.'); // Debug line
    });
  }


  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _deleteSelectedConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final storedConversations = prefs.getStringList('conversations') ?? [];

    _selectedIndices.toList().sort((a, b) => b.compareTo(a)); // Sort in reverse to avoid index issues
    for (int index in _selectedIndices) {
      storedConversations.removeAt(index);
    }

    await prefs.setStringList('conversations', storedConversations);
    setState(() {
      _conversations = storedConversations
          .map((conversation) => json.decode(conversation) as Map<String, dynamic>)
          .toList();
      _selectedIndices.clear();
      _isMultiSelectMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        actions: _isMultiSelectMode
            ? [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteSelectedConversations,
          ),
        ]
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshConversations,
        child: _conversations.isEmpty
            ? const Center(
          child: Text('No conversations yet.'),
        )
            : ListView.builder(
          itemCount: _conversations.length,
          itemBuilder: (context, index) {
            final conversation = _conversations[index];
            bool isSelected = _selectedIndices.contains(index);
            bool isUnread = conversation['lastMessageUnread'] == true;

            return Container(
              color: isSelected
                  ? Colors.grey[300]
                  : isUnread
                  ? Colors.blue[50]
                  : Colors.transparent,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: conversation['recipientUserImage'] != null && conversation['recipientUserImage'].isNotEmpty
                      ? NetworkImage(conversation['recipientUserImage'])
                      : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                ),
                title: Row(
                  children: [
                    Expanded(child: Text(conversation['recipientUserName'],
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold
                    ),)),
                    if (isSelected)
                      const Icon(Icons.check, color: Colors.green),
                    if (isUnread)
                      const Icon(Icons.circle, color: Colors.red, size: 8),
                  ],
                ),
                subtitle: Text(conversation['lastMessage'],
                style: TextStyle(
                  fontSize: 14,
                ),),
                trailing: Text(conversation['timestamp']),
                onTap: () {
                  if (_isMultiSelectMode) {
                    _toggleSelection(index);
                  } else {
                    _navigateToChat(
                      conversation['recipientId'].toString(),
                      conversation['recipientUserName'],
                      conversation['recipientUserImage'] ?? '',
                    );
                  }
                },
                onLongPress: () {
                  setState(() {
                    _isMultiSelectMode = true;
                    _toggleSelection(index);
                  });
                },
                selected: isSelected,
              ),
            );
          },
        ),
      ),
    );
  }
}
