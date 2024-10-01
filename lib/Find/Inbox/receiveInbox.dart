import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../newinbox.dart';

class InboxList extends StatefulWidget {
  const InboxList({Key? key}) : super(key: key);

  @override
  State<InboxList> createState() => _InboxListState();
}

class _InboxListState extends State<InboxList> {
  List<Map<String, dynamic>> _conversations = [];
  Set<int> _selectedIndices = {}; // Store selected indices
  bool _isMultiSelectMode = false; // Track multi-select mode

  @override
  void initState() {
    super.initState();
    _loadConversations(); // Load stored conversations on startup
  }

  Future<void> _loadConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final storedConversations = prefs.getStringList('conversations') ?? [];

    // Decode stored conversations and add them to the list
    setState(() {
      _conversations = storedConversations
          .map((conversation) => json.decode(conversation) as Map<String, dynamic>)
          .toList();
    });
  }

  // Navigate to the ChatScreen with the recipient details
  void _navigateToChat(String recipientId, String recipientUserName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          recipientId: recipientId,
          recipientUserName: recipientUserName,
          recipientUserImage: '',
        ),
      ),
    );
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

    // Remove selected conversations
    _selectedIndices.toList().sort((a, b) => b.compareTo(a)); // Sort in reverse to avoid index issues
    for (int index in _selectedIndices) {
      storedConversations.removeAt(index);
    }

    // Update SharedPreferences and conversation list
    await prefs.setStringList('conversations', storedConversations);
    setState(() {
      _conversations = storedConversations
          .map((conversation) => json.decode(conversation) as Map<String, dynamic>)
          .toList();
      _selectedIndices.clear();
      _isMultiSelectMode = false; // Exit multi-select mode
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
      body: _conversations.isEmpty
          ? const Center(
        child: Text('No conversations yet.'),
      )
          : ListView.builder(
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          bool isSelected = _selectedIndices.contains(index);
          return Container(
            color: isSelected ? Colors.grey[300] : Colors.transparent, // Highlight selected
            child: ListTile(
              title: Row(
                children: [
                  Expanded(child: Text(conversation['recipientUserName'])),
                  if (isSelected) // Show checkmark if selected
                    const Icon(Icons.check, color: Colors.green),
                ],
              ),
              subtitle: Text(conversation['lastMessage']),
              trailing: Text(conversation['timestamp']),
              onTap: () {
                if (_isMultiSelectMode) {
                  _toggleSelection(index);
                } else {
                  _navigateToChat(
                    conversation['recipientId'],
                    conversation['recipientUserName'],
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
    );
  }
}
