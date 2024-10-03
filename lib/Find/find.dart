// find screen with use of widget to search city

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel/Find/Inbox/Inbox.dart';
import 'package:travel/Trial/new.dart';
import 'package:travel/Find/Passenger/postrequest.dart';
import 'package:travel/Find/Driver/posttrip.dart';
import 'package:travel/Find/Inbox/receiveInbox.dart';
import 'package:travel/Find/SearchResult/searchresult.dart';
import 'package:http/http.dart' as http;
import 'package:travel/UserProfile/License/verifylicenese.dart';
import '../UserProfile/vechiledetails.dart';
import '../widget/City_search.dart';
import '../widget/HttpHandler.dart';
import '../UserProfile/Userprofile.dart';
import '../api/api.dart';
import 'Trips/TripsHome.dart';
import '../widget/internet.dart';
import 'notification.dart';

class FindScreen extends StatefulWidget {
  const FindScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<FindScreen> createState() => _FindScreenState();
}

class _FindScreenState extends State<FindScreen> {
  final VehicleDetailsController vehicleDetailsController =
      Get.find(); // Access your controller
  late HttpHandler hs;

  TextEditingController departureController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  FocusNode departureFocusNode = FocusNode();
  FocusNode destinationFocusNode = FocusNode();
  FocusNode dateFocusNode = FocusNode();
  bool showDepartureContainer = false;
  bool showDestinationContainer = false;
  List<dynamic> departureSuggestions = [];
  List<dynamic> destinationSuggestions = [];
  late TextEditingController
      activeController; // Keep track of the active controller

  List<String> recentSearches = []; // List to store recent searches

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        // Navigate to Trips screen
        Get.to(() => HomeScreen(initialIndex: 1));
      }
    });
  }

  // Fetch cities from API
  Future<List<dynamic>> fetchCities(String query) async {
    try {
      final response = await http
          .get(Uri.parse('${API.api1}/cities')); // Replace with your API URL

      if (response.statusCode == 200) {
        final List<dynamic> cities = json.decode(response.body);
        return cities.where((city) {
          final cityName = city['city']?.toLowerCase() ?? '';
          final provinceName = city['pname']?.toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          return cityName.contains(searchQuery) ||
              provinceName.contains(searchQuery);
        }).toList();
      } else {
        throw Exception('Failed to load cities: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cities: $e');
      return []; // Return an empty list in case of an error
    }
  }

  void _updateSuggestions(
      String pattern, TextEditingController controller) async {
    if (pattern.isNotEmpty) {
      setState(() {
        if (controller == departureController) {
          showDepartureContainer = true;
        } else if (controller == destinationController) {
          showDestinationContainer = true;
        }
      });
      try {
        if (controller == departureController) {
          departureSuggestions = await fetchCities(pattern);
        } else if (controller == destinationController) {
          destinationSuggestions = await fetchCities(pattern);
        }
        setState(() {}); // Update the UI with new suggestions
      } catch (e) {
        print('Error updating suggestions: $e');
      }
    } else {
      setState(() {
        if (controller == departureController) {
          showDepartureContainer = false;
        } else if (controller == destinationController) {
          showDestinationContainer = false;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    departureController.addListener(updateEraseController);
    destinationController.addListener(updateEraseController);
    hs = HttpHandler(ctx: context);
    chkDB();
  }

  void chkDB() async {
    bool chki = await hs.netconnection(true);
    if (chki == false) {
      final res = Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnInternet()),
          (Route<dynamic> route) => false);

      if (res != null && res.toString() == 'done') {
        chkDB();
        return;
      }
    }
  }

  @override
  void dispose() {
    departureController.removeListener(updateEraseController);
    destinationController.removeListener(updateEraseController);
    departureFocusNode.dispose();
    destinationFocusNode.dispose();
    dateFocusNode.dispose();
    super.dispose();
  }

  void updateEraseController() {
    setState(() {}); // Trigger rebuild to update clear icon visibility
  }

  void handleClearClick(TextEditingController controller) {
    setState(() {
      controller.clear();
    });
  }

  void _swapLocations() {
    setState(() {
      String temp = departureController.text;
      departureController.text = destinationController.text;
      destinationController.text = temp;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        dateController.text = picked.toString().split(" ")[0];
      });
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Input Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performSearch() async {
    String departure = departureController.text;
    String destination = destinationController.text;
    String date = dateController.text;

    if (departure.isEmpty && destination.isEmpty && date.isEmpty) {
      _showAlert('Please provide details.');
    } else if (departure.isEmpty) {
      _showAlert('Please enter departure location.');
    } else if (destination.isEmpty) {
      _showAlert('Please enter destination.');
    } else {
      // Save the search to recent searches
      String searchQuery = "$departure To $destination on $date";
      if (!recentSearches.contains(searchQuery)) {
        setState(() {
          recentSearches.insert(0, searchQuery); // Add to the top of the list
          if (recentSearches.length > 5) {
            recentSearches
                .removeLast(); // Maintain a maximum of 5 recent searches
          }
        });
      }

      // Perform API request with token
      try {
        // Retrieve token from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final authToken = prefs.getString('authToken') ?? '';

        if (authToken.isEmpty) {
          _showAlert('Authentication token not found.');
          return;
        }

        final response = await http.get(
          Uri.parse(
            '${API.api1}/find-trip?departure=$departure&destination=$destination&leaving_date=$date',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken', // Add the token here
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> resultsJson = json.decode(response.body);
          final List<Map<String, dynamic>> results =
              List<Map<String, dynamic>>.from(resultsJson);
          print('API called');
          if (results.isNotEmpty) {
            // Handle successful response and navigate to results page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchResult(
                  results: results, // Pass the results to SearchResult
                  selectedCities: [
                    departure,
                    destination
                  ], // Pass selected cities
                ),
              ),
            );
          } else {
            _showAlert('No trips found.');
          }
        } else if (response.statusCode == 404) {
          _showAlert('No trips found for provided locations.');
        } else {
          _showAlert('Error fetching data from the server.');
        }
      } catch (e) {
        print('An error occurred: $e');
        _showAlert('An error occurred.');
      }

      // Clear input fields after search
      destinationController.clear();
      departureController.clear();
      dateController.clear();
    }
  }

  Future<bool> _showExitPrompt() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App'),
            content: Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // Do not exit
                child: Text('No'),
              ),
              TextButton(
                onPressed: () {
                  SystemNavigator.pop(); // Close the app
                },
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false; // In case the user dismisses the dialog by tapping outside
  }

  void _selectRecentSearch(String search) {
    // The format is "Departure To Destination on Date"
    List<String> parts = search.split(
        ' on '); // Split the string into "Departure To Destination" and "Date"
    if (parts.length == 2) {
      String locationsPart = parts[0];
      String datePart = parts[1];

      List<String> locations =
          locationsPart.split(' To '); // Split the "Departure To Destination"
      if (locations.length == 2) {
        setState(() {
          departureController.text = locations[0]; // Set the departure location
          destinationController.text =
              locations[1]; // Set the destination location
          /* dateController.text = datePart;*/ // Set the date
        });
      }
    }
  }

  void _removeSearch(int index) {
    setState(() {
      recentSearches.removeAt(index);
    });
  }

  void _clearAllSearches() {
    setState(() {
      recentSearches.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _showExitPrompt,
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Tooltip(
              message: 'User details',
              child: Container(
                height: 40,
                width: 40,
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => UserProfile(),
                        transition: Transition.leftToRight);
                  },
                  child: Image.asset(
                    'images/blogo.png',
                  ),
                ),
              ),
            ),
          ),
          actions: [
            Tooltip(
              message: 'Notifications',
              child: IconButton(
                  onPressed: () {
                    Get.to(NotificationScreen());
                  },
                  icon: Icon(Icons.notifications_active)),
            ),
            SizedBox(width: 15),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find your ride!', // Use the user's name here
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CitySearchField(
                        controller: departureController,
                        focusNode: departureFocusNode,
                        hintText: 'Departure Location',
                        showSuggestions: showDepartureContainer,
                        suggestions: departureSuggestions,
                        onChanged: (value) {
                          activeController = departureController;
                          _updateSuggestions(value, departureController);
                        },
                        onSubmitted: (value) {
                          FocusScope.of(context)
                              .requestFocus(destinationFocusNode);
                        },
                        onClear: () => handleClearClick(departureController),
                        onSuggestionTap: (suggestion) {
                          departureController.text =
                              '${suggestion['city']}, ${suggestion['pname']}';
                          setState(() {
                            showDepartureContainer = false;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      CitySearchField(
                        controller: destinationController,
                        focusNode: destinationFocusNode,
                        hintText: 'Destination Location',
                        showSuggestions: showDestinationContainer,
                        suggestions: destinationSuggestions,
                        onChanged: (value) {
                          activeController = destinationController;
                          _updateSuggestions(value, destinationController);
                        },
                        onSubmitted: (value) {
                          FocusScope.of(context).requestFocus(dateFocusNode);
                        },
                        onClear: () => handleClearClick(destinationController),
                        onSuggestionTap: (suggestion) {
                          destinationController.text =
                              '${suggestion['city']}, ${suggestion['pname']}';
                          setState(() {
                            showDestinationContainer = false;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                  Positioned(
                    right: 50,
                    top: 75,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF2d7af7),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.arrowsUpDown,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _swapLocations,
                      ),
                    ),
                  ),
                ],
              ),
              buildDateTextField(),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _performSearch,
                  child: Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2d7af7),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (recentSearches.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Searches:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: _clearAllSearches,
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: recentSearches.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(recentSearches[index]),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete,
                        ),
                        onPressed: () => _removeSearch(index),
                      ),
                      onTap: () => _selectRecentSearch(recentSearches[index]),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.white, // Background color of the bottom navigation bar
          height: kBottomNavigationBarHeight,
          child: Row(
            children: [
              Expanded(
                child: Tooltip(
                  message: 'Post a trip as driver',
                  child: InkWell(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('authToken');

                      if (token != null) {
                        try {
                          // Fetch vehicle data
                          final vehicleResponse = await http.get(
                            Uri.parse('${API.api1}/get-vehicle-data'),
                            headers: {
                              'Authorization': 'Bearer $token',
                            },
                          );

                          // Fetch license response
                          final licenseResponse = await http.get(
                            Uri.parse('${API.api1}/images'),
                            headers: {
                              'Authorization': 'Bearer $token',
                            },
                          );

                          int? licenseStatus;
                          if (licenseResponse.statusCode == 200) {
                            final jsonResponse =
                                json.decode(licenseResponse.body);
                            licenseStatus =
                                int.tryParse(jsonResponse['status'].toString());
                            print(
                                'Retrieved license status: $licenseStatus'); // Debugging
                          }

                          if (vehicleResponse.statusCode == 200) {
                            final vehicleData =
                                json.decode(vehicleResponse.body);
                            var vehicleStatus =
                                vehicleData['vehicles'][0]['status'];
                            print(
                                'Retrieved vehicle status: $vehicleStatus'); // Debugging

                            // Check both statuses before navigating
                            if (licenseStatus == 1 && vehicleStatus == 1) {
                              Get.to(() => PostTrip());
                            } else {
                              _showStatusDialog(
                                  context, licenseStatus, vehicleStatus);
                            }
                          } else {
                            // Call the new error handling method for vehicle data not found
                            _showVehicleDataErrorDialog(context);
                          }
                        } catch (e) {
                          print('Error: $e');
                          _showErrorDialog(
                              context, 'An error occurred. Please try again.');
                        }
                      } else {
                        print('Auth token not found');
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.directions_car, size: 20),
                        Text('Driver', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                child: VerticalDivider(
                  width: 1,
                  color: Colors.grey, // Color of the divider
                ),
              ),
              Expanded(
                child: Tooltip(
                  message: 'Inbox',
                  child: InkWell(
                    onTap: () {
                      Get.to(() => InboxList()); // Navigate to HomeScreen
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 20,
                        ),
                        Text(
                          'Inbox',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                child: VerticalDivider(
                  width: 1,
                  color: Colors.grey, // Color of the divider
                ),
              ),
              Expanded(
                child: Tooltip(
                  message: 'Requests details',
                  child: InkWell(
                    onTap: () {
                      _onItemTapped(1); // Set index for Trips screen
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trip_origin,
                          size: 20,
                        ),
                        Text(
                          'Requests',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                child: VerticalDivider(
                  width: 1,
                  color: Colors.grey, // Color of the divider
                ),
              ),
              Expanded(
                child: Tooltip(
                  message: 'Reqeust a trip',
                  child: InkWell(
                    onTap: () {
                      Get.to(() => Postrequest());
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person,
                          size: 20,
                        ),
                        Text(
                          'Passenger',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
  }) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            filled: true,
            prefixIcon: Icon(Icons.location_on),
            hintText: hintText,
            suffixIcon: Visibility(
              visible: controller.text.isNotEmpty,
              child: IconButton(
                icon: FaIcon(FontAwesomeIcons.times),
                onPressed: () => handleClearClick(controller),
              ),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onEditingComplete: () {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            }
          },
        ),
      ],
    );
  }

  Widget buildDateTextField() {
    return TextField(
      controller: dateController,
      focusNode: dateFocusNode,
      decoration: InputDecoration(
        hintText: 'Departure date',
        filled: true,
        prefixIcon: Icon(Icons.calendar_today),
        suffixIcon: dateController.text.isNotEmpty
            ? IconButton(
                icon: Icon(FontAwesomeIcons.times),
                onPressed: () {
                  setState(() {
                    dateController.clear();
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
    );
  }
}

void _showStatusDialog(
    BuildContext context, int? licenseStatus, int vehicleStatus) {
  String message = 'Check your license.\n';
  bool showLicenseAlert = licenseStatus != 1;

  if (showLicenseAlert) {
    message +=
        'You have not uploaded your license or your license is under approval. Please recheck it before posting a trip.\n';
  }

  // Show dialog with redirection options based on status
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('License Alert'),
        content: Text(message),
        actions: [
          if (showLicenseAlert)
            Column(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog before navigation
                    Get.to(() =>
                        VerifyLicense()); // Replace with your License screen
                  },
                  child: Text('Go to License'),
                ),
              ],
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}

void _showVehicleDataErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Upload details'),
        content: Text(
            'You have not uploaded vehicle details. Please upload before posting a ride.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog before navigation
              Get.to(() =>
                  VehicleDetails()); // Replace with your Vehicle Details screen
            },
            child: Text('Upload Details'),
          ),
        ],
      );
    },
  );
}

void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}
