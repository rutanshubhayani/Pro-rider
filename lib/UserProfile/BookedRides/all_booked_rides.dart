import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel/UserProfile/BookedRides/BookedPreview.dart';
import 'package:travel/auth/login.dart';
import 'package:travel/widget/configure.dart';
import '../../Find/Trips/trips.dart';
import '../../api/api.dart';

import '../Userprofile.dart';

class BookedUserRides extends StatelessWidget {
  const BookedUserRides({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'All Booked Rides',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: Colors.transparent,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors
                        .transparent, // change background color of whole tabbar
                  ),
                  child: const TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent, // underline of tabbar
                    indicator: BoxDecoration(
                      color: Color(0xFFece9ec),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,
                    tabs: [
                      TabItem(title: 'All'),
                      TabItem(title: 'Cancelled'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            AllBookedRides(),
            CancelledBookedRides(),
          ],
        ),
      ),
    );
  }
}









class AllBookedRides extends StatefulWidget {
  const AllBookedRides({super.key});

  @override
  _AllBookedRidesState createState() => _AllBookedRidesState();
}

class _AllBookedRidesState extends State<AllBookedRides> {
  bool _isLoading = true;
  List<dynamic> _bookedRides = [];

  @override
  void initState() {
    super.initState();
    _fetchBookedRides();
  }

  Future<void> _fetchBookedRides() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null || authToken.isEmpty) {
      Get.to(() => LoginScreen());
      Get.snackbar('Authentication Error', 'User not authenticated',
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${API.api1}/get-bookings'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('All booked rides: ${response.body}');
        setState(() {
          _bookedRides = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print(response.body);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
      Get.snackbar('Error', 'Internal server error.');
    }
  }

  Future<void> cancelBooking(String bookingTripId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      Get.snackbar('Authentication Error', 'User not authenticated');
      return;
    }

    final response = await http.post(
      Uri.parse('${API.api1}/cancel-booking/$bookingTripId'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _fetchBookedRides();
      });
      Get.snackbar(
        duration:Duration(seconds: 1) ,
        'Success',
        'Booking canceled successfully',
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: () {
            _restoreBooking(bookingTripId);
          },
          child: Text('Undo', style: TextStyle(color: Colors.blue)),
        ),
      );

    } else {
      print('Error cancelling ride: ${response.body}');
      Get.snackbar('Error', 'Error cancelling ride');
    }
  }

  Future<void> _restoreBooking(String bookingTripId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      Get.snackbar('Authentication Error', 'User not authenticated');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${API.api1}/restore-booking/$bookingTripId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _fetchBookedRides();
        Get.closeCurrentSnackbar();
      } else {
        print('Error restoring booking: ${response.body}');
        Get.snackbar('Error', 'Error restoring booking.');
      }
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'Error restoring booking.');
    }
  }

  Future<void> _cancelRide(String bookingTripId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Cancellation'),
          content: Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirm) {
      await cancelBooking(bookingTripId);
    }
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('E, MMM d \'at\' h:mma');

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchBookedRides,
        child: _isLoading
            ? _buildShimmerLoading()
            : _bookedRides.isEmpty
            ? const Center(child: Text('No booked rides found.'))
            : _buildBookedRidesList(dateFormat),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Color(0xFFE5E5E5),
          highlightColor: Color(0xFFF0F0F0),
          child: Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 20, width: 150, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 20, width: 100, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookedRidesList(DateFormat dateFormat) {
    return ListView.builder(
      itemCount: _bookedRides.length,
      itemBuilder: (context, index) {
        final ride = _bookedRides[index];

        // Safely extract fields with null-aware operators
        String formattedDate = ride['leaving_date_time'] != null
            ? dateFormat.format(DateTime.parse(ride['leaving_date_time']))
            : 'Date not available';

        String departureFirstName = ride['departure'] != null
            ? getFirstNameOfCity(ride['departure'])
            : '';

        String destinationFirstName = ride['destination'] != null
            ? getFirstNameOfCity(ride['destination'])
            : '';

        String userName = ride['uname'] ?? 'Unknown User';
        String profilePhoto = ride['profile_photo'] ?? '';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(color: kPrimaryColor, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: profilePhoto.isNotEmpty
                            ? NetworkImage(profilePhoto)
                            : AssetImage('images/Userpfp.png') as ImageProvider,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          userName,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${ride['booked_seats'] ?? '0'} Seats booked',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: departureFirstName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        TextSpan(
                          text: '  ${ride['departure'] ?? 'Unknown Departure'}',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: destinationFirstName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        TextSpan(
                          text: '  ${ride['destination'] ?? 'Unknown Destination'}',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (ride['booking_trip_id'] != null) {
                          _cancelRide(ride['booking_trip_id'].toString());
                        } else {
                          Get.snackbar('Error', 'Booking ID is not available');
                        }
                      },
                      child: Text('Cancel Booking'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0XFFd90000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String getFirstNameOfCity(String city) {
    return city.split(' ').first;
  }
}












class CancelledBookedRides extends StatefulWidget {
  const CancelledBookedRides({super.key});

  @override
  _CancelledBookedRidesState createState() => _CancelledBookedRidesState();
}

class _CancelledBookedRidesState extends State<CancelledBookedRides> {
  bool _isLoading = true;
  List<dynamic> _cancelledRides = [];

  @override
  void initState() {
    super.initState();
    _fetchCancelledRides();
  }

  Future<void> _fetchCancelledRides() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      Get.to(() => LoginScreen());
      Get.snackbar('Error', 'User not authenticated',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      String bookingUserId = prefs.getString('bookingUserId') ?? '';

      final response = await http.get(
        Uri.parse('${API.api1}/canceled-bookings/$bookingUserId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('all cancelled ride: ${response.body}');
        setState(() {
          _cancelledRides = jsonDecode(response.body);

          // Sort rides by date to ensure the most recent is on top
          _cancelledRides.sort((a, b) => DateTime.parse(b['leaving_date_time'])
              .compareTo(DateTime.parse(a['leaving_date_time'])));

          // Limit to the last 5 cancelled rides
          if (_cancelledRides.length > 5) {
            _cancelledRides =
                _cancelledRides.take(5).toList(); // Keep only the last 5
          }

          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        /*Get.snackbar('Error', 'Error fetching cancelled rides.',
            snackPosition: SnackPosition.BOTTOM);*/
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('Error', 'Error.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _showRestoreConfirmationDialog(String bookingTripId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Restore'),
          content: const Text('Are you sure you want to restore this booking?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _restoreBooking(bookingTripId); // Proceed with restoring the booking
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _restoreBooking(String bookingTripId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      Get.snackbar('Error', 'User not authenticated',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${API.api1}/restore-booking/$bookingTripId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Booking restored successfully.',
            duration:Duration(seconds: 1) ,
            snackPosition: SnackPosition.BOTTOM);
        _fetchCancelledRides();
      } else {
        print('Error restoring booking:${response.body}');
        Get.snackbar('Error', 'Error restoring booking.',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print('Error restoring booking:$e');

      Get.snackbar('Error', 'Error restoring booking.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('E, MMM d \'at\' h:mma');

    return Scaffold(
      body: _isLoading
          ? _buildShimmerLoading()
          : _cancelledRides.isEmpty
          ? const Center(child: Text('No cancelled rides found.'))
          : _buildCancelledRidesList(dateFormat),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Color(0xFFE5E5E5),
          highlightColor: Color(0xFFF0F0F0),
          child: Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 20,
                    width: 150,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 20,
                    width: 100,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCancelledRidesList(DateFormat dateFormat) {
    return ListView.builder(
      itemCount: _cancelledRides.length,
      itemBuilder: (context, index) {
        final ride = _cancelledRides[index];
        String formattedDate =
        dateFormat.format(DateTime.parse(ride['leaving_date_time']));
        String departureFirstName = getFirstNameOfCity(ride['departure']);
        String destinationFirstName = getFirstNameOfCity(ride['destination']);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
              color: kPrimaryColor,
              width: 1.5,
            ),
          ),
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: kPrimaryColor,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(ride['profile_photo']),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      ride['uname'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Text(
                      ' ${ride['booked_seats']} Seats cancelled',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: departureFirstName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: '  ${ride['departure']}',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 13.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: destinationFirstName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: '  ${ride['destination']}',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    '$formattedDate',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ride['status'] == 'driver_canceled'
                      ? Text(
                    'Ride cannot be restored as it was cancelled by driver.',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : ElevatedButton(
                    onPressed: () {
                      _showRestoreConfirmationDialog(
                          ride['booking_trip_id'].toString());
                    },
                    child: Text('Restore Booking'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF3d5a80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String getFirstNameOfCity(String city) {
    return city.split(' ').first;
  }
}
