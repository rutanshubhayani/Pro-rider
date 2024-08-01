import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Message {
  String text;
  bool isSentByMe;

  Message({
    required this.text,
    required this.isSentByMe,
  });
}

class InboxScreen extends StatefulWidget {
  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<Message> messages = [];
  TextEditingController textController = TextEditingController();
  int consecutiveMessagesWithNumbers = 0; // Track consecutive messages with numbers

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/200/300'),
              radius: 16,
            ),
            SizedBox(width: 8),
            Text(
              'Smiley',
              style: TextStyle(fontSize: 20),
            ),
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
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  Message message = messages[index];
                  return ListTile(
                    title: Align(
                      alignment: message.isSentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: message.isSentByMe
                              ? Color(0xFFB2BEB5) // Blue color for sent messages
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: Colors.black, // White text color
                            fontSize: 16, // Font size
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
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (RawKeyEvent event) {
                if (event is RawKeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.enter) {
                  sendMessage();
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      autofocus: true,
                      controller: textController,
                      textInputAction: TextInputAction.none,
                      onSubmitted: (value) {},
                      maxLines: null,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'Chat with your ride partner',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onEditingComplete: () {},
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      sendMessage();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage() {
    String messageText = textController.text.trim();

    if (messageText.isNotEmpty) {
      bool containsIntegers = hasIntegers(messageText);
      int countNumbers = countNumbersInText(messageText);

      if (countNumbers > 6) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                ),
                Text(
                  'Warning',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            content: Text('Message cannot contain more than 6 numbers.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
        return;
      }

      if (containsIntegers) {
        consecutiveMessagesWithNumbers++;
        if (consecutiveMessagesWithNumbers > 1) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                  ),
                  Text(
                    'Warning',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              content: Text('You can\'t use consecutive messages with numbers.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
          return;
        }
      } else {
        consecutiveMessagesWithNumbers = 0; // Reset count if message doesn't have numbers
      }

      setState(() {
        messages.insert(
          0,
          Message(text: messageText, isSentByMe: true),
        );
        textController.clear();
      });
    }
  }

  bool hasIntegers(String text) {
    RegExp regex = RegExp(r'\d');
    return regex.hasMatch(text);
  }

  int countNumbersInText(String text) {
    RegExp regex = RegExp(r'\d');
    return regex.allMatches(text).length;
  }
}

