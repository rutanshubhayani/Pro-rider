import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Make sure to import GetX if you use Get.to
import 'package:travel/notification.dart';
import 'package:travel/postrequest.dart';
import 'package:travel/posttrip.dart';
import 'package:travel/find.dart';
import 'Userprofile.dart';
import 'home.dart';

class RideScreen extends StatefulWidget {
  const RideScreen({Key? key}) : super(key: key);

  @override
  _RideScreenState createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Container(
            height: 40,
            width: 40,
            child: GestureDetector(
              onTap: () {
               // Get.to(UserProfile(userName1: '', usermail: '', unumber: '', ), transition: Transition.leftToRight);
              },
              child: Image.asset(
                'images/blogo.png',
              ),
            ),
          ),
        ),
        actions: [
          IconButton(onPressed: (){
            Get.to(NotificationScreen());
          },
              icon:Icon(Icons.notifications_active)),
          /*OutlinedButton.icon(
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
          ),*/
          SizedBox(width: 15),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PostTrip()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 13, top: 100),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car,size: 50,),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'I\'m driving',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'I want to fill empty seats in my car',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              /*Container(
                height: 8.0, // Adjust the height as needed
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueAccent, // Start color
                      Colors.tealAccent, // End color
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),*/
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Postrequest()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 13, top: 110),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_active,size: 40,color: Colors.white,),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'I need a ride',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Notify me when a ride is available',
                                style: TextStyle(
                                  color: Color(0xFFf0f0f0),
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: Image.asset('images/bwlogo.png',
              height: 70,
              width: 70,),
          ),
        ],
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
              padding: const EdgeInsets.only(top: 10.0,bottom: 10),
              child: VerticalDivider(
                width: 1,
                color: Colors.grey, // Color of the divider
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.to(() => HomeScreen()); // Navigate to HomeScreen
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
              padding: const EdgeInsets.only(top: 10.0,bottom: 10),
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
              padding: const EdgeInsets.only(top: 10.0,bottom: 10),
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
