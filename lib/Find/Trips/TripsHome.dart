import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel/Find/Inbox/Inbox.dart';
import 'package:travel/Find/find.dart';
import 'package:travel/auth/login.dart';
import 'package:travel/Find/Passenger/postrequest.dart';
import 'package:travel/Find/Driver/posttrip.dart';
import 'package:travel/UserProfile/profilesetting.dart';
import 'package:get/get.dart';
import 'package:travel/Find/Trips/trips.dart';
import '../../UserProfile/License/verifylicenese.dart';
import '../../UserProfile/Userprofile.dart';
import '../../UserProfile/vechiledetails.dart';
import '../Inbox/receiveInbox.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  HomeScreen({this.initialIndex = 0});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Set initial index if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(_currentIndex);
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavBarItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(index,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
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
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          // Inbox1(), // Index 0
          Trips(), // Index 1
          // UserProfile(), // Index 2
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white, // Background color of the bottom navigation bar
        height: kBottomNavigationBarHeight,
        child: Row(
          children: [
            Expanded(
              child: Tooltip(
                message: 'Post a trip as driver',
                child: InkWell(
                  onTap: () {
                    final vehicleController = Get.put(VehicleDetailsController());
                    final imageController = Get.put(ImageUploadController());

                    bool isDetailsPosted = vehicleController.isDetailsPosted.value;
                    bool isImageUploaded = imageController.isImageUploaded.value;

                    if (!isImageUploaded && !isDetailsPosted) {
                      // Show alert if neither image nor details are uploaded
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Upload Required'),
                            content: Text('Please upload both your vehicle image and vehicle details.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Get.to(() => VerifyLicense()); // Navigate to upload image page
                                },
                                child: Text('Upload License'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.to(() => VehicleDetails()); // Navigate to upload details page
                                },
                                child: Text('Upload Details'),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (!isImageUploaded) {
                      // Show alert if only image is not uploaded
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Upload Image'),
                            content: Text('Please upload your vehicle image.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Get.to(() => VerifyLicense()); // Navigate to upload image page
                                },
                                child: Text('Upload Image'),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (!isDetailsPosted) {
                      // Show alert if only details are not uploaded
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Upload Details'),
                            content: Text('Please upload your vehicle details.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Get.to(() => VehicleDetails()); // Navigate to upload details page
                                },
                                child: Text('Upload Details'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // Navigate to PostTrip if both image and details are uploaded
                      Get.to(() => PostTrip());
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_car, size: 20),
                      Text('Driver', style: TextStyle(fontSize: 14)),
                    ],
                  ),
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
              child: Tooltip(
                message: 'Inbox',
                child: InkWell(
                  onTap: ()
                  {
                    Get.to(() => ReceiveInbox()); // Navigate to HomeScreen
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
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0,bottom: 15),
              child: VerticalDivider(
                width: 1,
                color: Colors.grey, // Color of the divider
              ),
            ),
            Expanded(
              child: Tooltip(
                message: 'Trip details',
                child: InkWell(
                  onTap: () {
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
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0,bottom: 15),
              child: VerticalDivider(
                width: 1,
                color: Colors.grey, // Color of the divider
              ),
            ),
            Expanded(
              child: Tooltip(
                message: 'Reqeust a trip',
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
            ),
          ],
        ),
      ),
    );
  }
}
