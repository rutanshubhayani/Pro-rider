import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel/UserProfile/Userprofile.dart';

class RequestResult extends StatefulWidget {
  final List<Map<String, dynamic>> results;
  final List<String> selectedCities;
  final DateTime? selectedDate; // Optional date parameter

  RequestResult({
    Key? key,
    required this.results,
    required this.selectedCities,
    this.selectedDate, // Initialize optional date parameter
  }) : super(key: key);

  @override
  State<RequestResult> createState() => _RequestResultState();
}

class _RequestResultState extends State<RequestResult> {
  late List<Map<String, dynamic>> filteredTrips;

  @override
  void initState() {
    super.initState();
    _filterTrips();
  }

  void _filterTrips() {
    filteredTrips = widget.results.where((trip) {
      String fromLocation = trip['from_location'] ?? '';
      String toLocation = trip['to_location'] ?? '';
      bool cityMatches = widget.selectedCities.contains(fromLocation) ||
          widget.selectedCities.contains(toLocation);

      // Check if selected date is provided and matches the trip's departure date
      bool dateMatches = widget.selectedDate == null ||
          (trip['departure_date'] != null &&
              DateTime.parse(trip['departure_date']).isAtSameMomentAs(widget.selectedDate!));

      return cityMatches && dateMatches; // Return true only if both match
    }).toList();

    // Sort the filtered trips by departure date
    filteredTrips.sort((a, b) {
      DateTime dateA = DateTime.tryParse(a['departure_date'] ?? '') ?? DateTime.now();
      DateTime dateB = DateTime.tryParse(b['departure_date'] ?? '') ?? DateTime.now();
      return dateA.compareTo(dateB);
    });
  }

  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _filterTrips(); // Re-filter trips if necessary
    });
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('E, MMM d \'at\' h:mma');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Text('Request Results'),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 13),
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            itemCount: filteredTrips.length,
            itemBuilder: (context, index) {
              final trip = filteredTrips[index];
              String formattedDate = 'Date not available';

              String dateString = trip['departure_date'] ?? '';
              if (dateString.isNotEmpty) {
                try {
                  DateTime date = DateTime.parse(dateString);
                  formattedDate = dateFormat.format(date);
                } catch (e) {
                  print('Date parsing error: $e');
                }
              }

              int seatsRequired = trip['seats_required'] ?? 0;
              String userName = trip['uname'] ?? 'Unknown';

              String fromLocationFirstName = trip['from_location']?.split(' ').first ?? 'Unknown';
              String toLocationFirstName = trip['to_location']?.split(' ').first ?? 'Unknown';

              return GestureDetector(
                onTap: () {
                  // Handle tap if necessary
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
                                child: Text('$seatsRequired seats required', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: fromLocationFirstName, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                TextSpan(text: '  ${trip['from_location'] ?? 'Unknown Departure'}', style: TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 13, left: 15),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: toLocationFirstName, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                TextSpan(text: '  ${trip['to_location'] ?? 'Unknown Destination'}', style: TextStyle(color: Colors.black54)),
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
      ),
    );
  }
}
