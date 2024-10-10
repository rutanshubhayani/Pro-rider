import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:travel/api/api.dart';
import 'dart:convert';
import 'package:travel/auth/login.dart';

class Verifyotp extends StatefulWidget {
  final String email;

  const Verifyotp({super.key, required this.email});

  @override
  State<Verifyotp> createState() => _VerifyotpState();
}

class _VerifyotpState extends State<Verifyotp> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isOtpVerified = false;
  bool _isPasswordVisible = false;
  bool _isButtonDisabled = false; // Variable to manage button state

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
    _otpController.addListener(_otpFieldListener); // Listen to OTP field changes
  }

  @override
  void dispose() {
    _otpController.removeListener(_otpFieldListener); // Clean up listener
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _otpFieldListener() {
    if (_isButtonDisabled) {
      setState(() {
        _isButtonDisabled = false; // Enable button if OTP field is edited
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify OTP'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  readOnly: true,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Verify OTP',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text('Please check your provided email'),
                SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: TextFormField(
                    maxLength: 6,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'Enter OTP',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'OTP cannot be empty';
                      }
                      if (value.length != 6) {
                        return 'Enter a valid 6-digit OTP';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    'Note: OTP will be valid for only 5 minutes',
                    style: TextStyle(
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isButtonDisabled ? null : _verifyOtp, // Disable button if needed
                    child: Text(
                      'Verify OTP',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                      ),
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
                SizedBox(height: 20),
                if (_isOtpVerified) ...[
                  Text(
                    'New Password',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'Enter New Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      List<String> errors = [];

                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
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
                      }

                      if (errors.isNotEmpty) {
                        return 'Password must contain at least:\n' + errors.join('\n');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Confirm New Password',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'Confirm New Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _resetPassword,
                      child: Text(
                        'Confirm New Password',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                        ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _verifyOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isOtpVerified = true;
        _isButtonDisabled = true; // Disable button after click
      });
    }
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final String email = _emailController.text;
      final String otp = _otpController.text;
      final String newPassword = _passwordController.text;

      final url = Uri.parse('${API.api1}/reset-password');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'umail': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset successfully')),
        );
        Get.to(LoginScreen());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reset password: ${response.body}')),
        );
      }
    }
  }
}
