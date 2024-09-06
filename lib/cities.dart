import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class cities extends StatefulWidget {
  @override
  _citiesState createState() => _citiesState();
}

class _citiesState extends State<cities> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Destination Input Widget'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DestinationInputWidget(),
      ),
    );
  }
}

class DestinationInputWidget extends StatefulWidget {
  @override
  _DestinationInputWidgetState createState() => _DestinationInputWidgetState();
}

class _DestinationInputWidgetState extends State<DestinationInputWidget> {
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController stopsController = TextEditingController();
  final FocusNode desinationFocusNode = FocusNode();
  final FocusNode stopsFocusNode = FocusNode();
  bool showContainer = false;
  List<dynamic> suggestions = [];

  @override
  void dispose() {
    destinationController.dispose();
    stopsController.dispose();
    desinationFocusNode.dispose();
    stopsFocusNode.dispose();
    super.dispose();
  }

  // Fetch cities from API
  Future<List<dynamic>> fetchCities(String query) async {
    try {
      final response = await http.get(Uri.parse(
          'http://202.21.32.153:8081/cities')); // Replace with your API URL

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

  void _updateSuggestions(String pattern) async {
    if (pattern.isNotEmpty) {
      setState(() {
        showContainer = true;
      });
      try {
        suggestions = await fetchCities(pattern);
        setState(() {}); // Update the UI with new suggestions
      } catch (e) {
        print('Error updating suggestions: $e');
      }
    } else {
      setState(() {
        showContainer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: destinationController,
          focusNode: desinationFocusNode,
          decoration: InputDecoration(
            filled: true,
            prefixIcon: Icon(Icons.location_on),
            hintText: 'Destination Location',
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            _updateSuggestions(value);
          },
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(stopsFocusNode);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter destination location';
            }
            return null;
          },
        ),
        if (showContainer)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0XFFe6e0e9),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text('${suggestion['city']}, ${suggestion['pname']}'),
                  onTap: () {
                    destinationController.text =
                    '${suggestion['city']}, ${suggestion['pname']}';
                    setState(() {
                      showContainer =
                      false; // Hide the suggestions after selection
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
