import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel/UserProfile/Userprofile.dart';
import 'package:travel/auth/login.dart';
import 'dart:convert';
import 'package:travel/auth/verifyotp.dart';

import '../api/api.dart'; // For converting response to JSON


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
  final TextEditingController _currentPasswordController =
  TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

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
          Uri.parse('${API.api1}/changepassword'),
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
          // Clear the token from SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('authToken');

          Get.offAll(() => LoginScreen());
        } else if (response.statusCode == 401) {
          // Handle incorrect current password
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Current password is incorrect')),
          );
        } else {
          print('Error: ${response.body}');
          final responseBody = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: Unknown error')),
          );
          print(responseBody);
        }
      } catch (e) {
        print(e);
        // Handle any exceptions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error occurred')),
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
                      _isCurrentPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
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
                      _isNewPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
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
                  List<String> errors = [];

                  if (value == null || value.isEmpty) {
                    return 'Please enter your password'; // Only show this for empty passwords
                  } else {
                    if (value.length < 8) {
                      errors.add('• 8 characters long');
                    }
                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      errors.add('• One uppercase letter');
                    }
                    if (!RegExp(r'[a-z]').hasMatch(value)) {
                      errors.add('• One lowercase letter');
                    }
                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      errors.add('• One digit');
                    }
                    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      errors.add('• One special character');
                    }
                    /* // Check for only numbers
                          if (RegExp(r'^[0-9]+$').hasMatch(value)) {
                            errors.add('• At least one uppercase letter, one lowercase letter, and one special character');
                          }*/
                  }

                  if (errors.isNotEmpty) {
                    return 'Password must contain at least:\n' + errors.join('\n'); // Only show the common error message if there are other errors
                  }
                  return null; // No errors
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
                    backgroundColor: Color(0xFF3d5a80),
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
  final String _apiUrl = '${API.api1}/forgot-password';
  bool _isLoading = false; // Loading state

  Future<void> _sendForgotPasswordRequest() async {
    final email = _emailController.text;

    if (email.isEmpty) {
      // Show error if email is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an email address')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Set loading to true
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'umail': email}),
      );

      if (response.statusCode == 200) {
        // Navigate to the OTP verification screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Verifyotp(email: email),
          ),
        );
      } else if (response.statusCode == 404) {
        // Show error message based on response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email not registered.')),
        );
      } else {
        // Show error message based on response
        final errorMessage = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      print(e);

      // Show error message if request fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: Server Error')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false
      });
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
                onPressed: _isLoading ? null : _sendForgotPasswordRequest,
                child: _isLoading
                    ? CircularProgressIndicator(
                  color: Colors.white,
                )
                    : Text(
                  'Send OTP',
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 7,
                  backgroundColor: Color(0xFF3d5a80),
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
