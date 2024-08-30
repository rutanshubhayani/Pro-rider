import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
      ),
      body: listView(),
    );
  }
}


Widget listView() {
  return ListView.separated(
    itemBuilder: (context, index) {
      return listViewItem(index);
    },
    separatorBuilder: (context, index) {
      return Divider(height: 1);
    },
    itemCount: 15,
  );
}

Widget listViewItem(int index) {
  return Container(
    margin: EdgeInsets.all( 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        prefixIcon(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              message(index),
              timeAndDate(index),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget prefixIcon(){
  return Padding(
    padding: const EdgeInsets.only(right: 5.0),
    child: Container(
      height: 50,
      width: 50,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade300,
      ),
      child: Icon(
        Icons.notifications,
        size: 25,
        color: Colors.grey.shade700,
      ),
    ),
  );
}

Widget message(int index) { // Add Widget return type
  double textSize = 14;
  return Padding(
    padding: const EdgeInsets.only(top: 5.0),
    child: Container(
      child: RichText(
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: 'Message',
          style: TextStyle(
            fontSize: textSize,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: ' Message Description',
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget timeAndDate(int index) { // Add Widget return type
  // Get the current date and time
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd-MM-yyyy').format(now);
  String formattedTime = DateFormat('h:mm a').format(now);

  return Container(
    margin: EdgeInsets.only(top: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          formattedDate,
          style: TextStyle(
            fontSize: 10,
          ),
        ),
        Text(
          formattedTime,
          style: TextStyle(
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}