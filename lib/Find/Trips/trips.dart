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
import 'package:travel/widget/configure.dart';
import 'package:travel/widget/shimmer.dart';
import 'gettrippreview.dart';


class Trips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Requests',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
         /* bottom: PreferredSize(
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
            *//* ActiveScreen(),
            RecentScreen(),*//*
             RequestsScreen(),
          ],*/
        ),
        body: RequestsScreen(),
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
  bool isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    setState(() {
      isLoading = true; // Set loading to true when fetching
    });

    try {
      final response = await http.get(Uri.parse('${API.api1}/post_requests_get'));

      print('requests response');
      print(response.body);
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
          isLoading = false; // Set loading to false after fetching
        });
      } else {
        throw Exception('Failed to load requests');
      }
    } catch (error) {
      print('Error fetching requests: $error');
      setState(() {
        isLoading = false; // Handle error and stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 13.0, right: 13, top: 13),
      child: RefreshIndicator(
        onRefresh: fetchRequests, // Call fetchRequests on refresh
        child: isLoading // Show shimmer when loading
            ? ListView.builder(
          itemCount: 5, // Number of shimmer items
          itemBuilder: (context, index) {
            return TripShimmerCard(); // Your shimmer loading widget
          },
        )
            : requests.isEmpty
            ? Center(
          child: Text(
            'No requests found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        )
            : ListView(
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
                    color: kPrimaryColor,
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
                                      color: kPrimaryColor,
                                      width: 3,
                                    ),
                                  ),
                                  child:CircleAvatar(
                                    radius: 30,
                                    backgroundImage: request['userImage'] != null && request['userImage'].isNotEmpty
                                        ? NetworkImage(request['userImage'])
                                        : AssetImage('images/Userpfp.png') as ImageProvider,
                                  ),

                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.verified, color: Colors.blue),
                                ),
                                Text(
                                  ' ${request['uname']}', // You can replace with request['userName'] if available
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


/*


class ActiveScreen extends StatefulWidget {
  @override
  _ActiveScreenState createState() => _ActiveScreenState();
}

class _ActiveScreenState extends State<ActiveScreen> {
  List<Map<String, dynamic>> trips = [];
  bool isLoading = true;
  Map<String, dynamic>? _selectedTrip;

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
        Uri.parse('${API.api1}/get-trips'),
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

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true; // Optionally show a loading state while refreshing
    });
    await fetchTrips(); // Fetch trips again
  }

  String getFirstNameOfCity(String city) {
    return city.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('E, MMM d \'at\' h:mma');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 13),
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: isLoading
            ? ListView.builder(
          itemCount: 5, // Number of shimmer loading items
          itemBuilder: (context, index) {
            return TripShimmerCard();
          },
        )
            : trips.isEmpty
            ? Center(
          child: Text(
            'No trips found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        )
            : ListView.builder(
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
                    color: kPrimaryColor,
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
                                      color: kPrimaryColor,
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
                        padding: const EdgeInsets.only(top: 13.0, left: 15, bottom: 10),
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

*/








/*


class RecentScreen extends StatefulWidget {
  @override
  _RecentScreenState createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  List<Map<String, dynamic>> trips = [];
  bool isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    setState(() {
      isLoading = true; // Set loading to true when fetching
    });

    try {
      final response = await http.get(Uri.parse('${API.api1}/get-trips'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print(response.body);

        List<Map<String, dynamic>> sortedTrips = data.map((trip) {
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
          isLoading = false; // Set loading to false after fetching
        });
      } else {
        print('Failed to load trips');
        setState(() {
          isLoading = false; // Set loading to false if fetch fails
        });
      }
    } catch (error) {
      print('Error fetching trips: $error');
      setState(() {
        isLoading = false; // Handle error and stop loading
      });
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
      child: RefreshIndicator(
        onRefresh: fetchTrips, // Call fetchTrips on refresh
        child: isLoading // Show shimmer when loading
            ? ListView.builder(
          itemCount: 5, // Number of shimmer items
          itemBuilder: (context, index) {
            return TripShimmerCard(); // Your shimmer loading widget
          },
        )
            : trips.isEmpty
            ? Center(
          child: Text(
            'No trips found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        )
            : ListView.builder(
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
                    color: kPrimaryColor,
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
                                      color: kPrimaryColor,
                                      width: 3,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.transparent, // Optional: set a background color if needed
                                    child: trip['userImage'] != null && trip['userImage'].isNotEmpty
                                        ? ClipOval(
                                      child: Image.network(
                                        trip['userImage'],
                                        width: 60,  // Adjust according to CircleAvatar size
                                        height: 60, // Same size as the CircleAvatar (2 * radius)
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            'images/Userpfp.png',
                                            width: 60,  // Same size as CircleAvatar
                                            height: 60, // Same size as CircleAvatar
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    )
                                        : ClipOval(
                                      child: Image.asset(
                                        'images/Userpfp.png',
                                        width: 60,  // Same size as CircleAvatar
                                        height: 60, // Same size as CircleAvatar
                                        fit: BoxFit.cover,
                                      ),
                                    ),
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

*/








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



