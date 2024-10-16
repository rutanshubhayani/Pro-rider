import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel/Find/Passenger/findrequests.dart';
import 'package:travel/Find/SearchResult/searchresult.dart';
import 'package:travel/Find/find.dart';
import 'package:travel/UserProfile/BookedRides/all_booked_rides.dart';
import 'package:travel/widget/configure.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../home.dart';
import '../../widget/City_search.dart';
import '../../api/api.dart';

class Postrequest extends StatefulWidget {
  const Postrequest({Key? key}) : super(key: key);

  @override
  State<Postrequest> createState() => _PostrequestState();
}

class _PostrequestState extends State<Postrequest> {
  final _formKey = GlobalKey<FormState>();
  FocusNode departureFocusNode = FocusNode();
  FocusNode destinationFocusNode = FocusNode();
  FocusNode dateFocusNode = FocusNode();
  FocusNode seatFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();

  TextEditingController departureController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController seatController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool showDepartureContainer = false;
  bool showDestinationContainer = false;
  List<dynamic> departureSuggestions = [];
  List<dynamic> destinationSuggestions = [];
  late TextEditingController
      activeController; // Keep track of the active controller

  int _selectedSeat = 1;
  bool _isChecked = false;


  @override
  void dispose() {
    departureFocusNode.dispose();
    destinationFocusNode.dispose();
    dateFocusNode.dispose();
    seatFocusNode.dispose();
    descriptionFocusNode.dispose();
    departureController.dispose();
    destinationController.dispose();
    dateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not launch $url');
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



  void handleClearClick(TextEditingController controller) {
    setState(() {
      controller.clear();
    });
  }

  Future<void> _postRequest() async {
    // Retrieve the token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      _showErrorSnackbar('User not authenticated. Please log in again.');
      return;
    }

    // Concatenate date and time with a space in between
    final departureDateTime = '${dateController.text} ${timeController.text}';

    final response = await http.post(
      Uri.parse('${API.api1}/post_a_request'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include the token here
      },
      body: jsonEncode({
        'from_location': departureController.text,
        'to_location': destinationController.text,
        'departure_date': departureDateTime, // Use the corrected value here
        'seats_required': _selectedSeat,
        'description': descriptionController.text,
      }),
    );

    print('Sending request: ${response.body}');

    if (response.statusCode == 201) {
      _clearFields();
      Get.snackbar('Success', 'Ride requested successfully',
          snackPosition: SnackPosition.BOTTOM);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(initialIndex: 2,)),
      );
    } else {
      _showErrorSnackbar(
          jsonDecode(response.body)['error'] ?? 'Failed to submit request');
    }
  }

  void _clearFields() {
    setState(() {
      departureController.clear();
      destinationController.clear();
      dateController.clear();
      descriptionController.clear();
      _selectedSeat = 1;
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red, // Optional: customize the background color
        behavior:
            SnackBarBehavior.floating, // Optional: floating or fixed position
      ),
    );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Post a request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'From',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
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
                  FocusScope.of(context).requestFocus(destinationFocusNode);
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
              SizedBox(height: 20),
              Text(
                'To',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
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
              SizedBox(height: 20),
              Text(
                'Departure date',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: dateController,
                    focusNode: dateFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Pick departure date',
                      suffixIcon: dateController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.close_rounded),
                        onPressed: () => handleClearClick(dateController),
                      )
                          : null,
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(seatFocusNode);
                    },
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please pick a date';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: timeController,
                    decoration: InputDecoration(
                      hintText: 'Time',
                     /* suffixIcon: timeController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.close_rounded),
                        onPressed: () => handleClearClick(timeController),
                      )
                          : null,*/
                      prefixIcon: Icon(Icons.watch_later_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    readOnly: true,
                    onTap: () => _selectTime(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pick time';
                      }
                      return null;
                    },
                  ),
                )
              ],
            ),
              SizedBox(height: 20),
              Text(
                'Seats required',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_selectedSeat > 1) _selectedSeat--;
                      });
                    },
                  ),
                  Text(
                    '$_selectedSeat',
                    style: TextStyle(fontSize: 17),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_selectedSeat < 3) _selectedSeat++;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                focusNode: descriptionFocusNode,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText:
                  'Tell driver a little bit more about you and why you\'re travelling.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 40,),
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
              )
            ],
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
                  _postRequest();
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
                    'Post request',
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
      /*floatingActionButton: Container(
        width: 100,
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
      ),*/
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

    if (dateController.text.isEmpty) {
      FocusScope.of(context).requestFocus(dateFocusNode);
      return;
    }

    if (_selectedSeat == 1) {
      // Assuming default seat value of 1 is invalid, adjust as necessary
      FocusScope.of(context).requestFocus(seatFocusNode);
      return;
    }

    if (descriptionController.text.isEmpty) {
      FocusScope.of(context).requestFocus(descriptionFocusNode);
      return;
    }
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
}
