import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:travel/Inbox.dart';
import 'package:travel/postrequest.dart';
import 'package:travel/posttrip.dart';
import 'package:travel/searchresult.dart';
import 'package:http/http.dart' as http;
import 'Userprofile.dart';
import 'api.dart';
import 'home.dart';
import 'notification.dart';

class FindScreen extends StatefulWidget {
  final String userName; // Add userName parameter
  final String usermail; // Usermail passed from the previous screen
  final String unumber; // Usermail passed from the previous screen
  final String uaddress; // Usermail passed from the previous screen


  const FindScreen({Key? key, required this.userName,required this.usermail, required this.unumber, required this.uaddress}) : super(key: key);

  @override
  State<FindScreen> createState() => _FindScreenState();
}

class _FindScreenState extends State<FindScreen> {
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
  late TextEditingController activeController; // Keep track of the active controller

  List<String> recentSearches = []; // List to store recent searches

  int _selectedIndex = 0;

  get username => widget.userName;
  get usermail => widget.usermail;
  get unumber => widget.unumber ;
  get uaddress => widget.uaddress ;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) { // Navigate to Trips screen
        Get.to(() => HomeScreen(initialIndex: 1));
      }
    });
  }

  // Fetch cities from API
  Future<List<dynamic>> fetchCities(String query) async {
    try {
      final response = await http.get(Uri.parse('${API.api1}/cities')); // Replace with your API URL

      if (response.statusCode == 200) {
        final List<dynamic> cities = json.decode(response.body);
        return cities.where((city) {
          final cityName = city['city']?.toLowerCase() ?? '';
          final provinceName = city['pname']?.toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          return cityName.contains(searchQuery) || provinceName.contains(searchQuery);
        }).toList();
      } else {
        throw Exception('Failed to load cities: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cities: $e');
      return []; // Return an empty list in case of an error
    }
  }

  void _updateSuggestions(String pattern, TextEditingController controller) async {
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
    } else if (destination.isEmpty && date.isEmpty) {
      _showAlert('Please enter destination and date.');
    } else if (destination.isEmpty) {
      _showAlert('Please enter destination.');
    } else if (date.isEmpty) {
      _showAlert('Please enter date.');
    } else {
      // Save the search to recent searches
      String searchQuery = "$departure To $destination on $date";
      if (!recentSearches.contains(searchQuery)) {
        setState(() {
          recentSearches.insert(0, searchQuery); // Add to the top of the list
          if (recentSearches.length > 5) {
            recentSearches.removeLast(); // Maintain a maximum of 5 recent searches
          }
        });
      }

      // Perform API request
      try {
        final response = await http.get(Uri.parse(
            '${API.api1}/find-trip?departure=$departure&destination=$destination&leaving_date=$date'));

        if (response.statusCode == 200) {
          final List<dynamic> resultsJson = json.decode(response.body);
          final List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(resultsJson);
          print('API called');
          if (results.isNotEmpty) {
            // Handle successful response and navigate to results page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchResult(
                  results: results, // Pass the results to SearchResult
                  selectedCities: [departure, destination], // Pass selected cities
                ),
              ),
            );
          } else {
            _showAlert('No trips found.');
          }
        } else if (response.statusCode == 404) {
          _showAlert('No trips found for the specified query.');
        } else {
          _showAlert('Error fetching data from the server. Status code: ${response.statusCode}');
        }
      } catch (e) {
        _showAlert('An error occurred: $e');
      }

      // Clear input fields after search
      destinationController.clear();
      departureController.clear();
      dateController.clear();
    }
  }






  void _selectRecentSearch(String search) {
    // The format is "Departure To Destination on Date"
    List<String> parts = search.split(' on '); // Split the string into "Departure To Destination" and "Date"
    if (parts.length == 2) {
      String locationsPart = parts[0];
      String datePart = parts[1];

      List<String> locations = locationsPart.split(' To '); // Split the "Departure To Destination"
      if (locations.length == 2) {
        setState(() {
          departureController.text = locations[0]; // Set the departure location
          destinationController.text = locations[1]; // Set the destination location
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
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Container(
            height: 40,
            width: 40,
            child: GestureDetector(
              onTap: () {
                Get.to(() => UserProfile(userName1: username, usermail: usermail, unumber: unumber,uaddress: uaddress,),transition: Transition.leftToRight);
              },
              child: Image.asset(
                'images/blogo.png',
              ),
            ),
          ),
        ),
        actions: [
          IconButton(onPressed: (){
            Get.to(NotificationScreen());
          },
              icon:Icon(Icons.notifications_active)),
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
                    Text('Welcome, ${widget.userName}', // Use the user's name here
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),),
                    SizedBox(height: 10,),
                    TextFormField(
                      controller: departureController,
                      focusNode: departureFocusNode,
                      decoration: InputDecoration(
                        filled: true,
                        prefixIcon: Icon(Icons.location_on),
                        hintText: 'Departure Location',
                        suffixIcon: departureController.text.isNotEmpty
                            ? IconButton(
                          icon: FaIcon(FontAwesomeIcons.times),
                          onPressed: () => handleClearClick(departureController),
                        )
                            : null, // Only show the clear icon if there's text in the field
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (value) {
                        activeController = departureController;
                        _updateSuggestions(value, departureController);
                      },
                      onFieldSubmitted: (value){
                        FocusScope.of(context).requestFocus(destinationFocusNode);
                      },
                    ),
                    if (showDepartureContainer)
                      Card(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: departureSuggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = departureSuggestions[index];
                            return ListTile(
                              leading: Icon(Icons.location_on),
                              title: Text('${suggestion['city']}, ${suggestion['pname']}'),
                              onTap: () {
                                departureController.text = '${suggestion['city']}, ${suggestion['pname']}';
                                setState(() {
                                  showDepartureContainer = false; // Hide the suggestions after selection
                                });
                              },
                            );
                          },
                        ),
                      ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: destinationController,
                      focusNode: destinationFocusNode,
                      decoration: InputDecoration(
                        filled: true,
                        prefixIcon: const Icon(Icons.location_on),
                        hintText: 'Destination Location',
                        suffixIcon: destinationController.text.isNotEmpty
                            ? IconButton(
                          icon: FaIcon(FontAwesomeIcons.times),
                          onPressed: () => handleClearClick(destinationController),
                        )
                            : null, // Only show the clear icon if there's text in the field
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (value) {
                        activeController = destinationController;
                        _updateSuggestions(value, destinationController);
                      },
                      onFieldSubmitted: (value){
                        FocusScope.of(context).requestFocus(dateFocusNode);
                      },
                    ),
                    if (showDestinationContainer)
                   Card(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: destinationSuggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = destinationSuggestions[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text('${suggestion['city']}, ${suggestion['pname']}'),
                            onTap: () {
                              destinationController.text = '${suggestion['city']}, ${suggestion['pname']}';
                              setState(() {
                                showDestinationContainer = false; // Hide the suggestions after selection
                              });
                            },
                          );
                        },
                      ),
                    ),
                   /* buildTextField(
                      controller: destinationController,
                      hintText: 'Destination Location',
                      focusNode: destinationFocusNode,
                      nextFocusNode: dateFocusNode,
                    ),*/
                  ],
                ),
                Positioned(
                  right: 50,
                  top: 75,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
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
            SizedBox(height: 15),
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
                  backgroundColor: Color(0xFF2e2c2f),
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
                      icon: Icon(Icons.delete,),
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
              child: InkWell(
                onTap: () {
                  Get.to(() => PostTrip()); // Navigate to HomeScreen
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_car,size: 20,),
                    Text('Driver',style: TextStyle(fontSize: 14),),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0,bottom: 15),
              child: VerticalDivider(
                width: 1,
                color: Colors.grey, // Color of the divider
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.to(() => Inbox1()); // Navigate to HomeScreen
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox,size: 20,),
                    Text('Inbox',style: TextStyle(fontSize: 14),),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0,bottom: 15),
              child: VerticalDivider(
                width: 1,
                color: Colors.grey, // Color of the divider
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  _onItemTapped(1); // Set index for Trips screen
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trip_origin,size: 20,),
                    Text('Trips',style: TextStyle(fontSize: 14),),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0,bottom: 15),
              child: VerticalDivider(
                width: 1,
                color: Colors.grey, // Color of the divider
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.to(Postrequest());
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person,size: 20,),
                    Text('Passenger',style: TextStyle(fontSize: 14),),
                  ],
                ),
              ),
            ),
          ],
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
