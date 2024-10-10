import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widget/configure.dart';
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
  bool _morningSelected = false;
  bool _afternoonSelected = false;
  bool _eveningSelected = false;
  List<Map<String, dynamic>> filteredTrips = []; // Initialize as an empty list

  @override
  void initState() {
    super.initState();
    filteredTrips = widget.results; // Initially show all results
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Filter by Time of Day", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  CheckboxListTile(
                    title: Text("Morning"),
                    value: _morningSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        _morningSelected = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text("Afternoon"),
                    value: _afternoonSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        _afternoonSelected = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text("Evening"),
                    value: _eveningSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        _eveningSelected = value ?? false;
                      });
                    },
                  ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ()  {
                  Navigator.pop(context);
                  _filterTrips(); // Re-filter the trips based on selected time
                },
                child: Text('Apply filters'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _filterTrips() {
    setState(() {
      if (!_morningSelected && !_afternoonSelected && !_eveningSelected) {
        // If no filters are selected, show all results
        filteredTrips = widget.results;
      } else {
        filteredTrips = widget.results.where((trip) {
          String departureCity = trip['departure'] ?? '';
          String destinationCity = trip['destination'] ?? '';
          bool isInSelectedCities = widget.selectedCities.contains(departureCity) || widget.selectedCities.contains(destinationCity);

          if (!isInSelectedCities) return false;

          DateTime dateTime = DateTime.parse(trip['leaving_date_time'] ?? DateTime.now().toString());

          if (_morningSelected && dateTime.hour < 12) return true;
          if (_afternoonSelected && dateTime.hour >= 12 && dateTime.hour < 17) return true;
          if (_eveningSelected && dateTime.hour >= 17) return true;

          return false;
        }).toList();
      }

      filteredTrips.sort((a, b) {
        DateTime dateA = DateTime.tryParse(a['leaving_date_time'] ?? '') ?? DateTime.now();
        DateTime dateB = DateTime.tryParse(b['leaving_date_time'] ?? '') ?? DateTime.now();
        return dateB.compareTo(dateA);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('E, MMM d \'at\' h:mma');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Search Results'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              onPressed: _showFilterBottomSheet,
              icon: Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 13),
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
