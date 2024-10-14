import 'package:flutter/material.dart';
import 'package:travel/auth/login.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api/api.dart';
import '../widget/configure.dart';


class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obsecureText = true;

  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _numbercontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final TextEditingController _confirmpasswordcontroller = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _numberFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmpasswordFocusNode = FocusNode();

  // Handle Form Submission
  void _submitForm() async {
    // Validate the form fields
    if (_formKey.currentState!.validate()) {
      // Prepare the data to be sent to the API
      final data = {
        'uname': _namecontroller.text,
        'umail': _emailcontroller.text,
        'umobilenumber': _numbercontroller.text,
        'upassword': _passwordcontroller.text,
        'uconfirmpassword': _confirmpasswordcontroller.text,
        // Assuming you want to include the phone number as well:
      };

      // Show a loading indicator while waiting for the response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registering...'),
          duration: Duration(seconds: 1),
        ),
      );

      try {
        // Make the POST request
        final response = await http.post(
          Uri.parse('${API.api1}/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );

        // Handle the response
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('User registered successfully'),
            ),
          );
          // Navigate to the login screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          print('Registration failed: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Registration failed.'),
            ),
          );
        }
      } catch (error) {
        // Handle network or other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Error: $error'),
          ),
        );
      }
    } else {
      // If form validation fails, set focus to the first empty field
      FocusScope.of(context).requestFocus(_getFirstEmptyFocusNode());
    }
  }

  // Helper method to get the first empty FocusNode
  FocusNode _getFirstEmptyFocusNode() {
    if (_namecontroller.text.isEmpty) {
      return _nameFocusNode;
    }
    if (_emailcontroller.text.isEmpty) {
      return _emailFocusNode;
    }
    if (_numbercontroller.text.isEmpty) {
      return _numberFocusNode;
    }
    if (_passwordcontroller.text.isEmpty) {
      return _passwordFocusNode;
    }
    if (_confirmpasswordcontroller.text.isEmpty) {
      return _confirmpasswordFocusNode;
    }
    // If no fields are empty, return a default focus node (could be null or a dummy node)
    return FocusNode();
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _numberFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmpasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 20,
            right: -470,
            child: Container(
              height: 200,
              width: 600,
              decoration: BoxDecoration(
                color: Color(0xFFf0f7f9),
                border: Border.all(color: Color(0xFFf0f7f9), width: 0.0),
                borderRadius: BorderRadius.all(Radius.elliptical(90, 45)),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            right: -490,
            child: Container(
              height: 200,
              width: 650,
              decoration: BoxDecoration(
                color: Color(0xFFf0f7f9),
                border: Border.all(color: Color(0xFFf0f7f9), width: 0.0),
                borderRadius: BorderRadius.all(Radius.elliptical(90, 45)),
              ),
            ),
          ),
          Positioned(
            bottom: 170,
            left: 50,
            child: Container(
              height: 150,
              width: 140,
              decoration: BoxDecoration(
                color: Color(0xFFf0f7f9),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 90,
            left: -100,
            child: Container(
              height: 270,
              width: 270,
              decoration: BoxDecoration(
                color: Color(0xFFf0f7f9),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Let\'s join in',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Prorider',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 40),
                      TextFormField(
                        controller: _namecontroller,
                        focusNode: _nameFocusNode,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: kPrimaryColor,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (name) {
                          FocusScope.of(context).requestFocus(_emailFocusNode);
                          print("Name ########################################## $name");
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailcontroller,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: kPrimaryColor,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (mail) {
                          FocusScope.of(context).requestFocus(_numberFocusNode);
                          print("Email ========================================== $mail");
                        },
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
                      ),
                      SizedBox(height: 16),
                      IntlPhoneField(
                        keyboardType: TextInputType.number,
                        disableLengthCheck: true,
                        initialCountryCode: 'CA',
                        controller: _numbercontroller,
                        focusNode: _numberFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: kPrimaryColor,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (number) {
                          FocusScope.of(context).requestFocus(_passwordFocusNode);
                          print("Phone Number ------------------------------------------- ${number}");
                        },
                        validator: (value) {
                          if (value == null || value.number == null || value.number.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.number.length < 10 || value.number.length > 10) {
                            return 'Phone number must be 10 digits long';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordcontroller,
                      focusNode: _passwordFocusNode,
                      obscureText: _obsecureText,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obsecureText = !_obsecureText;
                            });
                          },
                          icon: Icon(
                            _obsecureText ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        List<String> errors = [];

                        if (value == null || value.isEmpty) {
                          return 'Please enter your password'; // Only show this for empty passwords
                        } else {
                          if (value.length < 8) {
                            errors.add('• At least 8 characters long');
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
                    ),

                                          SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmpasswordcontroller,
                        focusNode: _confirmpasswordFocusNode,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordcontroller.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: Text(
                            'Register',
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 7,
                            backgroundColor: kPrimaryColor,
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text('Already have an account?'),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: Text(
                          'Log In',
                          style: TextStyle(color: kPrimaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
