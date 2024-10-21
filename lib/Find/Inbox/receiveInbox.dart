import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import '../../api/api.dart';
import '../../chat_photo.dart';
import 'newinbox.dart'; // Adjust import based on your structure


class Conversation {
  final String recipientUserImage;
  final String recipientUserName; // Add this line

  Conversation({
    required this.recipientUserImage,
    required this.recipientUserName, // Add this line
  });

  // If you're retrieving this from a JSON object, you can add a fromJson method
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      recipientUserImage: json['recipientUserImage'],
      recipientUserName: json['recipientUserName'], // Map the JSON field
    );
  }
}


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
  Set<int> _clickedIndices = {};
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredConversations = [];


  bool get isWebSocketConnected => _channel != null && _channel!.closeCode == null;

  String _formatDateAndTime(String time) {
    // Get today's date
    DateTime now = DateTime.now();

    // Combine today's date with the time
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);

    return '$formattedDate'; // Combine date and time
  }
  String _formatTime(String time) {
    // Create a DateFormat for the input format
    DateFormat inputFormat = DateFormat("MM/dd/yyyy, h:mm:ss a");
    DateTime dateTime = inputFormat.parse(time); // Parse the input string
    return DateFormat('HH:mm').format(dateTime); // Format to show only hours and minutes
  }


  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
    _filteredConversations = _conversations; // Initialize filtered list
    _searchController.addListener(_filterConversations);
  }


  @override
  void dispose() {
    _searchController.dispose(); // Clean up the controller
    _channel?.sink.close();
    super.dispose();
  }


  void _filterConversations() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredConversations = _conversations;
      } else {
        _filteredConversations = _conversations.where((conversation) {
          return conversation['recipientUserName'].toLowerCase().contains(query);
        }).toList();
      }
    });
  }


  void _clearSearch() {
    _searchController.clear();
    _filterConversations(); // Update the filtered conversations list
    FocusScope.of(context).unfocus(); // Remove focus from the TextField
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
        // print("Message received: $message");
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

      // Retrieve the current user's ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? currentUserIdString = prefs.getString('userId');
      int? currentUserId = int.tryParse(currentUserIdString ?? '');
      if (currentUserId == null) {
        print('Error: Unable to parse user ID from SharedPreferences');
        return;
      }

      // Check if the incoming message has 'latest_messages'
      if (parsedMessage != null && parsedMessage.containsKey('latest_messages')) {
        List<dynamic> latestMessages = parsedMessage['latest_messages'];

        for (var msg in latestMessages) {
          int? senderId = int.tryParse(msg['from']?.toString() ?? '');
          int? recipientId = int.tryParse(msg['to']?.toString() ?? '');

          if (senderId != null && recipientId != null) {
            int otherUserId = (senderId == currentUserId) ? recipientId : senderId;
            _updateOrAddConversation(msg, otherUserId);
          }
        }

        // Update the state with new conversations
        setState(() {});
      } else {
        // Handle new direct messages
        int? senderId = int.tryParse(parsedMessage['from']?.toString() ?? '');
        int? recipientId = int.tryParse(parsedMessage['to']?.toString() ?? '');

        if (senderId != null && recipientId != null) {
          int otherUserId = (senderId == currentUserId) ? recipientId : senderId;
          _updateOrAddConversation(parsedMessage, otherUserId);
        }
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

// Helper method to update or add conversation
  void _updateOrAddConversation(Map<String, dynamic> msg, int userId) async {
    bool conversationExists = _conversations.any((conv) => conv['recipientId'] == userId);
    if (conversationExists) {
      for (var existingConversation in _conversations) {
        if (existingConversation['recipientId'] == userId) {
          setState(() {
            // Update existing conversation with the latest message
            existingConversation['lastMessage'] = msg['message'] ?? msg['content'];
            existingConversation['lastMessageUnread'] = !(msg['read'] ?? true);
            existingConversation['timestamp'] = msg['time'] ?? msg['formatted_time'];
          });

          // Remove the updated conversation to re-insert it later
          _conversations.remove(existingConversation);
          break; // Break the loop after finding the conversation
        }
      }
    } else {
      Map<String, dynamic>? userDetails = await _fetchUserDetails(userId);
      String recipientUserName = userDetails?['uname'] ?? 'User $userId';
      String recipientUserImage = userDetails?['profile_photo'] ?? '';

      setState(() {
        // Add the new conversation to the list
        _conversations.insert(0, {
          'recipientId': userId,
          'recipientUserName': recipientUserName,
          'recipientUserImage': recipientUserImage,
          'lastMessage': msg['message'] ?? msg['content'],
          'lastMessageUnread': !(msg['read'] ?? true),
          'timestamp': msg['time'] ?? msg['formatted_time'],
        });
      });
    }

    // Sort conversations based on the timestamp, latest first
    _sortConversations();
    setState(() {});
  }

  void _sortConversations() {
    DateFormat inputFormat = DateFormat("MM/dd/yyyy, h:mm:ss a");

    _conversations.sort((a, b) {
      try {
        DateTime timeA = inputFormat.parse(a['timestamp']);
        DateTime timeB = inputFormat.parse(b['timestamp']);
        return timeB.compareTo(timeA); // Sort in descending order
      } catch (e) {
        print('Error parsing date: ${e.toString()}'); // Log the error
        return 0; // Keep original order if there's an error
      }
    });
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





  void _navigateToChat(String recipientId, String recipientUserName, String recipientUserImage) {
    print('Navigating to chat with: $recipientUserName'); // Debug line
    print('Recipient ID: $recipientId, Image: $recipientUserImage'); // Debug line

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          recipientId: recipientId, // Ensure these match
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



  void _showProfilePhoto(String? imageUrl, String? receiverUserName) {
    showDialog(
      context: context,
      builder: (context) {
        return Material(
          color: Colors.transparent, // Make the background transparent
          child: Stack(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to FullScreenImage on image tap
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => FullScreenImage(
                          imageUrl: imageUrl ?? '',
                          userName: receiverUserName ?? 'User', // Provide a default name
                        ),
                      ),
                    );
                  },
                  child: ClipOval(
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: 300, // Set the width for circular size
                      height: 300, // Set the height for circular size
                    )
                        : Image.asset(
                      'images/Userpfp.png',
                      fit: BoxFit.cover,
                      width: 300, // Set the width for circular size
                      height: 300, // Set the height for circular size
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 240,
                right: 20,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) {
                      FocusScope.of(context).unfocus(); // Remove focus on submit
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: _isMultiSelectMode
            ? [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {},
          ),
        ]
            : null,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Remove focus from the TextField
        },
        child: _filteredConversations.isEmpty
            ? const Center(
          child: Text('No conversations yet.'),
        )
            : ListView.builder(
          itemCount: _filteredConversations.length,
          itemBuilder: (context, index) {
            final conversation = _filteredConversations[index];
            bool isSelected = _selectedIndices.contains(index);
            bool isUnread = conversation['lastMessageUnread'] == true;

            return Container(
              color: isSelected ? Colors.grey[300] : Colors.transparent,
              child: ListTile(
                leading: GestureDetector(
                  onTap: () => _showProfilePhoto(conversation['recipientUserImage'],conversation['recipientUserName']),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: conversation['recipientUserImage'] != null &&
                        conversation['recipientUserImage'].isNotEmpty
                        ? NetworkImage(conversation['recipientUserImage'])
                        : AssetImage('images/Userpfp.png') as ImageProvider,
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        conversation['recipientUserName'],
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Container(
                  constraints: BoxConstraints(
                    maxWidth: 200,
                    maxHeight: 20,
                  ),
                  child: Text(
                    conversation['type'] == 'sent' ? 'sent: ${conversation['lastMessage']}' : conversation['lastMessage'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatDateAndTime(conversation['timestamp']),
                    ),
                    Text(
                      _formatTime(conversation['timestamp']),
                    ),
                  ],
                ),
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


