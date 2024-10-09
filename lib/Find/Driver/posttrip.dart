import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel/Find/Trips/TripsHome.dart';
import 'package:travel/Find/find.dart';
import 'package:travel/UserProfile/PostedRides/all_posted_rides.dart';
import 'package:travel/api/api.dart';
import 'package:travel/Find/SearchResult/searchresult.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widget/City_search.dart';
import '../../widget/configure.dart';

class PostTrip extends StatefulWidget {
  @override
  State<PostTrip> createState() => _PostTripState();
}

class _PostTripState extends State<PostTrip> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController departureController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController stopsController = TextEditingController();
  bool showDepartureContainer = false;
  bool showDestinationContainer = false;
  bool showStopsContainer = false;
  List<dynamic> departureSuggestions = [];
  List<dynamic> destinationSuggestions = [];
  List<dynamic> stopsSuggestions = [];
  late TextEditingController
      activeController; // Keep track of the active controller
  TextEditingController spriceController = TextEditingController();
  TextEditingController dpriceController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController licenseController = TextEditingController();
  FocusNode departureFocusNode = FocusNode();
  FocusNode destinationFocusNode = FocusNode();
  FocusNode dpriceFocusNode = FocusNode();
  FocusNode stopsFocusNode = FocusNode();
  FocusNode spriceFocusNode = FocusNode();
  List<Map<String, String>> stopsAndPrices = [];
  FocusNode dateFocusNode = FocusNode();
  FocusNode timeFocusNode = FocusNode();
  FocusNode modelFocusNode = FocusNode();
  FocusNode licenseFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();
  TimeOfDay? selectedTime;
  List<bool> isSelectedTrip = [true, false];
  List<bool> isSelectedPeople = [true, false];
  List<bool> isSelected1 = [true, false, false];
  List<String> choices = ['Winter tires', 'Bikes', 'Skis & snowboards', 'Pets'];
  List<IconData> icons = [
    Icons.ac_unit,
    Icons.directions_bike,
    Icons.downhill_skiing,
    Icons.pets
  ];
  List<bool> isSelected2 = [false, false, false, false];
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  int _selectedChoice = 1;
  int selectedSeats = 1;
  bool _isChecked = false;

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchVehicleData();
    // Add a listener to the scroll controller
    _scrollController.addListener(() {
      setState(() {
        _isScrolled =
            _scrollController.offset > 100; // Adjust the offset as needed
      });
    });
  }

  Future<void> fetchVehicleData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      print('No authentication token found');
      return;
    }

    final response = await http.get(
      Uri.parse('${API.api1}/get-vehicle-data'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['vehicles'] != null && data['vehicles'].isNotEmpty) {
        final licensePlate = data['vehicles'][0]['licence_plate'];
        setState(() {
          licenseController.text = licensePlate;
        });
      } else {
        print('No vehicle data found');
      }
    } else {
      print('Failed to fetch vehicle data: ${response.statusCode}');
    }
  }

  Future<void> _postTrip() async {
    if (_formKey.currentState?.validate() ?? false) {
      final url = Uri.parse('${API.api1}/post-a-trip');

      final Map<String, dynamic> body = {
        'departure': departureController.text,
        'destination': destinationController.text,
        'price': dpriceController.text,
        'ride_schedule': isSelectedTrip[0] ? 'One-time trip' : 'Recurring trip',
        'leaving_date_time': '${dateController.text} ${timeController.text}',
        'luggage': isSelected1.indexWhere((element) => element),
        // 'back_row_sitting': isSelectedPeople[0] ? 'Max 2 people' : '3 people',
        /*'other_items': choices
            .asMap()
            .entries
            .where((entry) => isSelected2[entry.key])
            .map((entry) => entry.value)
            .join(', '),*/
        'empty_seats': selectedSeats,
        'description': descriptionController.text,
        'stops': stopsAndPrices
            .map((stopAndPrice) => {
                  'name': stopAndPrice['stop'],
                  'price': stopAndPrice['price'],
                })
            .toList(),
      };

      print('Sending data: $body');

      try {
        // Retrieve the token from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final authToken = prefs.getString('authToken');

        final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            if (authToken != null) 'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Trip posted successfully!')),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => FindScreen()),
            (route) => false,
          );

          // Navigate to search results or another page if needed
        } else {
          print('Failed to post trip: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to post trip.')),
          );
        }
      } catch (e) {
        print('Error: $e');
        _showErrorSnackbar('An error occurred. Please try again.');
      }
    } else {
      _focusFirstEmptyField();
    }
  }

  void _showErrorSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor:
          Colors.red, // Set the background color to red to indicate an error
      behavior: SnackBarBehavior.floating, // Make the snackbar float
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
        } else if (controller == stopsController) {
          showStopsContainer = true;
        }
      });
      try {
        if (controller == departureController) {
          departureSuggestions = await fetchCities(pattern);
        } else if (controller == destinationController) {
          destinationSuggestions = await fetchCities(pattern);
        } else if (controller == stopsController) {
          stopsSuggestions = await fetchCities(pattern);
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
        } else if (controller == stopsController) {
          showStopsContainer = false;
        }
      });
    }
  }

  void handleClearClick(TextEditingController controller) {
    setState(() {
      controller.clear();
    });
  }

  void addStopAndPrice() {
    final stop = stopsController.text;
    // final price = spriceController.text;

    if (stop.isNotEmpty /*&& price.isNotEmpty*/) {
      setState(() {
        stopsAndPrices.add({
          'stop': stop,
          // 'price': '',
        });
      });

      // Clear the input fields
      stopsController.clear();
      // spriceController.clear();
      FocusScope.of(context).requestFocus(stopsFocusNode);
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        timeController.text = pickedTime.format(context);
      });
    }
  }

  @override
  void dispose() {
    departureFocusNode.dispose();
    destinationFocusNode.dispose();
    dpriceFocusNode.dispose();
    stopsFocusNode.dispose();
    spriceFocusNode.dispose();
    dateFocusNode.dispose();
    timeFocusNode.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Post a trip'),
        /* actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PostedUserRides()));
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 20,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      'History',
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ],
                )),
          )
        ],*/
      ),
      body: Material(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0, left: 16, right: 16),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0, left: 3),
                        child: Text(
                          'Find your travel partner!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 5, left: 3.0, bottom: 10),
                        child: Text(
                          'Enter your departure, destination, and stops you are taking along the way',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 3.0, bottom: 7),
                        child: Text(
                          'Departure',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter departure';
                          }
                          return null;
                        },
                        onSuggestionTap: (suggestion) {
                          departureController.text =
                              '${suggestion['city']}, ${suggestion['pname']}';
                          setState(() {
                            showDepartureContainer = false;
                          });
                        },
                      ),
                      SizedBox(height: 25),
                      const Padding(
                        padding: EdgeInsets.only(left: 3.0, bottom: 7),
                        child: Text(
                          'Destination',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: destinationController,
                              focusNode: destinationFocusNode,
                              decoration: InputDecoration(
                                filled: true,
                                prefixIcon: Icon(Icons.location_on),
                                hintText: 'Destination Location',
                                suffixIcon: destinationController
                                        .text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.close_rounded),
                                        onPressed: () => handleClearClick(
                                            destinationController),
                                      )
                                    : null, // Only show the clear icon if there's text in the field
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (value) {
                                FocusScope.of(context)
                                    .requestFocus(dpriceFocusNode);
                              },
                              onChanged: (value) {
                                _updateSuggestions(
                                    value, destinationController);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter destination';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              focusNode: dpriceFocusNode,
                              controller: dpriceController,
                              decoration: InputDecoration(
                                filled: true,
                                hintText: 'Enter price',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter price';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(stopsFocusNode);
                              },
                            ),
                          ),
                        ],
                      ),
                      // Container for suggestions
                      if (showDestinationContainer)
                        Card(
                          elevation: 4,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics:
                                NeverScrollableScrollPhysics(), // Prevent scrolling within the Container
                            itemCount: destinationSuggestions.length,
                            itemBuilder: (context, index) {
                              final suggestion = destinationSuggestions[index];
                              return ListTile(
                                leading: Icon(Icons.location_on),
                                title: Text(
                                    '${suggestion['city']}, ${suggestion['pname']}'),
                                onTap: () {
                                  destinationController.text =
                                      '${suggestion['city']}, ${suggestion['pname']}';
                                  setState(() {
                                    showDestinationContainer =
                                        false; // Hide the suggestions after selection
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      SizedBox(height: 20),
                      Divider(
                        height: 4,
                        thickness: 1,
                        color: Colors.black26,
                      ),
                      SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.only(left: 3.0, bottom: 7),
                        child: Text(
                          'Stops',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: stopsController,
                                  focusNode: stopsFocusNode,
                                  decoration: InputDecoration(
                                    filled: true,
                                    prefixIcon:
                                        Icon(Icons.add_location_alt_sharp),
                                    hintText: 'Stops Location',
                                    suffixIcon: stopsController.text.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(Icons.close_rounded),
                                            onPressed: () => handleClearClick(
                                                stopsController),
                                          )
                                        : null, // Only show the clear icon if there's text in the field
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(spriceFocusNode);
                                  },
                                  onChanged: (value) {
                                    _updateSuggestions(value, stopsController);
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                             /* Expanded(
                                child: TextFormField(
                                  focusNode: spriceFocusNode,
                                  controller: spriceController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    hintText: 'Enter price',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context)
                                        .requestFocus(dateFocusNode);
                                  },
                                ),
                              ),*/
                            ],
                          ),
                          // Container for suggestions
                          if (showStopsContainer)
                            Card(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics:
                                    NeverScrollableScrollPhysics(), // Prevent scrolling within the Container
                                itemCount: stopsSuggestions.length,
                                itemBuilder: (context, index) {
                                  final suggestion = stopsSuggestions[index];
                                  return ListTile(
                                    leading: Icon(Icons.location_on),
                                    title: Text(
                                        '${suggestion['city']}, ${suggestion['pname']}'),
                                    onTap: () {
                                      stopsController.text =
                                          '${suggestion['city']}, ${suggestion['pname']}';
                                      setState(() {
                                        showStopsContainer =
                                            false; // Hide the suggestions after selection
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: stopsController.text
                                    .isNotEmpty // Check if there's text in the field
                                ? ElevatedButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              12.0), // Adjust the radius as needed
                                        ),
                                      ),
                                      elevation: MaterialStateProperty.all(
                                          5.0), // Adjust the elevation as needed
                                    ),
                                    onPressed: addStopAndPrice,
                                    child: Text(
                                      'Add',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  )
                                : Container(), // Return an empty container if there's no text
                          ),
                          SizedBox(
                              height:
                                  20), // Optional: Add space between fields and list
                          ...stopsAndPrices.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween, // Use space between to separate text and delete icon
                                children: [
                                  Expanded(
                                    child: Text(
                                        '${item['stop']}'),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        stopsAndPrices.remove(item);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                      SizedBox(height: 20),
                      Divider(
                        endIndent: 100,
                        height: 4,
                        thickness: 2,
                        color: Colors.black26,
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0, bottom: 7),
                        child: Text(
                          'Ride Schedule',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 21),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: Text(
                          'Enter precise date and time of your journey',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 10),
                        child: ToggleButtons(
                          borderRadius: BorderRadius.circular(20),
                          renderBorder: true,
                          borderWidth: 1,
                          selectedBorderColor: Colors.white,
                          selectedColor: Colors.white,
                          fillColor: kPrimaryColor,
                          color: Colors.black,
                          constraints:
                              BoxConstraints(minHeight: 30, minWidth: 130),
                          children: [
                            Text('One-time trip'),
                            Text('Recurring trip'),
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int buttonIndex = 0;
                                  buttonIndex < isSelectedTrip.length;
                                  buttonIndex++) {
                                if (buttonIndex == index) {
                                  isSelectedTrip[buttonIndex] = true;
                                } else {
                                  isSelectedTrip[buttonIndex] = false;
                                }
                              }
                            });
                          },
                          isSelected: isSelectedTrip,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 3.0, top: 10, bottom: 10),
                        child: Text(
                          "Leaving",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              focusNode: dateFocusNode,
                              controller: dateController,
                              decoration: InputDecoration(
                                hintText: 'Departure date',
                                filled: true,
                                prefixIcon: Icon(Icons.calendar_month),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10)),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              readOnly: true,
                              onTap: () {
                                _selectDate();
                              },
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(timeFocusNode);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please pick a date to travel';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              'at',
                              style: TextStyle(fontSize: 16),
                            ),
                          ), // Add some space between the two text fields
                          Expanded(
                            child: TextFormField(
                              focusNode: timeFocusNode,
                              onTap: _selectTime,
                              decoration: InputDecoration(
                                hintText: 'Time',
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(modelFocusNode);
                              },
                              readOnly: true,
                              controller: timeController,
                              style: TextStyle(color: Colors.black54),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Pick time';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Divider(
                        endIndent: 100,
                        height: 4,
                        thickness: 2,
                        color: Colors.black26,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0, bottom: 7),
                        child: Text(
                          'Trip prefrences',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0, bottom: 15),
                        child: Text(
                          'This informs passengers of how much space you have for their luggage and extras before they book.',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: Text(
                          'Luggage',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 10),
                        child: ToggleButtons(
                          borderRadius: BorderRadius.circular(20),
                          renderBorder: true,
                          borderWidth: 1,
                          selectedBorderColor: Colors.white,
                          selectedColor: Colors.white,
                          fillColor: Color(0xFF3d5a80),
                          color: Colors.black,
                          constraints:
                              BoxConstraints(minHeight: 33.0, minWidth: 110.0),
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 6,
                                ),
                                Icon(Icons.work),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('No luggage'),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.work),
                                SizedBox(
                                  width: 6,
                                ),
                                Text('Backpack'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.work),
                                SizedBox(
                                  width: 6,
                                ),
                                Text('Cabin Bag'),
                              ],
                            ),
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int buttonIndex = 0;
                                  buttonIndex < isSelected1.length;
                                  buttonIndex++) {
                                if (buttonIndex == index) {
                                  isSelected1[buttonIndex] = true;
                                } else {
                                  isSelected1[buttonIndex] = false;
                                }
                              }
                            });
                          },
                          isSelected: isSelected1,
                        ),
                      ),
                      Text(
                        'Note: Cabin bag must contain maximum of 23kg',
                        style: TextStyle(
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                     /* Padding(
                        padding: const EdgeInsets.only(
                            left: 3.0, top: 15, bottom: 10),
                        child: Text(
                          'Back row sitting',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: Text(
                          'Pledge to a maximum of 2 people in the back for better reviews',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 10),
                        child: ToggleButtons(
                          borderRadius: BorderRadius.circular(20),
                          renderBorder: true,
                          borderWidth: 1,
                          selectedBorderColor: Colors.white,
                          selectedColor: Colors.white,
                          fillColor: Color(0xFF3d5a80),
                          color: Colors.black,
                          constraints:
                              BoxConstraints(minHeight: 30, minWidth: 170),
                          children: [
                            Row(
                              children: [
                                Icon(Icons.group),
                                SizedBox(
                                  width: 7,
                                ),
                                Text('Max 2 people'),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.group),
                                SizedBox(
                                  width: 7,
                                ),
                                Text('3 people'),
                              ],
                            ),
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int buttonIndex = 0;
                                  buttonIndex < isSelectedPeople.length;
                                  buttonIndex++) {
                                if (buttonIndex == index) {
                                  isSelectedPeople[buttonIndex] = true;
                                } else {
                                  isSelectedPeople[buttonIndex] = false;
                                }
                              }
                            });
                          },
                          isSelected: isSelectedPeople,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Text('Other',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 10, // Spacing between chips
                            children: List<Widget>.generate(
                              choices.length,
                              (int index) {
                                return ChoiceChip(
                                  avatar: Icon(
                                    icons[index],
                                    color: isSelected2[index]
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  label: Text(choices[index]),
                                  selected: isSelected2[index],
                                  selectedColor: Color(0xFF3d5a80),
                                  showCheckmark: false,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      isSelected2[index] = selected;
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    side: BorderSide(
                                      color: isSelected2[index]
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                  labelStyle: TextStyle(
                                    color: isSelected2[index]
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        ],
                      ),*/
                      SizedBox(
                        height: 40,
                      ),
                      Divider(
                        endIndent: 100,
                        height: 4,
                        thickness: 2,
                        color: Colors.black26,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 3,
                        ),
                        child: Text(
                          'Select Empty seats',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 2.0),
                              child: Icon(
                                Icons.info_outline_rounded,
                                color: Colors.black54,
                                size: 15,
                              ),
                            ),
                            Text(
                              'Note: You can select maximum 7 seats',
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                if (selectedSeats > 1) selectedSeats--;
                              });
                            },
                          ),
                          Text(
                            '$selectedSeats',
                            style: TextStyle(fontSize: 17),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                if (selectedSeats < 7) selectedSeats++;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Divider(
                        endIndent: 100,
                        height: 4,
                        thickness: 2,
                        color: Colors.black26,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 3, bottom: 15),
                        child: Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: descriptionController,
                        focusNode: descriptionFocusNode,
                        maxLength: 50,
                        maxLines: 2,
                        inputFormatters: [NoEmojiInputFormatter()],
                        decoration: InputDecoration(
                            filled: true,
                            hintText: 'Add description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            )),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Divider(
                        endIndent: 100,
                        height: 4,
                        thickness: 2,
                        color: Colors.black26,
                      ),
                      SizedBox(
                        height: 30,
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: 3, bottom: 15),
                        child: Text(
                          'License plate',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: licenseController,
                          decoration: InputDecoration(
                            filled: true,
                            hintText: 'License plate',
                            hintStyle: TextStyle(
                                color: Colors.grey), // Grey hint text color
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: Colors.black54,
                              size: 15,
                            ),
                          ),
                          Text(
                            'Note: You can edit license plate from vehicle details',
                            style: TextStyle(
                                color: Colors.black54,
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Divider(
                        endIndent: 100,
                        height: 4,
                        thickness: 2,
                        color: Colors.black26,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 3, bottom: 15),
                        child: Text(
                          'Rules when posting a trip',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Image.asset(
                            'images/time.png',
                            height: 100,
                            width: 100,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 3.0, top: 10, bottom: 7),
                            child: Text(
                              'Be reliable',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Text(
                              'Only post a trip if you\'re sure you\'re driving and showup on time.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 18,
                          ),
                          Image.asset(
                            'images/no_cash.png',
                            height: 100,
                            width: 100,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 3.0, top: 10, bottom: 7),
                            child: Text(
                              'No cash',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Text(
                              'All passengers pay online and you receive a payout after the trip.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 18,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Image.asset(
                              'images/drive_safely.png',
                              height: 80,
                              width: 80,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 3.0, top: 10, bottom: 7),
                            child: Text(
                              'Drive safely',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Text(
                              'Stick to the speed limit and do not use your phone while driving.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Row(
                        children: <Widget>[
                          Checkbox(
                            value: _isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                _isChecked = value!;
                              });
                            },
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'I agree to these rules, to the ',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: 'Driver Cancellation Policy',
                                    style: TextStyle(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () =>
                                          _launchURL('https://www.google.com/'),
                                  ),
                                  TextSpan(
                                    text: ', ',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () =>
                                          _launchURL('https://www.google.com/'),
                                  ),
                                  TextSpan(
                                    text: ' and the ',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () =>
                                          _launchURL('https://www.google.com/'),
                                  ),
                                  TextSpan(
                                    text:
                                        ', and I understand that my account could be suspended if I break the rules',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 70.0),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFdfdfdf),
        child: SizedBox(
          height: kBottomNavigationBarHeight, // Adjust if needed
          child: GestureDetector(
            onTap: () {
              if (_isChecked) {
                if (_formKey.currentState?.validate() ?? false) {
                  _postTrip();
                } else {
                  _focusFirstEmptyField();
                }
              } else {
                // Provide feedback if checkbox is not checked
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please agree to the terms and conditions.'),
                  ),
                );
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Post trip',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _isChecked ? Colors.black : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: _isScrolled ? 56 : 100,
        child: FloatingActionButton(
          backgroundColor: kPrimaryColor,
          onPressed: () {
            // Navigate to History screen or perform action
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PostedUserRides()));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, color: Colors.white), // Your history icon
              if (!_isScrolled) // Only show label if not scrolled
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _focusFirstEmptyField() {
    if (departureController.text.isEmpty) {
      FocusScope.of(context).requestFocus(departureFocusNode);
      return;
    }

    if (destinationController.text.isEmpty) {
      FocusScope.of(context).requestFocus(destinationFocusNode);
      return;
    }

    if (dateController == null) {
      FocusScope.of(context).requestFocus(dateFocusNode);
      return;
    }

    if (timeController == null) {
      FocusScope.of(context).requestFocus(timeFocusNode);
      return;
    }
  }

  Future<void> _selectDate() async {
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
}
