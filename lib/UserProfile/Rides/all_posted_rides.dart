import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Find/Trips/trips.dart';

class PostedUserRides extends StatelessWidget {
  const PostedUserRides({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'All User Rides',
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
                      TabItem(title: 'Cancel'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            AllPostedRides(),
            CancelledPostedRides(),
          ],
        ),
      ),
    );
  }
}








class AllPostedRides extends StatefulWidget {
  const AllPostedRides({super.key});

  @override
  _AllPostedRidesState createState() => _AllPostedRidesState();
}

class _AllPostedRidesState extends State<AllPostedRides> {
  List<Map<String, dynamic>> userTrips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserPosts();
  }

  Future<void> fetchUserPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('userId'); // Retrieve UID from SharedPreferences

    if (uid == null) {
      print('No user ID found in SharedPreferences.');
      return;
    }

    final url = Uri.parse('http://202.21.32.153:8081/get-user-posts/$uid');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Get profile photo and trips
        String profilePhoto = data['profile_photo'] ?? '';
        List<dynamic> trips = data['trips'];

        print('API Response: $trips');

        List<Map<String, dynamic>> sortedTrips = trips.map((trip) {
          return {
            'uid': uid,  // Using the UID retrieved from SharedPreferences
            'userName': (trip['uname'] ?? '').trim(),
            'userImage': profilePhoto,  // Using profile photo from the response
            'seatsLeft': trip['empty_seats'] ?? 0,
            'departure': trip['departure'] ?? '',
            'destination': trip['destination'] ?? '',
            'date': DateTime.tryParse(trip['leaving_date_time']) ?? DateTime.now(),
            'rideSchedule': trip['ride_schedule'] ?? '',
            'luggage': trip['luggage'] ?? '',
            'description': trip['description'] ?? '',
            'price': trip['price'] ?? 0,
            'otherItems': trip['other_items'] ?? '',
            'backRowSitting': trip['back_row_sitting'] ?? 'Not specified',
          };
        }).toList();

        // Sort the trips by date in descending order
        sortedTrips.sort((a, b) => b['date'].compareTo(a['date']));

        setState(() {
          userTrips = sortedTrips;
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        print('No trips found for this user');
        setState(() {
          isLoading = false;
        });
      } else {
        print('Failed to load user posts. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user posts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  String getFirstNameOfCity(String city) {
    return city.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('E, MMM d \'at\' h:mma');

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 13),
        child: isLoading
            ? ListView.builder(
          itemCount: 5, // Number of shimmer loading items
          itemBuilder: (context, index) {
            return ShimmerLoadingCard(); // Replace with your shimmer card widget
          },
        )
            : userTrips.isEmpty
            ? Center(child: Text('No trips found'))
            : ListView.builder(
          itemCount: userTrips.length,
          itemBuilder: (context, index) {
            final trip = userTrips[index];
            String formattedDate = dateFormat.format(trip['date']);
            String departureFirstName = getFirstNameOfCity(trip['departure']);
            String destinationFirstName = getFirstNameOfCity(trip['destination']);

            return GestureDetector(
              onTap: () {
                // Navigate to trip preview
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
      ),
    );
  }
}

class ShimmerLoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this with the actual shimmer loading card widget
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Color(0xFF51737A),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 20,
              color: Colors.grey[300],
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 20,
              color: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }
}






class CancelledPostedRides extends StatefulWidget {
  const CancelledPostedRides({super.key});

  @override
  _CancelledPostedRidesState createState() => _CancelledPostedRidesState();
}

class _CancelledPostedRidesState extends State<CancelledPostedRides> {
  List<Map<String, dynamic>> canceledTrips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCanceledTrips();
  }

  Future<void> fetchCanceledTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('http://202.21.32.153:8081/trips/canceled'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      List<Map<String, dynamic>> sortedTrips = data.map((trip) {
        DateTime parsedDate;
        try {
          parsedDate = DateTime.parse(trip['leaving_date_time']);
        } catch (e) {
          parsedDate = DateTime.now();
        }

        return {
          'post_a_trip_id': trip['post_a_trip_id'],
          'departure': trip['departure'] ?? '',
          'destination': trip['destination'] ?? '',
          'date': parsedDate,
          'rideSchedule': trip['ride_schedule'] ?? '',
          'luggage': trip['luggage'] ?? '',
          'description': trip['description'] ?? '',
          'price': trip['price'] ?? 0,
          'otherItems': trip['other_items'] ?? '',
          'backRowSitting': trip['back_row_sitting'] ?? 'Not specified',
        };
      }).toList();

      sortedTrips.sort((a, b) => b['date'].compareTo(a['date']));

      setState(() {
        canceledTrips = sortedTrips;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> restoreTrip(String postATripId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      return;
    }

    final response = await http.post(
      Uri.parse('http://202.21.32.153:8081/update-trip-status/$postATripId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'status': 'active'}),
    );

    if (response.statusCode == 200) {
      // Successfully restored the trip
      fetchCanceledTrips(); // Refresh the list of canceled trips
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip restored successfully')),
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to restore trip')),
      );
    }
  }

  String getFirstNameOfCity(String city) {
    return city.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('E, MMM d \'at\' h:mma');

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 13),
        child: isLoading
            ? ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return ShimmerLoadingCard();
          },
        )
            : canceledTrips.isEmpty
            ? Center(child: Text('No canceled trips found'))
            : ListView.builder(
          itemCount: canceledTrips.length,
          itemBuilder: (context, index) {
            final trip = canceledTrips[index];
            String formattedDate = dateFormat.format(trip['date']);
            String departureFirstName = getFirstNameOfCity(trip['departure']);
            String destinationFirstName = getFirstNameOfCity(trip['destination']);

            return GestureDetector(
              onTap: () {
                // Navigate to trip preview or details
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(width: 5),
                            Icon(Icons.cancel, color: Colors.red),
                            SizedBox(width: 5),
                            Text(
                              'Canceled Trip',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(top: 35, bottom: 10.0, right: 20),
                              child: Text(
                                '\$${trip['price']} ',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue
                                ),
                              ),
                            ),
                          ],
                        ),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 15, bottom: 10),
                        child: ElevatedButton(
                          onPressed: () => restoreTrip(trip['post_a_trip_id'].toString()),
                          child: Text('Restore'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Background color
                            foregroundColor: Colors.white
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
