// find screen with use of widget to search city

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel/Find/Driver/posttrip.dart';
import 'package:travel/Find/SearchResult/searchresult.dart';
import 'package:http/http.dart' as http;
import 'package:travel/Find/history.dart';
import 'package:travel/UserProfile/License/verifylicenese.dart';
import '../UserProfile/BookedRides/all_booked_rides.dart';
import '../UserProfile/vechiledetails.dart';
import '../widget/City_search.dart';
import '../widget/HttpHandler.dart';
import '../UserProfile/Userprofile.dart';
import '../api/api.dart';
import '../widget/configure.dart';
import 'Passenger/postrequest.dart';
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
  /*final VehicleDetailsController vehicleDetailsController =
      Get.find(); // Access your controller*/
  late HttpHandler hs;
  final _formKey = GlobalKey<FormState>();


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

  bool _isLoading = false; // Define a loading state
  bool isSearchLoading = false; // Loading state

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

  Future<void> _checkTripPostConditions() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token != null) {
      try {
        final vehicleResponse = await http.get(
          Uri.parse('${API.api1}/get-vehicle-data'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        final licenseResponse = await http.get(
          Uri.parse('${API.api1}/images'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        int? licenseStatus;
        if (licenseResponse.statusCode == 200) {
          final jsonResponse = json.decode(licenseResponse.body);
          licenseStatus = int.tryParse(jsonResponse['status'].toString());
        }

        bool vehicleDataFound = vehicleResponse.statusCode == 200;

        if (licenseStatus == 1 && vehicleDataFound) {
          Get.to(() => PostTrip());
        } else {
          _showStatusDialog(context, licenseStatus, vehicleDataFound);
        }
      } catch (e) {
        _showErrorDialog(
            context, 'Please check your connection and try again.');
      }
    } else {
      print('Auth token not found');
    }
    setState(() {
      _isLoading = false; // Stop loading
    });
  }

  void _showStatusDialog(
      BuildContext context, int? licenseStatus, bool vehicleDataFound) {
    String message = '';
    bool showLicenseAlert = licenseStatus != 1;
    bool showVehicleAlert = !vehicleDataFound;

    if (showLicenseAlert) {
      message += 'Your license is either not uploaded or under approval.\n';
    }

    if (showVehicleAlert) {
      message +=
          'You have not uploaded vehicle details. Please upload before posting a ride.\n';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Status Alert'),
          content: Text(message),
          actions: [
            if (showLicenseAlert)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.to(() => VerifyLicense());
                },
                child: Text('Go to License'),
              ),
            if (showVehicleAlert)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.to(() => VehicleDetails());
                },
                child: Text('Go to Vehicle Details'),
              ),
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

  @override
  void initState() {
    super.initState();
    departureController.addListener(updateEraseController);
    destinationController.addListener(updateEraseController);
    hs = HttpHandler(contx: context);
    chkDB();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  Future<void> _saveRecentSearches(List<String> recentSearches) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('recentSearches', recentSearches);
  }

  void _addNewSearch(String searchQuery) {
    setState(() {
      if (!recentSearches.contains(searchQuery)) {
        recentSearches.add(searchQuery);
        _saveRecentSearches(recentSearches);
      }
    });
  }

  void _removeSearch(int index) {
    setState(() {
      recentSearches.removeAt(index);
      _saveRecentSearches(recentSearches);
    });
  }

  void _clearAllSearches() {
    setState(() {
      recentSearches.clear();
      _saveRecentSearches(recentSearches);
    });
  }

  void chkDB() async {
    bool chki = await hs.InternetConnection(true);
    if (chki == false) {
      final res = Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Internet()),
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

    if (_formKey.currentState?.validate() ?? false)  {
      // Save the search to recent searches
      String searchQuery = "$departure To $destination on $date";
      if (!recentSearches.contains(searchQuery)) {
        setState(() {
          recentSearches.insert(0, searchQuery);
          if (recentSearches.length > 3) {
            recentSearches
                .removeLast(); // Maintain a maximum of 3 recent searches
          }
          _saveRecentSearches(
              recentSearches); // Save updated searches to shared preferences
        });
      }

      setState(() {
        isSearchLoading = true; // Start loading
      });

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
          print('Find trip data: ${response.body}');
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
      } finally {
        // Ensure loading state is reset
        setState(() {
          isSearchLoading = false; // Stop loading
        });

        // Clear input fields after search
        destinationController.clear();
        departureController.clear();
        dateController.clear();
      }
    }
  }

 /* Future<bool> _showExitPrompt() async {
    final result = await CustomDialog.show(
      context,
      title: 'Exit App',
      content: 'Are you sure you want to exit the app?',
      cancelButtonText: 'No',
      confirmButtonText: 'Yes',
      onConfirm: () {
        SystemNavigator.pop(); // Close the app
      },
    );
    // You can infer whether the user chose to exit based on your logic.
    // For example, if `onConfirm` is called, you can assume they want to exit.
    return true; // User confirmed exit
  }*/

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Form(
          key: _formKey,
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
                      Text(
                        'Find your desired trip by providing departure and destination locations.',
                        style: TextStyle(color: Colors.black54),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter departure';
                          }
                          return null;
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter destination';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                  Positioned(
                    right: 50,
                    top: 115,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF3d5a80),
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
              CustomTextField(
                controller: dateController,
                focusNode: dateFocusNode,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).unfocus();  // Or move to next focus
                },
                hintText: 'Departure date',
                prefixIcon: Icon(Icons.calendar_today),
                readOnly: true,
                onTap: () => _selectDate(context),  // Opens date picker
                suffixIcon: dateController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(FontAwesomeIcons.times),
                  onPressed: () {
                    dateController.clear();  // Clear the date field
                  },
                )
                    : null,  // No suffix icon if text is empty
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSearchLoading ? null : _performSearch,
                  child: isSearchLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Search',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3d5a80),
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
      ),
    /*        bottomNavigationBar: Container(
        color: Colors.white, // Background color of the bottom navigation bar
        height: kBottomNavigationBarHeight,
        child: Row(
          children: [
        Expanded(
        child: Tooltip(
        message: 'Post a trip as driver',
          child: InkWell(
            onTap: _checkTripPostConditions,
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
                message: 'Find Requests',
                child: InkWell(
                  onTap: () {
                    // Get.to(() => FindRequests());
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
            */ /*Expanded(
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
            ),*/ /*
          ],
        ),
      ),*/
      floatingActionButton: Align(
        child: Container(
          padding: EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 165,
                  child: ActionButton(
                    tootltipmessage: 'Booking history',
                    label: 'History',
                    icon: Icons.history,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => History()),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: 165,
                  child: ActionButton(
                    label: 'Add Request',
                    icon: Icons.add,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Postrequest()),
                      );
                    },
                  ),
                ),
/*
                SizedBox(
                  width: 165,
                  height: 50,
                  child: FloatingActionButton(
                    backgroundColor: kPrimaryColor,
                    onPressed: _checkTripPostConditions,
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center the content
                      children: [
                        if (!_isLoading)
                          Icon(
                            Icons.add,
                            color: Colors.white,
                          ), // Show the icon only if not loading
                        if (_isLoading)
                          SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 4,
                              )), // Show loading indicator when loading
                        if (!_isLoading) ...[
                          // Only show text if not loading
                          SizedBox(width: 5),
                          Text(
                            'Add ride',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
*/
              ],
            ),
          ),
        ),
      ),
    /*
        floatingActionButton: Container(
          width: 100,
          child: Tooltip(
            preferBelow: false,
            message: 'Booking history',
            child: Container(
              padding: EdgeInsets.only(top: 10),
              child: FloatingActionButton(
                backgroundColor: kPrimaryColor,
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BookedUserRides()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, color: Colors.white), // Your history icon
                    const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        'History',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
    */
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
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
    );
  }
}
