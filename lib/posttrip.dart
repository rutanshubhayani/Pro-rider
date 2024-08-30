import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:travel/api.dart';
import 'package:travel/searchresult.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late TextEditingController activeController; // Keep track of the active controller
  TextEditingController priceController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  FocusNode departureFocusNode = FocusNode();
  FocusNode destinationFocusNode = FocusNode();
  FocusNode stopsFocusNode = FocusNode();
  FocusNode priceFocusNode = FocusNode();
  List<Map<String, String>> stopsAndPrices = [];
  FocusNode dateFocusNode = FocusNode();
  FocusNode timeFocusNode = FocusNode();
  FocusNode modelFocusNode = FocusNode();
  FocusNode cartypeFocusNode = FocusNode();
  FocusNode colorFocusNode = FocusNode();
  FocusNode yearFocusNode = FocusNode();
  FocusNode licenseFocusNode = FocusNode();
  TimeOfDay? selectedTime;
  List<bool> isSelectedTrip = [true, false];
  List<bool> isSelectedPeople = [true, false];
  List<bool> isSelected1 = [true, false, false];
  List<String> choices = ['Winter tires', 'Bikes', 'Skis & snowboards', 'Pets'];
  List<IconData> icons = [Icons.ac_unit, Icons.directions_bike, Icons.downhill_skiing, Icons.pets];
  List<bool> isSelected2 = [false, false, false, false];

  int _selectedChoice = 1;
  int selectedSeats = 1;
  bool _isChecked = false;
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _postTrip() async {
    if (_formKey.currentState?.validate() ?? false) {
      final url = Uri.parse('${API.api1}/post-a-trip');

      final Map<String, dynamic> body = {
        'departure': departureController.text,
        'destination': destinationController.text,
        'ride_shedule': isSelectedTrip[0] ? 'One-time trip' : 'Recurring trip',
        'leaving_date_time': '${dateController.text} ${timeController.text}',
        'luggage': isSelected1.indexWhere((element) => element),
        'back_row_sitiing': isSelectedPeople[0] ? 'Max 2 people' : '3 people',
        'other_items': choices
            .asMap()
            .entries
            .where((entry) => isSelected2[entry.key])
            .map((entry) => entry.value)
            .join(', '),
        'empty_seats': selectedSeats,
        'stops': stopsAndPrices.map((stopAndPrice) => {
          'name': stopAndPrice['stop'],
          'price': stopAndPrice['price'],
        }).toList(),
      };
      print('Sending data: $body');

      try {
        final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Trip posted successfully!')),
          );
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SearchResult(initialTabIndex: 1, results: [], selectedCities: [],)));

          // Navigate to search results or another page if needed
        } else {
          print('Failed to post trip: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to post trip: ${response.body}')),
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
      backgroundColor: Colors.red, // Set the background color to red to indicate an error
      behavior: SnackBarBehavior.floating, // Make the snackbar float
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
    final price = priceController.text;

    if (stop.isNotEmpty && price.isNotEmpty) {
      setState(() {
        stopsAndPrices.add({
          'stop': stop,
          'price': price,
        });
      });

      // Clear the input fields
      stopsController.clear();
      priceController.clear();
      FocusScope.of(context).requestFocus(stopsFocusNode);
    }
  }

  // Image selection state and methods
  /* File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }
  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedImage = await _picker.pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }
*/

  @override
  void dispose() {
    departureFocusNode.dispose();
    destinationFocusNode.dispose();
    stopsFocusNode.dispose();
    priceFocusNode.dispose();
    dateFocusNode.dispose();
    timeFocusNode.dispose();
    /* modelFocusNode.dispose();
    cartypeFocusNode.dispose();
    colorFocusNode.dispose();
    yearFocusNode.dispose();
    licenseFocusNode.dispose();*/
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Post a trip'),
      ),
      body: Material(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0, left: 16, right: 16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey ,
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
                        padding: EdgeInsets.only(
                            top: 5, left: 3.0, bottom: 10),
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


                      TextFormField(
                        controller: departureController,
                        focusNode: departureFocusNode,
                        decoration: InputDecoration(
                          filled: true,
                          prefixIcon: Icon(Icons.location_on),
                          hintText: 'Departure Location',
                          suffixIcon: departureController.text.isNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.close_rounded),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter departure location';
                          }
                          return null;
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
                      TextFormField(
                        controller: destinationController,
                        focusNode: destinationFocusNode,
                        decoration: InputDecoration(
                          filled: true,
                          prefixIcon: const Icon(Icons.location_on),
                          hintText: 'Destination Location',
                          suffixIcon: destinationController.text.isNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.close_rounded),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter destination location';
                          }
                          return null;
                        },
                      ),
                      if (showDestinationContainer)
                       /* Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0XFFe6e0e9),
                          ),*/Card(
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
                                    prefixIcon: Icon(Icons.add_location_alt_sharp),
                                    hintText: 'Stops Location',
                                    suffixIcon: stopsController.text.isNotEmpty
                                        ? IconButton(
                                      icon: Icon(Icons.close_rounded),
                                      onPressed: () => handleClearClick(stopsController),
                                    )
                                        : null, // Only show the clear icon if there's text in the field
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) {
                                    _updateSuggestions(value, stopsController);
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  focusNode: priceFocusNode,
                                  controller: priceController,
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
                                    FocusScope.of(context).requestFocus(dateFocusNode);
                                  },
                                ),
                              ),
                            ],
                          ),
                          // Container for suggestions
                          if (showStopsContainer)
                           Card(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(), // Prevent scrolling within the Container
                                itemCount: stopsSuggestions.length,
                                itemBuilder: (context, index) {
                                  final suggestion = stopsSuggestions[index];
                                  return ListTile(
                                    leading: Icon(Icons.location_on),
                                    title: Text('${suggestion['city']}, ${suggestion['pname']}'),
                                    onTap: () {
                                      stopsController.text = '${suggestion['city']}, ${suggestion['pname']}';
                                      setState(() {
                                        showStopsContainer = false; // Hide the suggestions after selection
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0), // Adjust the radius as needed
                                  ),
                                ),
                                elevation: MaterialStateProperty.all(5.0), // Adjust the elevation as needed
                              ),
                              onPressed: addStopAndPrice,
                              child: Text(
                                'Add',
                                style: TextStyle(color: Colors.black),
                              ),
                            )

                          ),
                          SizedBox(height: 20), // Optional: Add space between fields and list
                          ...stopsAndPrices.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Use space between to separate text and delete icon
                                children: [
                                  Expanded(
                                    child: Text('${item['stop']} - ${item['price']}'),
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
                      SizedBox(height: 40),
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
                          selectedBorderColor: Colors.black,
                          selectedColor: Colors.white,
                          fillColor: Colors.black,
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
                        padding: const EdgeInsets.only(left: 3.0, top: 10,bottom: 10),
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
                              onFieldSubmitted: (_){
                                FocusScope.of(context).requestFocus(timeFocusNode);
                              },
                              validator: (value){
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
                              onTap: () async {
                                final TimeOfDay? timeOfDay = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime ?? TimeOfDay.now(),
                                  initialEntryMode: TimePickerEntryMode.dial,
                                );
                                if (timeOfDay != null) {
                                  setState(() {
                                    selectedTime = timeOfDay;
                                    timeController.text =
                                    "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}";
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Time', // Added hint text for clarity
                                filled: true,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10)),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_){
                                FocusScope.of(context).requestFocus(modelFocusNode);
                              },
                              readOnly: true,
                              controller: timeController,
                              style: TextStyle(color: Colors.black54),
                              validator: (value){
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
                        height: 40,
                      ),
                      /* Padding(
                        padding: const EdgeInsets.only(left: 3.0, bottom: 7),
                        child: Text(
                          'Vehicle details',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: Text(
                          'This will help you get more bookings and it will be easier for passengers to identify your vehicle during pick-up.',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Integrated image selection from _AddThemeScreen1
                      GestureDetector(
                        onTap: () async {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return SafeArea(
                                child: Wrap(
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(Icons.photo_camera),
                                      title: Text("Camera"),
                                      onTap: () {
                                        _getImage(ImageSource.camera);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.photo_library),
                                      title: Text("Gallery"),
                                      onTap: () {
                                        _getImage(ImageSource.gallery);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Center(
                          child: Stack(
                            children: [
                              Container(
                                height: 200,
                                width: 300,
                                decoration: BoxDecoration(
                                  border:
                                  Border.all(color: Colors.grey, width: 2.0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: _selectedImage != null
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                    : Center(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 60.0),
                                        child: Icon(
                                          Icons.directions_car,
                                          color: Colors.grey,
                                          size: 50,
                                        ),
                                      ),
                                      Text(
                                        'Add Photo',
                                        style:
                                        TextStyle(color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_selectedImage != null)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: _removeImage,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black54,
                                      ),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 3.0),
                              child: Text(
                                'Model',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              focusNode: modelFocusNode,
                              decoration: InputDecoration(
                                  filled: true,
                                  hintText: 'e.g. Ford Focus',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_){
                                FocusScope.of(context).requestFocus(cartypeFocusNode);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 3.0),
                              child: Text(
                                'Type',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black87),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 53,
                              child: DropdownButtonFormField(
                                focusNode: cartypeFocusNode,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                items: ['Sedan', 'SUV', 'Truck', 'Coupe']
                                    .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                                    .toList(),
                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus(colorFocusNode);
                                },

                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 3.0),
                              child: Text(
                                'Color',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 50,
                              child: DropdownButtonFormField(
                                focusNode: colorFocusNode,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                items: ['Red', 'Blue', 'White', 'Black']
                                    .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                                    .toList(),
                                onChanged: (value) {
                                  FocusScope.of(context).requestFocus(yearFocusNode);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 3.0),
                              child: Text(
                                'Year',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 2,
                              child: TextFormField(
                                focusNode: yearFocusNode,
                                maxLength: 4,
                                /*inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,],*/
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    hintText: 'YYYY',
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_){
                                  FocusScope.of(context).requestFocus(licenseFocusNode);
                                },
                              )),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.only(left: 3),
                              child: Text(
                                'Licence Plate',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 2,
                              child: TextFormField(
                                focusNode: licenseFocusNode,
                                decoration: InputDecoration(
                                    filled: true,
                                    hintText: 'POP 123',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    )),
                              )),
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
                        height: 40,
                      ),*/
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0,bottom: 7),
                        child: Text(
                          'Trip prefrences',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0,bottom: 15),
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
                        padding: const EdgeInsets.only(left: 10.0,top: 10),
                        child: ToggleButtons(
                          borderRadius: BorderRadius.circular(20),
                          renderBorder: true,
                          borderWidth: 1,
                          selectedBorderColor: Colors.black,
                          selectedColor: Colors.white,
                          fillColor: Colors.black,
                          color: Colors.black,
                          constraints: BoxConstraints(minHeight: 33.0, minWidth: 110.0),
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 6,),
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
                                SizedBox(width: 6,),
                                Text('Backpack'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.work),
                                SizedBox(width: 6,),
                                Text('Cabin Bag'),
                              ],
                            ),
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int buttonIndex = 0; buttonIndex < isSelected1.length; buttonIndex++) {
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
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0,top: 15,bottom: 10),
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
                        padding: const EdgeInsets.only(left: 10.0,top: 10),
                        child: ToggleButtons(
                          borderRadius: BorderRadius.circular(20),
                          renderBorder: true,
                          borderWidth: 1,
                          selectedBorderColor: Colors.black,
                          selectedColor: Colors.white,
                          fillColor: Colors.black,
                          color: Colors.black,
                          constraints:
                          BoxConstraints(minHeight: 30, minWidth: 170),
                          children: [
                            Row(
                              children: [
                                Icon(Icons.group),
                                SizedBox(width: 7,),
                                Text('Max 2 people'),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.group),
                                SizedBox(width: 7,),
                                Text('3 pepple'),],
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
                      SizedBox(height: 20,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Text(
                                'Other',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 10, // Spacing between chips
                            children: List<Widget>.generate(
                              choices.length,
                                  (int index) {
                                return ChoiceChip(
                                  avatar: Icon(
                                    icons[index],
                                    color: isSelected2[index] ? Colors.white : Colors.black,
                                  ),
                                  label: Text(choices[index]),
                                  selected: isSelected2[index],
                                  selectedColor: Colors.black,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      isSelected2[index] = selected;
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    side: BorderSide(
                                      color: isSelected2[index] ? Colors.black : Colors.grey,
                                    ),),
                                  labelStyle: TextStyle(
                                    color: isSelected2[index] ? Colors.white : Colors.black,
                                  ),
                                );
                              },
                            ).toList(),
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
                        height: 40,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 3,top: 15),
                        child: Text(
                          'Select Empty seats',
                          style: TextStyle(
                            fontSize:20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0,bottom: 15),
                        child: Text('Note: You can select maximum 7 seats',
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              fontStyle: FontStyle.italic
                          ),),
                      ),

                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove,size: 30,),
                            onPressed: () {
                              setState(() {
                                if (selectedSeats > 1) selectedSeats--;
                              });
                            },
                          ),

                          Text('$selectedSeats',
                            style: TextStyle(
                                fontSize: 17
                            ),),
                          IconButton(
                            icon: Icon(Icons.add,size: 30,),
                            onPressed: () {
                              setState(() {
                                if (selectedSeats < 7) selectedSeats++;
                              });
                            },
                          ),
                        ],
                      ),
                      /* Row(
                        children: List.generate(3, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedChoice = index + 1;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _selectedChoice == index + 1 ? Colors.black : Colors.white,
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: _selectedChoice == index + 1 ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
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
                        height: 40,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 3,bottom: 15,top: 15),
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
                          SizedBox(height: 10,),
                          Image.asset('images/time.png',height: 100,width: 100,),
                          Padding(
                            padding: const EdgeInsets.only(left: 3.0,top: 10,bottom: 7),
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
                          SizedBox(height: 18,),
                          Image.asset('images/no_cash.png',height: 100,width: 100,),
                          Padding(
                            padding: const EdgeInsets.only(left: 3.0,top: 10,bottom: 7),
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
                          SizedBox(height: 18,),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Image.asset('images/drive_safely.png',height: 80,width: 80,),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3.0,top: 10,bottom: 7),
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
                                      ..onTap = () => _launchURL('https://www.google.com/'),
                                  ),
                                  TextSpan(
                                    text: ', ',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => _launchURL('https://www.google.com/'),
                                  ),
                                  TextSpan(
                                    text: ' and the ',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => _launchURL('https://www.google.com/'),
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
        child: GestureDetector(
          onTap: () {
            print('Post trip tapped');
            if (_formKey.currentState?.validate() ?? false) {
              _postTrip();

            }
            else {
              _focusFirstEmptyField();
            }

          },
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
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _focusFirstEmptyField(){
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


