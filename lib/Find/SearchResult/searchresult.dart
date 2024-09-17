import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel/UserProfile/Userprofile.dart';
import 'package:travel/api/api.dart';
import 'Findtrippreview.dart';
import '../Trips/gettrippreview.dart';

class SearchResult extends StatefulWidget {
  final int initialTabIndex;
  final List<Map<String, dynamic>> results;
  final List<String> selectedCities;

  SearchResult({
    Key? key,
    this.initialTabIndex = 0,
    required this.results,
    required this.selectedCities,
  }) : super(key: key);

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Text('Search Results',),
              ),
              TextButton(
                onPressed: () {
                  Get.to(UserProfile(),transition: Transition.rightToLeft);
                },
                child: Text(
                  'Settings',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: Colors.transparent,
                ),
                child: TabBar(
                  dividerColor: Colors.transparent, // underline of tab bar
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Color(0xFFece9ec),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black54,
                  tabs: [
                    Tab(child: Text('All')),
                    Tab(child: Text('Trips')),
                    Tab(child: Text('Requests')),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            AllScreen(trips: widget.results, selectedCities: widget.selectedCities),
            TripsScreen(), // Pass the results if needed
            RequestsScreen(), // Implement RequestsScreen
          ],
        ),
      ),
    );
  }
}


class AllScreen extends StatelessWidget {
  final List<Map<String, dynamic>> trips;
  final List<String> selectedCities;

  AllScreen({required this.trips, required this.selectedCities});

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('E, MMM d \'at\' h:mma');

    // Filter trips based on selected cities
    List<Map<String, dynamic>> filteredTrips = trips.where((trip) {
      String departureCity = trip['departure'] ?? '';
      String destinationCity = trip['destination'] ?? '';
      return selectedCities.contains(departureCity) ||
          selectedCities.contains(destinationCity);
    }).toList();

    // Sort filteredTrips by date in descending order
    filteredTrips.sort((a, b) {
      DateTime dateA = DateTime.tryParse(a['leaving_date_time'] ?? '') ??
          DateTime.now();
      DateTime dateB = DateTime.tryParse(b['leaving_date_time'] ?? '') ??
          DateTime.now();
      return dateB.compareTo(dateA); // Sort in descending order
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 13),
      child: ListView.builder(
        itemCount: filteredTrips.length,
        itemBuilder: (context, index) {
          final trip = filteredTrips[index];

          // Log trip data for debugging
          print('Trip data: $trip');

          String formattedDate = 'Date not available'; // Default value for missing date

          // Check if 'leaving_date_time' field exists and is not empty
          String dateString = trip['leaving_date_time'] ?? '';
          if (dateString.isNotEmpty) {
            print('Date string from API: $dateString');
            try {
              DateTime date = DateTime.parse(dateString);
              formattedDate = dateFormat.format(date);
            } catch (e) {
              // Handle parsing error
              print('Date parsing error: $e');
            }
          } else {
            print('Date field is empty or missing');
          }

          int seatsLeft = trip['empty_seats'] ?? 0;
          String userImage = trip['profile_photo'] ?? '';
          String userName = trip['uname'] ??
              'Unknown'; // Updated to use 'uname' field

          // Extract first name of the city from departure and destination
          String getFirstCityName(String city) {
            // Split the city name by spaces and return the first part
            return city
                .split(' ')
                .first;
          }

          String departureCityFirstName = getFirstCityName(
              trip['departure'] ?? 'Unknown Departure');
          String destinationCityFirstName = getFirstCityName(
              trip['destination'] ?? 'Unknown Destination');

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FindTripPreview(tripData: trip),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10),
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
                                  backgroundImage: trip['profile_photo'] !=
                                      null && trip['profile_photo'].isNotEmpty
                                      ? NetworkImage(trip['profile_photo'])
                                      : AssetImage(
                                      'images/Userpfp.png') as ImageProvider,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(Icons.verified, color: Colors.blue),
                              SizedBox(width: 5),
                              Text(
                                userName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 35, bottom: 10.0, right: 20),
                              child: Text(
                                '$seatsLeft seats left',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
                                  text: departureCityFirstName,
                                  // Display first name of departure city
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                TextSpan(
                                  text: '  ${trip['departure'] ??
                                      'Unknown Departure'}',
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
                              text: destinationCityFirstName,
                              // Display first name of destination city
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            TextSpan(
                              text: '  ${trip['destination'] ??
                                  'Unknown Destination'}',
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









class TripsScreen extends StatefulWidget {
  @override
  _TripsScreenState createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
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














class RequestsScreen extends StatefulWidget {
  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  List<dynamic> requests = [];

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    final response = await http.get(Uri.parse('http://202.21.32.153:8081/post_requests_get'));

    if (response.statusCode == 200) {
      List<dynamic> fetchedRequests = json.decode(response.body);

      // Sort requests by departure_date in descending order
      fetchedRequests.sort((a, b) {
        DateTime dateA = DateTime.parse(a['departure_date']);
        DateTime dateB = DateTime.parse(b['departure_date']);
        return dateB.compareTo(dateA); // For descending order
      });

      setState(() {
        requests = fetchedRequests;
      });
    } else {
      throw Exception('Failed to load requests');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('E, MMM d \'at\' h:mma').format(now);

    return Padding(
      padding: const EdgeInsets.only(left: 13.0, right: 13, top: 13),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: requests.map((request) {
            // Parse the departure date from the API response
            DateTime departureDate = DateTime.parse(request['departure_date']);
            // Format the date into a readable format
            String formattedDate = DateFormat('E, MMM d \'at\' h:mma').format(departureDate);

            // Get only the first word (city name) from the location
            String firstfromCity = request['from_location'].split(' ').first;
            String firsttoCity = request['to_location'].split(' ').first;

            return GestureDetector(
              onTap: () {
                // Handle tap
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
                            padding: const EdgeInsets.only(left: 15.0, top: 10, bottom: 10),
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
                                    backgroundImage: NetworkImage('https://picsum.photos/200/300'),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.verified, color: Colors.blue),
                                ),
                                Text(
                                  'Chandeep',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 60),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 35, bottom: 10.0),
                              child: Text(
                                '${request["seats_required"]} seats required',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                    text: firstfromCity,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '  ${request['from_location']}',
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
                        padding: EdgeInsets.only(top: 13, left: 15),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: firsttoCity,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: '  ${request['to_location']}',
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
          }).toList(),
        ),
      ),
    );
  }
}
