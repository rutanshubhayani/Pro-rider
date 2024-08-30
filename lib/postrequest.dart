import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel/searchresult.dart';
import 'api.dart';

class Postrequest extends StatefulWidget {
  const Postrequest({Key? key}) : super(key: key);

  @override
  State<Postrequest> createState() => _PostrequestState();
}

class _PostrequestState extends State<Postrequest> {
  final _formKey = GlobalKey<FormState>();
  FocusNode originFocusNode = FocusNode();
  FocusNode destinationFocusNode = FocusNode();
  FocusNode dateFocusNode = FocusNode();
  FocusNode seatFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();

  TextEditingController originController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController seatController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool showOriginContainer = false;
  bool showDestinationContainer = false;
  List<dynamic> originSuggestions = [];
  List<dynamic> destinationSuggestions = [];
  late TextEditingController activeController; // Keep track of the active controller

  int _selectedSeat = 1;

  @override
  void dispose() {
    originFocusNode.dispose();
    destinationFocusNode.dispose();
    dateFocusNode.dispose();
    seatFocusNode.dispose();
    descriptionFocusNode.dispose();
    originController.dispose();
    destinationController.dispose();
    dateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void handleClearClick(TextEditingController controller) {
    setState(() {
      controller.clear();
    });
  }

  Future<void> _postRequest() async {
    final response = await http.post(
      Uri.parse('${API.api1}/post_a_request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'from_location': originController.text,
        'to_location': destinationController.text,
        'departure_date': dateController.text,
        'seats_required': _selectedSeat,
        'description': descriptionController.text,
      }),
    );

    print('Sending request: ${response.body}');

    if (response.statusCode == 201) {
      _clearFields();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchResult(initialTabIndex: 2, results: [], selectedCities: [],)),
      );

    } else {
      _showErrorSnackbar(jsonDecode(response.body)['error'] ?? 'Failed to submit request');
    }
  }

  void _clearFields(){
   setState(() {
     originController.clear();
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
        behavior: SnackBarBehavior.floating, // Optional: floating or fixed position
      ),
    );
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
        if (controller == originController) {
          showOriginContainer = true;
        } else if (controller == destinationController) {
          showDestinationContainer = true;
        }
      });
      try {
        if (controller == originController) {
          originSuggestions = await fetchCities(pattern);
        } else if (controller == destinationController) {
          destinationSuggestions = await fetchCities(pattern);
        }
        setState(() {}); // Update the UI with new suggestions
      } catch (e) {
        print('Error updating suggestions: $e');
      }
    } else {
      setState(() {
        if (controller == originController) {
          showOriginContainer = false;
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
        title: Text('Post a request'),
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
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 10,),
              TextFormField(
                controller: originController,
                focusNode: originFocusNode,
                decoration: InputDecoration(
                  filled: true,
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'Enter origin',
                  suffixIcon: originController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.close_rounded),
                    onPressed: () => handleClearClick(originController),
                  )
                      : null, // Only show the clear icon if there's text in the field
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  activeController = originController;
                  _updateSuggestions(value, originController);
                },
                onFieldSubmitted: (value){
                  FocusScope.of(context).requestFocus(destinationFocusNode);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter origin location';
                  }
                  return null;
                },
              ),
              if (showOriginContainer)
                Card(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: originSuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = originSuggestions[index];
                      return ListTile(
                        leading: Icon(Icons.location_on),
                        title: Text('${suggestion['city']}, ${suggestion['pname']}'),
                        onTap: () {
                          originController.text = '${suggestion['city']}, ${suggestion['pname']}';
                          setState(() {
                            showOriginContainer = false; // Hide the suggestions after selection
                          });
                        },
                      );
                    },
                  ),
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
              TextFormField(
                controller: destinationController,
                focusNode: destinationFocusNode,
                decoration: InputDecoration(
                  filled: true,
                  prefixIcon: const Icon(Icons.location_on),
                  hintText: 'Enter destination',
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
                onFieldSubmitted: (value){
                  FocusScope.of(context).requestFocus(dateFocusNode);
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
              Text(
                'Departure date',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10,),
              TextFormField(
                controller: dateController,
                focusNode: dateFocusNode,
                decoration: InputDecoration(
                  hintText: 'Pick departure date',
                  suffixIcon: dateController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.close_rounded),
                    onPressed: () => handleClearClick(dateController),
                  )
                      : null, // Only show the clear icon if there's text in the field
                  filled: true,
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
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
              SizedBox(height: 20,),
              Text(
                'Seats required',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17
                ),
              ),
              SizedBox(height: 10,),
              DropdownButtonFormField<int>(
                focusNode: seatFocusNode,
                value: _selectedSeat,
                decoration: InputDecoration(
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: List.generate(3, (index) => index + 1)
                    .map((seat) => DropdownMenuItem<int>(

                  value: seat,
                  child: Text(seat.toString()),
                ))
                    .toList(),
                onChanged: (newValue) {
                  FocusScope.of(context).requestFocus(descriptionFocusNode);
                  setState(() {
                    _selectedSeat = newValue!;
                  });
                },
                icon: Icon(Icons.arrow_forward_ios_rounded),
              ),
              SizedBox(height: 20,),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10,),
              TextFormField(
                controller: descriptionController,
                focusNode: descriptionFocusNode,
                maxLines: 5,
                decoration: InputDecoration(
                    filled: true,
                    hintText: 'Tell driver a little bit more about you and why you\'re\ travelling.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    )
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: GestureDetector(
          onTap: () {
            if (_formKey.currentState!.validate()) {
              _postRequest();
            } else {
              _focusFirstEmptyField();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              textAlign: TextAlign.center,
              'Post request',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _focusFirstEmptyField() {
    if (originController.text.isEmpty) {
      FocusScope.of(context).requestFocus(originFocusNode);
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

    if (_selectedSeat == 1) { // Assuming default seat value of 1 is invalid, adjust as necessary
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
