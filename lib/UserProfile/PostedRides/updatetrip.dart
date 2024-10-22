import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel/UserProfile/PostedRides/all_posted_rides.dart';
import 'package:travel/api/api.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widget/City_search.dart';
import '../../widget/configure.dart';

class UpdateTrip extends StatefulWidget {
  final Map<String, dynamic> tripData;
  const UpdateTrip({Key? key, required this.tripData}) : super(key: key);

  @override
  State<UpdateTrip> createState() => _UpdateTripState();
}

class _UpdateTripState extends State<UpdateTrip> {
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
  late List<bool> isSelectedTrip;
  late List<bool> isSelectedPeople;
  late List<bool> isSelected1;
  List<String> choices = ['Winter tires', 'Bikes', 'Skis & snowboards', 'Pets'];

  List<String> rideScheduleOptions = ['One-time trip', 'Recurring trip'];
  List<IconData> rideicons = [Icons.date_range, Icons.repeat]; // Replace with your actual icons
  List<bool> isSelectedTrip1 = [false, false]; // Track selected state for each chip
  String _selectedRideSchedule = ''; // Store the selected ride schedule
  late List<bool> isSelected2;

  List<String> tripPreferences = ['No luggage', 'Backpack', 'Cabin bag (23kg)', 'Cabin bag (46kg)'];
  List<IconData> tripIcons = [
    Icons.clear,       // Represents no luggage
    Icons.backpack,    // Represents a backpack
    Icons.cases_outlined,     // Represents a cabin bag (23kg)
    Icons.luggage,    // Represents a cabin bag (46kg)
  ];
  List<bool> isSelected3 = [false, false, false,false]; // Track selected state for each chip
  int selectedSeats = 1;
  bool _isChecked = true;
  bool _isEditingStops = false;

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
    print('Update Data : ${widget.tripData}');

    initializeSelections();
    InitializeControllers();
    fetchVehicleData();
  }

  void initializeSelections() {
    final rideSchedule = widget.tripData['rideSchedule'] ?? 'Unknown';
    final backRowSitting = widget.tripData['backRowSitting'] ?? 'Unknown';
    final luggageCode = widget.tripData['luggage']?.toString() ?? '0';
    final otherItems = widget.tripData['otherItems']?.split(',') ?? [];

    initializeIsSelected2(otherItems);
    initializeIsSelected1(luggageCode);
    initializeIsSelectedPeople(backRowSitting);
    initializeIsSelectedTrip(rideSchedule);
  }

  void initializeIsSelected2(List<String> otherItems) {
    isSelected2 = List<bool>.filled(choices.length, false);

    for (var item in otherItems) {
      item = item.trim();
      if (choices.contains(item)) {
        int selectedIndex = choices.indexOf(item);
        isSelected2[selectedIndex] = true;
      }
    }
  }

  void initializeIsSelected1(String luggageCode) {
    isSelected1 = [false, false, false, false]; // Default to none selected

    switch (luggageCode) {
      case '0':
        isSelected1[0] = true; // "No luggage"
        break;
      case '1':
        isSelected1[1] = true; // "Backpack"
        break;
      case '2':
        isSelected1[2] = true; // "Cabin bag"
        break;
        case '3':
        isSelected1[3] = true; // "Cabin bag"
        break;
      default:
        // Remains as no selection
        break;
    }
  }


  void initializeIsSelectedPeople(String backRowSitting) {
    if (backRowSitting == 'Max 2 people') {
      isSelectedPeople = [true, false]; // "Max 2 people"
    } else if (backRowSitting == '3 people') {
      isSelectedPeople = [false, true]; // "3 people"
    } else {
      isSelectedPeople = [false, false]; // Default to none selected
    }
  }

  void initializeIsSelectedTrip(String rideSchedule) {
    if (rideSchedule == 'One-time trip') {
      isSelectedTrip = [true, false]; // "One-time trip"
    } else if (rideSchedule == 'Recurring trip') {
      isSelectedTrip = [false, true]; // "Recurring trip"
    } else {
      isSelectedTrip = [false, false]; // Default to none selected
    }
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

  void InitializeControllers() {
    // Set the departure city to the controller text
    departureController.text =
        widget.tripData['departure'] ?? 'Unknown Departure';

    // You can also initialize other fields similarly
    destinationController.text =
        widget.tripData['destination'] ?? 'Unknown Destination';
    String dateTimeString = widget.tripData['date'].toString();
    DateTime parsedDateTime = DateTime.parse(dateTimeString);
    // Format the date and time as needed
    String formattedDate =
        "${parsedDateTime.year}-${parsedDateTime.month.toString().padLeft(2, '0')}-${parsedDateTime.day.toString().padLeft(2, '0')}";
    String formattedTime =
        "${parsedDateTime.hour.toString().padLeft(2, '0')}:${parsedDateTime.minute.toString().padLeft(2, '0')}";

    // Set the values to the controllers
    dateController.text = formattedDate;
    timeController.text = formattedTime;
    descriptionController.text = widget.tripData['description'] ?? '';
    dpriceController.text = widget.tripData['price'].toString() ?? 'N/A';
    descriptionController.text =
        widget.tripData['description'].toString() ?? 'N/A';

    // For numeric fields like seats
    selectedSeats = widget.tripData['seatsLeft'] ?? 1;
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

    if (stop.isNotEmpty) {
      setState(() {
        // Append the new stop to the existing list
        stopsAndPrices.add({
          'stop': stop,
          // 'price': price,
        });
      });

      // Clear the input fields
      stopsController.clear();
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


  Future<void> _updateTrip() async {
    final postAtripID = widget.tripData['post_a_trip_id'].toString();

    if (_formKey.currentState?.validate() ?? false) {
      final url = Uri.parse('${API.api1}/update-trip/$postAtripID');

      // Prepare the merged stops to send in the request
      final List<Map<String, dynamic>> mergedStops = [
        // Existing stops from the API response
        if (widget.tripData['stops'] != null)
          ...widget.tripData['stops'].map<Map<String, dynamic>>((stop) => {
            'stop_name': stop['stop_name'] ?? '', // Safely handle nulls
            'stop_price': stop['stop_price']?.toString() ?? '0', // Convert price to String
          }).toList(),

        // Newly added stops
        ...stopsAndPrices.map<Map<String, dynamic>>((item) => {
          'stop_name': item['stop'] ?? '',
          'stop_price': item['price'] ?? '0',
        }),
      ];

      // Create the body for the API request
      final Map<String, dynamic> body = {
        'departure': departureController.text,
        'destination': destinationController.text,
        'price': dpriceController.text,
        'ride_schedule': isSelectedTrip[0] ? 'One-time trip' : 'Recurring trip',
        'leaving_date_time': '${dateController.text} ${timeController.text}', // Ensure the format is YYYY-MM-DD HH:mm
        'luggage': isSelected1.indexWhere((element) => element),
        /*'back_row_sitting': isSelectedPeople[0] ? 'Max 2 people' : '3 people',
        'other_items': choices
            .asMap()
            .entries
            .where((entry) => isSelected2[entry.key])
            .map((entry) => entry.value)
            .join(', '),*/
        'empty_seats': selectedSeats,
        'description': descriptionController.text,
        'stops': mergedStops, // Include the properly formatted stops here
      };

      print('Sending data: $body'); // Check that the data being sent includes stops

      try {
        final prefs = await SharedPreferences.getInstance();
        final authToken = prefs.getString('authToken');

        final response = await http.put(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            if (authToken != null) 'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Trip updated successfully!')),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => PostedUserRides()),
          );

          print('Response from server: ${response.body}'); // Log response
        } else {
          print('Failed to update trip: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update trip: ${response.body}')),
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

  String getLuggageLabel(String code) {
    switch (code) {
      case '0':
        return 'No luggage';
      case '1':
        return 'Backpack';
      case '2':
        return 'Cabin bag (max. 23 kg)';
      default:
        return 'Unknown';
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
    final uid = widget.tripData['uid'].toString() ?? 'Unknown uid';
    final postAtripID =
        widget.tripData['post_a_trip_id'].toString() ?? 'Unknown uid';

    // Assuming widget.tripData['stops'] contains the stop details
    final stops = widget.tripData['stops'] ?? [];

/*
    final stop = stops.isNotEmpty ? stops.first : null;
*/

    /* final DateTime dateTime =
        DateTime.parse(widget.tripData['date'].toString());
    final String formattedDate =
        DateFormat('EE, MMM d \'at\' h:mm a').format(dateTime);
    final departureCity = widget.tripData['departure'] ?? 'Unknown Departure';
    final departureCityFirstName =
        widget.tripData['departure']?.split(' ').first ?? 'Unknown';
    final destinationCity =
        widget.tripData['destination'] ?? 'Unknown Destination';
    final destinationCityFirstName =
        widget.tripData['destination']?.split(' ').first ?? 'Unknown';
    final userName = widget.tripData['userName'] ?? 'Unknown';
    final price = widget.tripData['price']?.toString() ?? '0';
    final luggageCode = widget.tripData['luggage']?.toString() ?? '0';
    final luggage = getLuggageLabel(luggageCode);
    final description = widget.tripData['description']?.isNotEmpty == true
        ? widget.tripData['description']
        : 'Trip from $departureCity to $destinationCity';
    final rideSchedule = widget.tripData['rideSchedule'] ?? 'Unknown';
    final int seatsLeft = widget.tripData['seatsLeft'] ?? 0;
    final backRowSitting = widget.tripData['backRowSitting'] ?? 'Not specified';
    final userImage = widget.tripData['userImage'] ?? 'images/Userpfp.png';
    final stopsData = widget.tripData['stops'] as List<dynamic>? ?? [];

    final Map<String, IconData> luggageIcons = {
      'No luggage': Icons.cancel,
      'Backpack': Icons.backpack,
      'Cabin bag (max. 23 kg)': Icons.luggage,
    };

    final Map<String, IconData> itemsIcons = {
      'Winter tires': Icons.ac_unit,
      'Skis & snowboards': Icons.downhill_skiing,
      'Pets': Icons.pets,
      'Bikes': Icons.directions_bike,
    };
*/
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Update trip'),
        ),
        body: Material(
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0, left: 16, right: 16),
            child: SingleChildScrollView(
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
                          padding:
                              EdgeInsets.only(top: 5, left: 3.0, bottom: 10),
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
                        CitySearchField(
                          controller: destinationController,
                          focusNode: destinationFocusNode,
                          hintText: 'destination Location',
                          showSuggestions: showDestinationContainer,
                          suggestions: destinationSuggestions,
                          onChanged: (value) {
                            activeController = destinationController;
                            _updateSuggestions(value, destinationController);
                          },
                          onSubmitted: (value) {
                            FocusScope.of(context)
                                .requestFocus(destinationFocusNode);
                          },
                          onClear: () => handleClearClick(destinationController),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter destination';
                            }
                            return null;
                          },
                          onSuggestionTap: (suggestion) {
                            destinationController.text =
                            '${suggestion['city']}, ${suggestion['pname']}';
                            setState(() {
                              showDestinationContainer = false;
                            });
                          },
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
                            CitySearchField(
                              controller: stopsController,
                              focusNode: stopsFocusNode,
                              hintText: 'stops Location',
                              showSuggestions: showStopsContainer,
                              suggestions: stopsSuggestions,
                              onChanged: (value) {
                                activeController = stopsController;
                                _updateSuggestions(value, stopsController);
                              },
                              onSubmitted: (value) {
                                FocusScope.of(context)
                                    .requestFocus(stopsFocusNode);
                              },
                              onClear: () => handleClearClick(stopsController),

                              onSuggestionTap: (suggestion) {
                                stopsController.text =
                                '${suggestion['city']}, ${suggestion['pname']}';
                                setState(() {
                                  showStopsContainer = false;
                                });
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                      ),
                                      elevation: MaterialStateProperty.all(5.0),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isEditingStops =
                                            !_isEditingStops; // Toggle editing mode
                                      });
                                    },
                                    child: Text(
                                      _isEditingStops ? 'Done' : 'Edit Stops',
                                      style: TextStyle(color: Colors.black),
                                    ),
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
                              ],
                            ),

// Always display stops from the response
// Always display stops from the response
                            for (var stop in widget.tripData['stops'] ?? [])
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                          '${stop['stop_name']} '),
                                    ),
                                    if (_isEditingStops) // Show delete icon only in edit mode
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          setState(() {
                                            // Remove the stop using its unique identifier
                                            widget.tripData['stops']
                                                .removeWhere((s) =>
                                                    s['stop_id'] ==
                                                    stop['stop_id']);
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              ),

                            // Display all stops and prices
                            ...stopsAndPrices.map((item) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                          '${item['stop']}'), // Correctly reference 'stop' and 'price'
                                    ),
                                    if (_isEditingStops) // Show delete icon only in edit mode
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          setState(() {
                                            stopsAndPrices.remove(
                                                item); // Use stopsAndPrices for removal
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                        Divider(
                          height: 4,
                          thickness: 1,
                          color: Colors.black26,
                        ),
                        SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.only(left: 3.0, bottom: 7),
                          child: Text(
                            'Price',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: CustomTextField(
                            label: 'Price',
                            controller: dpriceController,
                            focusNode: dpriceFocusNode,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(stopsFocusNode);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter price';
                              }
                              return null;
                            },
                            hintText: 'Enter price',
                            prefixIcon: Icon(Icons.currency_exchange),
                          ),

                        ),
                        SizedBox(height: 25),
                        Divider(
                          endIndent: 100,
                          height: 4,
                          thickness: 2,
                          color: Colors.black26,
                        ),
                        SizedBox(height: 10,),

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
            Wrap(
              spacing: 10, // Spacing between chips
              children: List<Widget>.generate(
                rideScheduleOptions.length,
                    (int index) {
                  return ChoiceChip(
                    avatar: Icon(
                      rideicons[index],
                      color: isSelectedTrip[index] ? Colors.white : Colors.black,
                    ),
                    label: Text(rideScheduleOptions[index]),
                    selected: isSelectedTrip[index],
                    selectedColor: Color(0xFF3d5a80),
                    showCheckmark: false,
                    onSelected: (bool selected) {
                      setState(() {
                        if (!selected || isSelectedTrip[index]) return;

                        // Deselect all other chips and select the current chip
                        for (int i = 0; i < isSelectedTrip.length; i++) {
                          isSelectedTrip[i] = (i == index);
                        }
                        _selectedRideSchedule = rideScheduleOptions[index]; // Update selected schedule
                      });
                    },
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: isSelectedTrip[index] ? Colors.white : Colors.grey,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: isSelectedTrip[index] ? Colors.white : Colors.black,
                    ),
                  );
                },
              ).toList(),
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
                              child: CustomTextField(
                                label: 'Departure Date',
                                controller: dateController,
                                focusNode: dateFocusNode,
                                keyboardType: TextInputType.none,  // Since it's a date picker
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(timeFocusNode);
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please pick a date to travel';
                                  }
                                  return null;
                                },
                                hintText: 'Departure date',
                                prefixIcon: Icon(Icons.calendar_month),
                                readOnly: true,  // Makes it non-editable, only tappable
                                onTap: () {
                                  _selectDate();  // Your method to open the date picker
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
                              child: CustomTextField(
                                label: 'Time',
                                controller: timeController,
                                focusNode: timeFocusNode,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(modelFocusNode);
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Pick time';
                                  }
                                  return null;
                                },
                                hintText: 'Time',
                                readOnly: true,  // Make it non-editable, so only tappable
                                onTap: _selectTime,  // Opens the time picker
                                textStyle: TextStyle(color: Colors.black54),
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
          Wrap(
            spacing: 10, // Spacing between chips
            children: List<Widget>.generate(
              tripPreferences.length,
                  (int index) {
                return ChoiceChip(
                  avatar: Icon(
                    tripIcons[index],
                    color: isSelected1[index] ? Colors.white : Colors.black,
                  ),
                  label: Text(tripPreferences[index]),
                  selected: isSelected1[index],
                  selectedColor: Color(0xFF3d5a80),
                  showCheckmark: false,
                  onSelected: (bool selected) {
                    setState(() {
                      // If the user clicks on an already selected chip, don't allow deselecting it.
                      // Ensure that at least one chip is always selected.
                      if (!selected || isSelected1[index]) return;

                      // Deselect all other chips and select the current chip
                      for (int i = 0; i < isSelected1.length; i++) {
                        isSelected1[i] = (i == index);
                      }
                    });
                  },
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      color: isSelected1[index] ? Colors.white : Colors.grey,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected1[index] ? Colors.white : Colors.black,
                  ),
                );
              },
            ).toList(),
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
                                  SizedBox(width: 7),
                                  Text('Max 2 people'),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.group),
                                  SizedBox(width: 7),
                                  Text('3 people'),
                                ],
                              ),
                            ],
                            onPressed: (int index) {
                              setState(() {
                                for (int buttonIndex = 0;
                                    buttonIndex < isSelectedPeople.length;
                                    buttonIndex++) {
                                  isSelectedPeople[buttonIndex] =
                                      buttonIndex == index;
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
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
                                            ? Colors.black
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
                              '$selectedSeats', // Display the currently selected seats
                              style: TextStyle(fontSize: 17),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add,
                                size: 30,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (selectedSeats < 7)
                                    selectedSeats++; // Allow adding if seats are available
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
                            hintText: 'Add description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.grey,
                                  width: 2
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(
                                  color: kPrimaryColor,
                                  width: 2
                              ),),),
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
                              'Note: You can\'t edit license plate',
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
                                        ..onTap = () => _launchURL(
                                            'https://www.google.com/'),
                                    ),
                                    TextSpan(
                                      text: ', ',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(color: Colors.blue),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => _launchURL(
                                            'https://www.google.com/'),
                                    ),
                                    TextSpan(
                                      text: ' and the ',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(color: Colors.blue),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => _launchURL(
                                            'https://www.google.com/'),
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
                print('Update trip tapped');
                if (_isChecked) {
                  if (_formKey.currentState?.validate() ?? false) {
                  } else {
                    _focusFirstEmptyField();
                  }
                  _updateTrip();
                } else {
                  // Provide feedback if checkbox is not checked
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Please agree to the terms and conditions.'),
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
                      'Update trip',
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
        ));
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

    /* if (dateController == null) {
      FocusScope.of(context).requestFocus(dateFocusNode);
      return;
    }

    if (timeController == null) {
      FocusScope.of(context).requestFocus(timeFocusNode);
      return;
    }*/
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
