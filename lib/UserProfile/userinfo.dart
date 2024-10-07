import 'dart:io';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel/UserProfile/Userprofile.dart';
import 'package:travel/api/api.dart';
import 'dart:convert';
import 'package:travel/auth/verifyotp.dart'; // For converting response to JSON












class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  bool isEditing = false;
  bool isLoading = true;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  // FocusNodes for each text field
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _phoneFocusNode = FocusNode();
  FocusNode _addressFocusNode = FocusNode();

  // Key for the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';

    if (token.isEmpty) {
      print('No auth token found');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${API.api1}/user'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Log the full response for debugging
        print('User data: $data');

        setState(() {
          _nameController.text = data['uname'] ?? '';
          _emailController.text = data['umail'] ?? '';
          _phoneController.text = data['umobilenumber'].toString() ??
              ''; // Ensure this matches the key in API response
          _addressController.text = data['uaddress'] ??
              ''; // Ensure this matches the key in API response
          isLoading = false;
        });
      } else {
        print('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void toggleEditing() {
    setState(() {
      isEditing = !isEditing;
      if (isEditing) {
        FocusScope.of(context).requestFocus(_nameFocusNode);
      } else {
        FocusScope.of(context)
            .unfocus(); // Unfocus all fields when editing is disabled
      }
    });
  }

  void submitChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';

    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> updatedUserData = {
        'uname': _nameController.text,
        'umail': _emailController.text,
        'umobilenumber': _phoneController.text,
        'uaddress': _addressController.text,
      };

      try {
        final response = await http.put(
          Uri.parse('${API.api1}/updateUser'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token', // Ensure this is correct
          },
          body: json.encode(updatedUserData),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User updated successfully')),
          );
        } else if (response.statusCode == 404) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not found')),
          );
        } else {
          print('Response status: ${response.statusCode}');
          print('Response body: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error updating user: ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
        print('Exception: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }

      toggleEditing();
      FocusScope.of(context).requestFocus(_nameFocusNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Information'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Attach the form key
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLoading ? buildShimmerCard() : buildUserForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Color(0xFFE5E5E5),
      highlightColor: Color(0xFFF0F0F0),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 4,
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 4,
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 4,
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 4,
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        TextFormField(
          controller: _nameController,
          readOnly: !isEditing,
          focusNode: _nameFocusNode, // Set focus node
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            labelText: 'Name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFF51737A),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_emailFocusNode);
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          readOnly: !isEditing,
          focusNode: _emailFocusNode, // Set focus node
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFF51737A),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
            if (!emailRegex.hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_phoneFocusNode);
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          readOnly: !isEditing,
          focusNode: _phoneFocusNode, // Set focus node
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            labelText: 'Number',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFF51737A),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            if (value.length != 10) {
              return 'Phone number must be 10 digits long';
            }
            return null;
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_addressFocusNode);
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          readOnly: !isEditing,
          focusNode: _addressFocusNode, // Set focus node
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            labelText: isEditing ? 'Address (Optional)' : null,
            hintText: isEditing ? null : 'Address (Optional)',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isEditing ? submitChanges : toggleEditing,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  textAlign: TextAlign.center,
                  isEditing ? 'Update' : 'Edit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3.0),
                  child: Icon(
                    isEditing ? null : Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            style: ElevatedButton.styleFrom(
              elevation: 7,
              backgroundColor: Color(0xFF3d5a80),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}












