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
  bool _earlyMorningSelected = false;
  bool _morningSelected = false;
  bool _afternoonSelected = false;
  bool _eveningSelected = false;

  List<Map<String, dynamic>> filteredTrips = [];
  int _loadedTripCount = 5; // Initial count of loaded trips
  final int _increment = 5; // Number of trips to load on scroll
  ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false; // Loading state for more trips


  @override
  void initState() {
    super.initState();
    print('Initial results count: ${widget.results.length}');
    filteredTrips = widget.results.take(_loadedTripCount).toList(); // Load initial trips

  // Add a listener to the scroll controller
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
        print("Scrolled to bottom, loading more trips...");
        _loadMoreTrips(); // Load more trips when reaching the bottom
      }
    });
  }

  Future<void> _loadMoreTrips() async {
    print("Attempting to load more trips...");

    if (_isLoadingMore || filteredTrips.length >= widget.results.length) {
      print("Already loading or no more trips to load.");
      return;
    }

    setState(() {
      _isLoadingMore = true; // Start loading
    });

    // Simulate a delay for loading more trips
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _loadedTripCount = (_loadedTripCount + _increment).clamp(0, widget.results.length);
      filteredTrips = widget.results.take(_loadedTripCount).toList(); // Update filtered trips
      _isLoadingMore = false; // Stop loading
    });

    print('Loaded trips: ${filteredTrips.length}');
    print('Loaded trip count: $_loadedTripCount');
    print('Total available trips: ${widget.results.length}');
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
                    title: Text("Early Morning"),
                    value: _earlyMorningSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        _earlyMorningSelected = value ?? false;
                      });
                    },
                  ),
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
                      onPressed: () {
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
                  ),
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
      if (!_earlyMorningSelected && !_morningSelected && !_afternoonSelected && !_eveningSelected) {
        filteredTrips = widget.results;
      } else {
        filteredTrips = widget.results.where((trip) {
          String departureCity = trip['departure'] ?? '';
          String destinationCity = trip['destination'] ?? '';
          bool isInSelectedCities = widget.selectedCities.contains(departureCity) || widget.selectedCities.contains(destinationCity);

          if (!isInSelectedCities) return false;

          DateTime dateTime = DateTime.parse(trip['leaving_date_time'] ?? DateTime.now().toString());

          if (_earlyMorningSelected && dateTime.hour >= 0 && dateTime.hour < 6) return true;
          if (_morningSelected && dateTime.hour >= 6 && dateTime.hour < 12) return true;
          if (_afternoonSelected && dateTime.hour >= 12 && dateTime.hour < 18) return true;
          if (_eveningSelected && dateTime.hour >= 18 && dateTime.hour < 24) return true;

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

  Future<void> _refreshTrips() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      filteredTrips = widget.results; // Reset trips on refresh
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose of the scroll controller
    super.dispose();
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
      body: RefreshIndicator(
        onRefresh: _refreshTrips,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 13),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: filteredTrips.length + (_isLoadingMore ? 1 : 0), // Add one for loading indicator
            itemBuilder: (context, index) {
              if (index < filteredTrips.length) {
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
                int stopCount = (trip['stops'] as List).length; // Count the stops

// Display the number of stops
                String stopsText;
                if (stopCount == 0) {
                  stopsText = 'No stops';
                } else {
                  stopsText = '$stopCount stop${stopCount != 1 ? 's' : ''}';
                }

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
                    elevation: 5,
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(trip['profile_photo'] ?? 'images/Userpfp.png'),
                                ),
                                SizedBox(width: 5),
                                const Icon(Icons.verified, color: Colors.blue,size: 20,),
                                SizedBox(width: 5),
                                Expanded(child: Text(userName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                                Spacer(),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Text('$seatsLeft seats left', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
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
                            child: Row(
                              children: [
                                Text(formattedDate, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(width: 10,),
                                Text('-  ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold
                                ),),
                            Text('$stopsText', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),                     ],       ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (_isLoadingMore) {
                // Loading indicator
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: CircularProgressIndicator(), // Show loading indicator
                  ),
                );
              } else {
                // Optionally handle the case where no more items are loading
                return SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }
}
