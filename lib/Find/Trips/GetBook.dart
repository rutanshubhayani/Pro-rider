import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel/Find/ReviewTrip/review_trip.dart';
import 'package:travel/Find/rideverifyemail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../api/api.dart';


class GetBook extends StatefulWidget {
  final Map<String, dynamic> tripData;
  final int bookedSeats;

  const GetBook({super.key,required this.tripData,required this.bookedSeats});

  @override
  _GetBookState createState() => _GetBookState();
}
class _GetBookState extends State<GetBook> {
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
              Get.to(() => GetReviewTrip(tripData: widget.tripData,bookedSeats: widget.bookedSeats,),transition: Transition.fade);
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























class GetMeetDriver extends StatefulWidget {
  final Map<String, dynamic> tripData;

  const GetMeetDriver({super.key, required this.tripData});

  @override
  State<GetMeetDriver> createState() => _GetMeetDriverState();
}

class _GetMeetDriverState extends State<GetMeetDriver> {
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
        setState(() {
          driverData = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load driver data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching driver data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30,
            width: 200,
            color: Colors.grey[200],
          ),
          SizedBox(height: 10),
          Container(
            height: 20,
            width: 150,
            color: Colors.grey[200],
          ),
          SizedBox(height: 10),
          Container(
            height: 20,
            width: 100,
            color: Colors.grey[200],
          ),
          SizedBox(height: 30),
          Divider(),
          SizedBox(height: 30),
          Container(
            height: 20,
            width: 200,
            color: Colors.grey[200],
          ),
          SizedBox(height: 10),
          Container(
            height: 120,
            width: 150,
            color: Colors.grey[200],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime dateTime = DateTime.parse(driverData?['user']['insdatetime'].toString() ?? 'Unknown');
    final String formattedDate = DateFormat('MMMM, yyyy').format(dateTime);

    return Scaffold(
      appBar: AppBar(
        title: Text('Book'),
      ),
      body: isLoading
          ? Center(child: buildShimmerEffect())
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
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 40),
        Row(
          children: [
            // Profile picture with shimmer
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 3),
              ),
              child: isLoading
                  ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.white,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                ),
              )
                  : CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage('${driverData!['user']['profile_photo_url']}'),
                backgroundColor: Colors.transparent,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isLoading
                      ? buildShimmerEffect()
                      : Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified, color: Colors.blue, size: 20),
                          SizedBox(width: 4),
                          Text(
                            driverData!['user']['uname'] ?? 'Unknown',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Joined ', style: TextStyle(fontSize: 16, color: Colors.black54)),
                          Text(formattedDate, style: TextStyle(fontSize: 16, color: Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
              ],
            ),
            SizedBox(height: 30),
            Divider(endIndent: 20),
            SizedBox(height: 30),
            Text('Driver details:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 25),
            Row(
              children: [
                // Vehicle image with shimmer
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: isLoading
                      ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.white,
                    child: Container(
                      height: 120,
                      width: 150,
                      color: Colors.grey[200],
                    ),
                  )
                      : Image.network(
                    '${driverData!['vehicle']['vehicle_img_url']}',
                    height: 120,
                    width: 150,
                    fit: BoxFit.cover,
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
                    isLoading
                        ? Container(
                      height: 20,
                      width: 150,
                      color: Colors.grey[200],
                    )
                        : Text(
                      driverData!['vehicle']['vehicle_model'] ?? 'Unknown Model',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    isLoading
                        ? Container(
                      height: 20,
                      width: 180,
                      color: Colors.grey[200],
                    )
                        : Text(
                      '${driverData!['vehicle']['vehicle_color'] ?? 'Unknown Color'}, ${driverData!['vehicle']['vehicle_year'] ?? 'Unknown Year'}',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
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
            Get.to(() => RideEmailVerify());
          },
          child: Center(
            child: Text(
              'Next',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
