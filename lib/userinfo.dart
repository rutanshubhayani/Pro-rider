import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel/Userprofile.dart';
import 'package:travel/api.dart';
import 'package:travel/profilesetting.dart';
import 'dart:convert';
import 'package:travel/verifyotp.dart'; // For converting response to JSON



class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  bool isEditing = false;
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

    const apiUrl = 'http://202.21.32.153:8081/user';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
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
          _phoneController.text = data['umobilenumber'].toString() ?? '';  // Ensure this matches the key in API response
          _addressController.text = data['uaddress'] ?? '';      // Ensure this matches the key in API response
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
        FocusScope.of(context).unfocus();  // Unfocus all fields when editing is disabled
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
          Uri.parse('http://202.21.32.153:8081/updateUser'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',  // Ensure this is correct
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
            SnackBar(content: Text('Error updating user: ${response.reasonPhrase}')),
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
                SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  readOnly: !isEditing,
                  focusNode: _nameFocusNode,  // Set focus node
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
                  focusNode: _emailFocusNode,  // Set focus node
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
                  focusNode: _phoneFocusNode,  // Set focus node
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
                  focusNode: _addressFocusNode,  // Set focus node
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
                      backgroundColor: Color(0xFF2e2c2f),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}









class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  FocusNode newPasswordFocusNode = FocusNode();
  FocusNode currentPasswordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    if (value == _currentPasswordController.text) {
      return 'New password cannot be the same as current password';
    }
    return null;
  }

  String? _validateAllPasswords(String? value) {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword == newPassword || currentPassword == confirmPassword) {
      return 'All passwords cannot be the same';
    }
    return null;
  }

  Future<void> _changePassword() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';

    if (_formKey.currentState!.validate()) {
      final currentPassword = _currentPasswordController.text;
      final newPassword = _newPasswordController.text;
      final confirmPassword = _confirmPasswordController.text;

      try {
        final response = await http.post(
          Uri.parse('http://202.21.32.153:8081/changepassword'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'currentPassword': currentPassword,
            'newPassword': newPassword,
            'confirmPassword': confirmPassword,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password changed successfully')),
          );
          _newPasswordController.clear();
          _currentPasswordController.clear();
          _confirmPasswordController.clear();
          Get.to(UserProfile());
        } else {
          final responseBody = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${responseBody['message'] ?? 'Unknown error'}')),
          );
          print(responseBody);
        }
      } catch (e) {
        // Handle any exceptions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exception: $e')),
        );
        print(e);
      }
    }
  }

  @override
  void dispose() {
    newPasswordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    currentPasswordFocusNode.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                focusNode: currentPasswordFocusNode,
                controller: _currentPasswordController,
                keyboardType: TextInputType.visiblePassword,
                obscureText: !_isCurrentPasswordVisible,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock_open),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isCurrentPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: _validatePassword,
                onEditingComplete: () {
                  FocusScope.of(context).requestFocus(newPasswordFocusNode);
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                focusNode: newPasswordFocusNode,
                controller: _newPasswordController,
                keyboardType: TextInputType.visiblePassword,
                obscureText: !_isNewPasswordVisible,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isNewPasswordVisible = !_isNewPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    return 'Password must contain at least one uppercase letter';
                  }
                  if (!RegExp(r'[a-z]').hasMatch(value)) {
                    return 'Password must contain at least one lowercase letter';
                  }
                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Password must contain at least one digit';
                  }
                  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                    return 'Password must contain at least one special character';
                  }
                  return null;
                },
                onEditingComplete: () {
                  FocusScope.of(context).requestFocus(confirmPasswordFocusNode);
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                focusNode: confirmPasswordFocusNode,
                controller: _confirmPasswordController,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  final confirmValidation = _validateConfirmPassword(value);
                  if (confirmValidation != null) {
                    return confirmValidation;
                  }
                  return _validateAllPasswords(value);
                },
                onEditingComplete: () {
                  _changePassword();
                },
              ),
              SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _changePassword,
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 7,
                    backgroundColor: Color(0xFF2e2c2f),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}









class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final String _apiUrl = 'http://202.21.32.153:8081/forgot-password';

  Future<void> _sendForgotPasswordRequest() async {
    final email = _emailController.text;

    if (email.isEmpty) {
      // Show error if email is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an email address')),
      );
      return;
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sending OTP...'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'umail': email}),
      );

      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sent successfully')),
        );
        Navigator.push(context,
        MaterialPageRoute(builder: (context) => Verifyotp(email: email,)));
      } else {
        // Show error message based on response
        final errorMessage = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      // Show error message if request fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: $e')),
      );
      print('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                fillColor: Colors.transparent,
                filled: true,
                labelText: 'Enter Mail',
                prefixIcon: Icon(Icons.mail),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendForgotPasswordRequest,
                child: Text(
                  'Send OTP',
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 7,
                  backgroundColor: Color(0xFF2e2c2f),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
