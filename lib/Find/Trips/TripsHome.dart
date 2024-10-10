import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel/Find/Inbox/Inbox.dart';
import 'package:travel/Find/Passenger/findrequests.dart';
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
import '../../api/api.dart';
import '../../home.dart';
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
  int _selectedIndex = 0;


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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        // Navigate to Trips screen
        Get.to(() => HomeScreen(initialIndex: 1));
      }
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

  Future<void> _checkTripPostConditions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token != null) {
      try {
        final vehicleResponse = await http.get(
          Uri.parse('${API.api1}/get-vehicle-data'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        final licenseResponse = await http.get(
          Uri.parse('${API.api1}/images'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        int? licenseStatus;
        if (licenseResponse.statusCode == 200) {
          final jsonResponse = json.decode(licenseResponse.body);
          licenseStatus = int.tryParse(jsonResponse['status'].toString());
        }

        bool vehicleDataFound = vehicleResponse.statusCode == 200;

        if (licenseStatus == 1 && vehicleDataFound) {
          Get.to(() => PostTrip());
        } else {
          _showStatusDialog(context, licenseStatus, vehicleDataFound);
        }
      } catch (e) {
        _showErrorDialog(context, 'An error occurred. Please try again.');
      }
    } else {
      print('Auth token not found');
    }
  }


  void _showStatusDialog(BuildContext context, int? licenseStatus, bool vehicleDataFound) {
    String message = '';
    bool showLicenseAlert = licenseStatus != 1;
    bool showVehicleAlert = !vehicleDataFound;

    if (showLicenseAlert) {
      message += 'Your license is either not uploaded or under approval.\n';
    }

    if (showVehicleAlert) {
      message += 'You have not uploaded vehicle details. Please upload before posting a ride.\n';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Status Alert'),
          content: Text(message),
          actions: [
            if (showLicenseAlert)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.to(() => VerifyLicense());
                },
                child: Text('Go to License'),
              ),
            if (showVehicleAlert)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.to(() => VehicleDetails());
                },
                child: Text('Go to Vehicle Details'),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }


  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
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
                MaterialPageRoute(builder: (context) => MyHomePage()),
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
          FindRequests(), // Index 1
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
                  onTap: _checkTripPostConditions,
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
              padding: const EdgeInsets.only(top: 15.0, bottom: 15),
              child: VerticalDivider(
                width: 1,
                color: Colors.grey, // Color of the divider
              ),
            ),
            Expanded(
              child: Tooltip(
                message: 'Inbox',
                child: InkWell(
                  onTap: () {
                    Get.to(() => InboxList()); // Navigate to HomeScreen
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 20,
                      ),
                      Text(
                        'Inbox',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15),
              child: VerticalDivider(
                width: 1,
                color: Colors.grey, // Color of the divider
              ),
            ),
            Expanded(
              child: Tooltip(
                message: 'Requests details',
                child: InkWell(
                  onTap: () {
                    _onItemTapped(1); // Set index for Trips screen
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trip_origin,
                        size: 20,
                      ),
                      Text(
                        'Requests',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15),
              child: VerticalDivider(
                width: 1,
                color: Colors.grey, // Color of the divider
              ),
            ),
/*            Expanded(
              child: Tooltip(
                message: 'Reqeust a trip',
                child: InkWell(
                  onTap: () {
                    Get.to(() => Postrequest());
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person,
                        size: 20,
                      ),
                      Text(
                        'Passenger',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            )*/
          ],
        ),
      ),
    );
  }
}
