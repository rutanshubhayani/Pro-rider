import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel/UserProfile/Userprofile.dart';
import 'Findtrippreview.dart';

class SearchResult extends StatefulWidget {
  final List<Map<String, dynamic>> results;
  final List<String> selectedCities;

  SearchResult({
    Key? key,
    required this.results,
    required this.selectedCities,
  }) : super(key: key);

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Text('Search Results'),
            ),
            TextButton(
              onPressed: () {
                Get.to(UserProfile(), transition: Transition.rightToLeft);
              },
              child: Text(
                'Settings',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      body: AllScreen(trips: widget.results, selectedCities: widget.selectedCities),
    );
  }
}

class AllScreen extends StatefulWidget {
  final List<Map<String, dynamic>> trips;
  final List<String> selectedCities;

  AllScreen({required this.trips, required this.selectedCities});

  @override
  _AllScreenState createState() => _AllScreenState();
}

class _AllScreenState extends State<AllScreen> {
  late List<Map<String, dynamic>> filteredTrips;

  @override
  void initState() {
    super.initState();
    _filterTrips();
  }

  void _filterTrips() {
    filteredTrips = widget.trips.where((trip) {
      String departureCity = trip['departure'] ?? '';
      String destinationCity = trip['destination'] ?? '';
      return widget.selectedCities.contains(departureCity) || widget.selectedCities.contains(destinationCity);
    }).toList();

    filteredTrips.sort((a, b) {
      DateTime dateA = DateTime.tryParse(a['leaving_date_time'] ?? '') ?? DateTime.now();
      DateTime dateB = DateTime.tryParse(b['leaving_date_time'] ?? '') ?? DateTime.now();
      return dateB.compareTo(dateA);
    });
  }

  Future<void> _refreshData() async {
    // Add your data fetching logic here
    // For example, you might fetch new results from a server
    // After fetching, make sure to call setState to update the UI
    // Here, I'll just simulate a refresh with a delay
    await Future.delayed(Duration(seconds: 1));

    // You can add logic to refetch trips if needed.
    setState(() {
      _filterTrips(); // Re-filter trips if necessary
    });
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('E, MMM d \'at\' h:mma');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 13),
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          itemCount: filteredTrips.length,
          itemBuilder: (context, index) {
            final trip = filteredTrips[index];
            String formattedDate = 'Date not available';

            String dateString = trip['leaving_date_time'] ?? '';
            if (dateString.isNotEmpty) {
              try {
                DateTime date = DateTime.parse(dateString);
                formattedDate = dateFormat.format(date);
              } catch (e) {
                print('Date parsing error: $e');
              }
            }

            int seatsLeft = trip['empty_seats'] ?? 0;
            String userName = trip['uname'] ?? 'Unknown';

            String departureCityFirstName = trip['departure']?.split(' ').first ?? 'Unknown';
            String destinationCityFirstName = trip['destination']?.split(' ').first ?? 'Unknown';

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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(trip['profile_photo'] ?? 'images/Userpfp.png'),
                            ),
                            SizedBox(width: 5),
                            const Icon(Icons.verified, color: Colors.blue),
                            SizedBox(width: 5),
                            Text(userName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Text('$seatsLeft seats left', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: departureCityFirstName, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              TextSpan(text: '  ${trip['departure'] ?? 'Unknown Departure'}', style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 13, left: 15),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: destinationCityFirstName, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              TextSpan(text: '  ${trip['destination'] ?? 'Unknown Destination'}', style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 13.0, left: 15),
                        child: Text(formattedDate, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
