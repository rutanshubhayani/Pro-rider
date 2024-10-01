import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel/UserProfile/BookedRides/BookedPreview.dart';
import '../../Find/Trips/trips.dart';
import '../../api/api.dart';
import '../Userprofile.dart';



class BookedUserRides extends StatelessWidget {
  const BookedUserRides({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate directly to UserProfile screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UserProfile()),
              );
            },
          ),
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
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: Colors.transparent,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent, // change background color of whole tabbar
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

    if (authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${API.api1}/get-bookings'), // Updated API URL
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('All booked rides of user: ${response.body}');
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Internal server error.')),
      );
    }
  }

  Future<void> _cancelRide(String postATripId) async {
    // Show confirmation dialog
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

    // If confirmed, proceed to cancel the booking
    if (confirm) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? authToken = prefs.getString('authToken');

      if (authToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('${API.api1}/cancel-book-trip/$postATripId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Store the cancelled ride temporarily
        final cancelledRide = _bookedRides.firstWhere((ride) => ride['post_a_trip_id'].toString() == postATripId);

        // Remove the cancelled ride from the _bookedRides list
        setState(() {
          _bookedRides.removeWhere((ride) => ride['post_a_trip_id'].toString() == postATripId);
        });

        // Show snackbar with undo option
        Get.snackbar(
          'Success',
          'Trip cancelled successfully',
          snackPosition: SnackPosition.BOTTOM,
    );
      } else {
        print('Failed to cancel booking. ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel booking.')),
        );
      }
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

  // Shimmer loading effect
  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 6, // Number of shimmer items
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

  // Booked rides list after data is loaded
  Widget _buildBookedRidesList(DateFormat dateFormat) {
    return ListView.builder(
      itemCount: _bookedRides.length,
      itemBuilder: (context, index) {
        final ride = _bookedRides[index];
        String formattedDate = dateFormat.format(DateTime.parse(ride['leaving_date_time']));
        String departureFirstName = getFirstNameOfCity(ride['departure']);
        String destinationFirstName = getFirstNameOfCity(ride['destination']);

        return GestureDetector(
          onTap: () {
            // Add navigation or additional functionality here if needed
            Get.to(() => GetBookedPreview(tripData: _bookedRides,));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                  color: Color(0xFF51737A),
                  width: 1.5,
                ),
              ),
              margin: index == 0 ? const EdgeInsets.only(top: 10, left: 10, right: 10) : const EdgeInsets.only(left: 10, right: 10, bottom: 0), // Remove bottom margin for all but the last card
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
                              color: Color(0xFF51737A),
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: ride['profile_photo'] != null && ride['profile_photo'].isNotEmpty
                                ? NetworkImage(ride['profile_photo'])
                                : AssetImage('images/Userpfp.png') as ImageProvider,
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
                          ' ${ride['booked_seats']} Seats booked',
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
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        '$formattedDate',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _cancelRide(ride['post_a_trip_id'].toString());
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
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
        print(response.body);
        setState(() {
          _cancelledRides = jsonDecode(response.body);

          // Sort rides by date to ensure the most recent is on top
          _cancelledRides.sort((a, b) => DateTime.parse(b['leaving_date_time']).compareTo(DateTime.parse(a['leaving_date_time'])));

          // Limit to the last 5 cancelled rides
          if (_cancelledRides.length > 5) {
            _cancelledRides = _cancelledRides.take(5).toList(); // Keep only the last 5
          }

          _isLoading = false;
        });
      } else {
        print('Error fetching cancelled rides: ${response.body}');
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching cancelled rides.')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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

  // Shimmer loading effect
  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 6, // Number of shimmer items
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

  // Cancelled rides list after data is loaded
  Widget _buildCancelledRidesList(DateFormat dateFormat) {
    return ListView.builder(
      itemCount: _cancelledRides.length,
      itemBuilder: (context, index) {
        final ride = _cancelledRides[index];
        String formattedDate = dateFormat.format(DateTime.parse(ride['leaving_date_time']));
        String departureFirstName = getFirstNameOfCity(ride['departure']);
        String destinationFirstName = getFirstNameOfCity(ride['destination']);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
              color: Color(0xFF51737A),
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
                          color: Color(0xFF51737A),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        // Placeholder image for demonstration
                        backgroundImage: AssetImage('images/Userpfp.png'),
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
