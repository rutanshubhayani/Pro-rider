import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel/Find/SearchResult/searchresult.dart';
import 'package:travel/api/api.dart';
import 'package:travel/Find/SearchResult/Findtrippreview.dart';
import 'gettrippreview.dart';


class Trips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Trips',
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
                      TabItem(title: 'Active'),
                      TabItem(title: 'Recent'),
                      TabItem(title: 'Requests'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
             ActiveScreen(),
            RecentScreen(),
             RequestsScreen(),
          ],
        ),
      ),
    );
  }
}





class ActiveScreen extends StatefulWidget {
  @override
  _ActiveScreenState createState() => _ActiveScreenState();
}

class _ActiveScreenState extends State<ActiveScreen> {
  List<Map<String, dynamic>> trips = [];
  bool isLoading = true;
  Map<String, dynamic>? _selectedTrip;
  bool _showCancelButton = false; // Track visibility of cancel button

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken') ?? '';

      final response = await http.get(
        Uri.parse('http://202.21.32.153:8081/get-trips'),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print(response.body);

        List<Map<String, dynamic>> sortedTrips = data.map((trip) {

          return {

            'uid': trip['uid'].toString() ?? 'UID not found',
            'post_a_trip_id': trip['post_a_trip_id'].toString() ?? 'Not found',
            'userName': (trip['uname'] ?? '').trim(),
            'userImage': trip['profile_photo'] ?? '',
            'seatsLeft': trip['empty_seats'] ?? 0,
            'departure': trip['departure'] ?? '',
            'destination': trip['destination'] ?? '',
            'date': DateTime.tryParse(trip['leaving_date_time']) ?? DateTime.now(),
            'rideSchedule': trip['ride_schedule'] ?? '',
            'luggage': trip['luggage'] ?? '',
            'description': trip['description'] ?? '',
            'price': trip['price'] ?? 0,
            'stops': trip['stops'] ?? [],
            'otherItems': trip['other_items'] ?? '',
            'backRowSitting': trip['back_row_sitting'] ?? 'Not specified',
          };
        }).toList();

        // Sort trips by date in descending order
        sortedTrips.sort((a, b) => b['date'].compareTo(a['date']));

        setState(() {
          trips = sortedTrips;
          isLoading = false;
        });
      } else {
        print('Failed to load trips');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching trips: $error');
    }
  }

  Future<void> _cancelTrip(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken') ?? '';

    try {
      final response = await http.post(
        Uri.parse('http://202.21.32.153:8081/cancel-trip/$postId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Trip canceled successfully', snackPosition: SnackPosition.BOTTOM);
        fetchTrips(); // Refresh the trip list
      } else {
        Get.snackbar('Error', 'Failed to cancel trip', snackPosition: SnackPosition.BOTTOM);
        print('Failed to cancel trip : ${response.statusCode}');
      }
    } catch (error) {
      Get.snackbar('Error', 'An error occurred while canceling the trip: $error', snackPosition: SnackPosition.BOTTOM);
      print('Error canceling trip: $error');
    }
  }

  Future<void> _showCancelDialog(Map<String, dynamic> trip) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Ride'),
          content: Text('Are you sure you want to cancel this ride?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes, Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _cancelTrip(trip['post_a_trip_id'].toString());
              },
            ),
          ],
        );
      },
    );
  }

  String getFirstNameOfCity(String city) {
    return city.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('E, MMM d \'at\' h:mma');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 13),
      child: isLoading
          ? ListView.builder(
        itemCount: 5, // Number of shimmer loading items
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Color(0XFFe1e1e1)!,
            highlightColor: Color(0XFFeeeeee)!,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                  color: Color(0xFF51737A),
                  width: 1.5,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                          child: Row(
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
                                  backgroundColor: Colors.grey[300],
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(Icons.verified, color: Colors.blue),
                              SizedBox(width: 5),
                              Container(
                                color: Colors.grey[300],
                                width: 100,
                                height: 16,
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 35, bottom: 10.0, right: 20),
                          child: Container(
                            color: Colors.grey[300],
                            width: 80,
                            height: 16,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 13),
                      child: Container(
                        color: Colors.grey[300],
                        width: 150,
                        height: 16,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 13.0, left: 15),
                      child: Container(
                        color: Colors.grey[300],
                        width: 200,
                        height: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      )
          : ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          String formattedDate = dateFormat.format(trip['date']);
          String departureFirstName = getFirstNameOfCity(trip['departure']);
          String destinationFirstName = getFirstNameOfCity(trip['destination']);

          return GestureDetector(
            onLongPress: () {
              setState(() {
                if (_selectedTrip == trip) {
                  _showCancelButton = !_showCancelButton; // Toggle visibility
                } else {
                  _selectedTrip = trip;
                  _showCancelButton = true; // Show button for the selected trip
                }
              });
            },
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GetTripPreview(
                          tripData: trip,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: Color(0xFF51737A),
                        width: 1.5,
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                                child: Row(
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
                                        backgroundImage: trip['userImage'] != null && trip['userImage'].isNotEmpty
                                            ? NetworkImage(trip['userImage'])
                                            : AssetImage('images/Userpfp.png') as ImageProvider,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Icon(Icons.verified, color: Colors.blue),
                                    SizedBox(width: 5),
                                    Text(
                                      trip['userName'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(top: 35, bottom: 10.0, right: 20),
                                child: Text(
                                  '${trip['seatsLeft']} seats left',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: RichText(
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
                                        text: '  ${trip['departure']}',
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
                            padding: const EdgeInsets.only(top: 13, left: 15),
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
                                    text: '  ${trip['destination']}',
                                    style: TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 13.0, left: 15),
                            child: Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_selectedTrip == trip) // Show cancel option if the trip is selected
                  Positioned(
                    bottom: 15,
                    right: 15,
                    child: AnimatedOpacity(
                      opacity: _showCancelButton ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 300),
                      child: AnimatedPositioned(
                        duration: Duration(milliseconds: 300),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showCancelButton = false; // Hide the cancel option after action
                            });
                            _showCancelDialog(trip);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white, // Add background color
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.cancel_outlined),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Text(
                                      'Cancel Ride',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}













class RecentScreen extends StatefulWidget {
  @override
  _RecentScreenState createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  List<Map<String, dynamic>> trips = [];

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    final response = await http.get(Uri.parse('${API.api1}/get-trips'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print(response.body);

      List<Map<String, dynamic>> sortedTrips = data.map((trip) {
        print('Original date: ${trip['leaving_date_time']}'); // Debugging line

        return {
          'uid': trip['uid'].toString() ?? 'UID not found',
          'userName': (trip['uname'] ?? '').trim(),
          'userImage': trip['profile_photo'] ?? '',
          'seatsLeft': trip['empty_seats'] ?? 0,
          'departure': trip['departure'] ?? '',
          'destination': trip['destination'] ?? '',
          'date': DateTime.tryParse(trip['leaving_date_time']) ?? DateTime.now(),
          'rideSchedule': trip['ride_schedule'] ?? '',
          'luggage': trip['luggage'] ?? '',
          'description': trip['description'] ?? '',
          'price': trip['price'] ?? 0,
          'stops': trip['stops'] ?? [],
          'otherItems': trip['other_items'] ?? '',
          'backRowSitting': trip['back_row_sitting'] ?? 'Not specified',
        };
      }).toList();

      // Sort trips by date in descending order
      sortedTrips.sort((a, b) => b['date'].compareTo(a['date']));

      setState(() {
        trips = sortedTrips;
      });
    } else {
      print('Failed to load trips');
    }
  }





  String getFirstNameOfCity(String city) {
    return city.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('E, MMM d \'at\' h:mma');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 13),
      child: ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          String formattedDate = dateFormat.format(trip['date']);
          String departureFirstName = getFirstNameOfCity(trip['departure']);
          String destinationFirstName = getFirstNameOfCity(trip['destination']);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GetTripPreview(
                    tripData: trip,
                  ),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                  color: Color(0xFF51737A),
                  width: 1.5,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                          child: Row(
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
                                  backgroundImage: trip['userImage'] != null && trip['userImage'].isNotEmpty
                                      ? NetworkImage(trip['userImage'])
                                      : AssetImage('images/Userpfp.png') as ImageProvider,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(Icons.verified, color: Colors.blue),
                              SizedBox(width: 5),
                              Text(
                                trip['userName'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 35, bottom: 10.0, right: 20),
                          child: Text(
                            '${trip['seatsLeft']} seats left',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: RichText(
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
                                  text: '  ${trip['departure']}',
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
                      padding: const EdgeInsets.only(top: 13, left: 15),
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
                              text: '  ${trip['destination']}',
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 13.0, left: 15),
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}









class TabItem extends StatelessWidget {
  final String title;

  const TabItem({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
          ),
        ],
      ),
    );
  }
}



