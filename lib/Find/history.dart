import 'package:flutter/material.dart';
import 'package:travel/UserProfile/PostedRides/all_posted_rides.dart';
import 'package:travel/widget/configure.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('History'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to PostedUserRides when tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostedUserRides()),
                );
              },
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: kPrimaryColor, width: 2),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(10, 10),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.all(16.0), // Optional: adds some space around the card
                  child: Padding(
                    padding: EdgeInsets.all(16.0), // Adds padding inside the card
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Optional: Wrap Image in a Container for more control
                        Container(
                          alignment: Alignment.centerLeft, // Align to left
                          child: Image.asset(
                            'images/posthistory.png',
                            height: 100,
                            width: 100,
                          ),
                        ),
                        Text(
                          'Post History',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: Text(
                                'Access your ride history to view, edit, or cancel your bookings. Check who’s joined your ride and stay in control of your travel plans!',
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            Spacer(),
                            Expanded(child: Icon(Icons.arrow_forward_ios_rounded)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Other containers remain unchanged
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.27,
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: kPrimaryColor, width: 2),
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.all(16.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Post History',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text('Detail 1: Some description here.'),
                      Text('Detail 2: Additional information here.'),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.27,
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: kPrimaryColor, width: 2),
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.all(16.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Post History',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text('Detail 1: Some description here.'),
                      Text('Detail 2: Additional information here.'),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
