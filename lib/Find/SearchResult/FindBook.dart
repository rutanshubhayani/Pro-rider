import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel/Find/ReviewTrip/review_trip.dart';
import 'package:travel/Find/rideverifyemail.dart';

import '../../api/api.dart';



class FindBook extends StatefulWidget {
  final Map<String, dynamic> tripData;
  final Map<String, dynamic> seats;

  const FindBook({super.key,required this.tripData,required this.seats});

  @override
  _FindBookState createState() => _FindBookState();
}
class _FindBookState extends State<FindBook> {
  bool _isSwitchOn = false; // State variable for Switch

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                'What you need to know',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: 20, left: 10.0, right: 15.0),
                  child: Image.asset(
                    'images/no-car.png',
                    height: 70,
                    width: 70,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0, right: 35),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This is not a taxi service',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          textAlign: TextAlign.justify,
                          'You need to meet at the pickup location, sit in the front seat with your driver and keep phone conversations to a minimum.',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 0.0),
                  child: Image.asset(
                    'images/no_cash.png',
                    height: 85,
                    width: 85,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0, right: 35),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cash is not allowed',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          textAlign: TextAlign.justify,
                          'All payments happen online and drivers get paid after trip.',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Image.asset(
                    'images/time.png',
                    height: 70,
                    width: 70,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 35),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Show up on time',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          textAlign: TextAlign.justify,
                          'Drivers leave on time, so make sure to arrive a bit early.',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 10),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isSwitchOn = !_isSwitchOn;
                  });
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'I understand that my account could be suspended if I break these rules',
                      ),
                    ),
                    Switch(
                      value: _isSwitchOn,
                      onChanged: (bool newValue) {
                        setState(() {
                          _isSwitchOn = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_isSwitchOn) {
              print('Next tapped');
              Get.to(FindReviewTrip(tripData: widget.tripData,),transition: Transition.fade);
            } else {
              print('Switch is off');
              // Optionally, you can show a message or indication to the user
            }
          },
          child: Center(
            child: Text(
              'Next',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: _isSwitchOn
                    ? Colors.black
                    : Colors.grey, // Conditional color
              ),
            ),
          ),
        ),
      ),
    );
  }
}


























class FindMeetDriver extends StatefulWidget {
  final Map<String, dynamic> tripData;

  const FindMeetDriver({super.key, required this.tripData});

  @override
  State<FindMeetDriver> createState() => _FindMeetDriverState();
}

class _FindMeetDriverState extends State<FindMeetDriver> {
  Map<String, dynamic>? driverData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDriverData();
  }

  Future<void> fetchDriverData() async {
    final uid = widget.tripData['uid'];
    final url = '${API.api1}/user-profile-and-vehicle-data/$uid';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Driver Data: $data'); // Debugging line

        setState(() {
          driverData = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load driver data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching driver data: $e'); // Debugging line
      setState(() {
        isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final DateTime dateTime = DateTime.parse(driverData!['user']['insdatetime'].toString() ?? 'Unknown');
    final String formattedDate = DateFormat('MMMM, yyyy').format(dateTime);
    return Scaffold(
      appBar: AppBar(
        title: Text('Book'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : driverData == null
          ? Center(child: Text('No driver data available'))
          : Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meet the driver',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            Row(
              children: [
                // Profile picture with border
                // Profile picture with border
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: FadeInImage.assetNetwork(
                      placeholder: 'images/default-user.png', // Placeholder image
                      image: '${driverData!['user']['profile_photo_url']}',
                      fit: BoxFit.cover,
                    ).image,
                  ),
                ),

                SizedBox(width: 12),
                // User details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            driverData!['user']['uname'] ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Joined ',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Divider(
              endIndent: 20,
            ),
            SizedBox(height: 30),
            Text(
              'Driver details:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 25),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    '${driverData!['vehicle']['vehicle_img_url']}',
                    height: 120,
                    width: 150,
                    fit: BoxFit.cover,
                    // Fallback image
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'images/default-car.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverData!['vehicle']['vehicle_model'] ?? 'Unknown Model',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${driverData!['vehicle']['vehicle_color'] ?? 'Unknown Color'}, ${driverData!['vehicle']['vehicle_year'] ?? 'Unknown Year'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // Navigate to EmailVerify or any other screen
            Get.to (() => RideEmailVerify());
          },
          child: Center(
            child: Text(
              'Next',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

}

