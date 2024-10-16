import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel/Find/Passenger/all_posted_requests.dart';
import 'package:travel/Find/Passenger/postrequest.dart';
import 'package:travel/Find/Passenger/requestresult.dart';
import '../../api/api.dart';
import '../../widget/City_search.dart';
import '../../widget/HttpHandler.dart';
import '../../widget/configure.dart';
import '../../widget/internet.dart';
import '../SearchResult/searchresult.dart';
import '../Trips/TripsHome.dart';

class FindRequests extends StatefulWidget {
  const FindRequests({super.key});

  @override
  State<FindRequests> createState() => _FindRequestsState();
}

class _FindRequestsState extends State<FindRequests> {

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
            '${API.api1}/find_requests?from_location=$departure&to_location=$destination&departure_date=$date',
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
          print('date : $date');
          print('API called');
          print('Find request data:${response.body}');
          if (results.isNotEmpty) {
            // Handle successful response and navigate to results page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RequestResult(
                  results: results, // Pass the results to SearchResult
                  selectedCities: [
                    departure,
                    destination,
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric( horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20,),
                    Text(
                      'Find requests!', // Use the user's name here
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Find requests of person by entering locations of departure and destination.',style: TextStyle(color: Colors.black54),),
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
                  top: 145,
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
            buildDateTextField(),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _performSearch,
                child: Text(
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
/*      bottomNavigationBar: Container(
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
                    Get.to(() => FindRequests());
                    // _onItemTapped(1); // Set index for Trips screen
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
      )*/
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
                label: 'History',
                icon: Icons.history,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RequestHistory()),
                  );
                },
              ),
            ),
                SizedBox(height: 10,),

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
              ],
            ),
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

