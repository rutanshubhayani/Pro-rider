import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:travel/postrequest.dart';
import 'package:travel/posttrip.dart';
import 'Userprofile.dart';
import 'find.dart';
import 'home.dart';

class Message {
  String text;
  bool isSentByMe;

  Message({
    required this.text,
    required this.isSentByMe,
  });
}

class Inbox1 extends StatelessWidget {
  const Inbox1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Container(
            height: 40,
            width: 40,
            child: GestureDetector(
              onTap: () {
               Get.to(UserProfile(),transition: Transition.leftToRight);
              },
              child: Image.asset(
                'images/blogo.png',
              ),
            ),
          ),
        ),
        actions: [
          OutlinedButton.icon(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
               MaterialPageRoute(builder: (context) => FindScreen()),
              );
            },
            label: Text(
              'Find',
              style: TextStyle(color: Colors.black),
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
      body: InboxMain(),
    );
  }
}


class InboxMain extends StatefulWidget {
  @override
  State<InboxMain> createState() => _InboxMainState();
}

class _InboxMainState extends State<InboxMain> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) { // Navigate to Trips screen
        Get.to(() => HomeScreen(initialIndex: 1));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Inbox',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 134.0),
              child: TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Icon(Icons.archive_outlined, size: 25, color: Colors.black,),
                    SizedBox(width: 2,),
                    Text(
                      'Archived',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: Scrollbar(
          controller: ScrollController(),
          trackVisibility: true,
          thickness: 2,
          radius: Radius.circular(20),
          child: ListView.builder(
            controller: ScrollController(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Get.to(() => InboxScreen(),
                    transition: Transition.rightToLeft,
                  );
                },
                child: Inbox(),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white, // Background color of the bottom navigation bar
        height: kBottomNavigationBarHeight,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.to(() => PostTrip()); // Navigate to HomeScreen
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_car,size: 20,),
                    Text('Driver',style: TextStyle(fontSize: 14),),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0,bottom: 15),
              child: VerticalDivider(
                width: 1,
                color: Colors.grey, // Color of the divider
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.to(() => InboxMain()); // Navigate to HomeScreen
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox,size: 20,),
                    Text('Inbox',style: TextStyle(fontSize: 14),),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0,bottom: 15),
              child: VerticalDivider(
                width: 1,
                color: Colors.grey, // Color of the divider
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  _onItemTapped(1); // Set index for Trips screen
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trip_origin,size: 20,),
                    Text('Trips',style: TextStyle(fontSize: 14),),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0,bottom: 15),
              child: VerticalDivider(
                width: 1,
                color: Colors.grey, // Color of the divider
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.to(Postrequest());
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person,size: 20,),
                    Text('Passenger',style: TextStyle(fontSize: 14),),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Inbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Row(
            children: [
              SizedBox(width: 17,),
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage('https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/200/300'),
              ),
              SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Smiely',
                        style: TextStyle(fontSize: 15),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 5),
                        child: Icon(Icons.circle, size: 6,),
                      ),
                      Text(
                        'Inquiry',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Brampton to Windsor',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        ' on ',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Fri, Jul 5',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
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

