import 'dart:convert';
import 'dart:io'; // Import dart:io for connectivity checks
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel/auth/password.dart';
import 'package:travel/Find/find.dart';
import 'package:travel/auth/register.dart';
import 'package:travel/UserProfile/userinfo.dart';

import '../api/api.dart';
import '../widget/internet.dart';
import '../widget/HttpHandler.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late HttpHandler hs;
  bool _obsecureText = true; // For password visibility
  TextEditingController _emailicontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();

  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();




  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    hs = HttpHandler(ctx: context);
    chkDB();
  }


  void chkDB() async {
    bool chki = await hs.netconnection(true);
    if (chki == false) {
      final res =  Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnInternet()),
              (Route<dynamic> route) => false);

      if (res != null && res.toString() == 'done') {
        chkDB();
        return;
      }
    }
  }


  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      // If the form is not valid, return
      return;
    }

    final String email = _emailicontroller.text.trim();
    final String password = _passwordcontroller.text.trim();

    try {
      final response = await http.post(
        Uri.parse('${API.api1}/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'umail': email,
          'upassword': password,
        }),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey('token')) {
          final token = responseData['token'];
          final user = responseData['user'];

          // Print user information for debugging
          print('User: $user');
          print('Token: $token');
          if (user.containsKey('uid')) {
            final uid = user['uid'].toString();
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('userId', uid.toString()); // Save UID
            // Verify saved data
            print('Saved userId: ${prefs.getString('userId')}');
          }

          if (user.containsKey('uid')) {
            final userid = user['uid'];
            print('$userid');
          }
          if (user.containsKey('uname')) {
            final uname = user['uname'];
            print('$uname');
          }
          if (user.containsKey('umail')) {
            final umail = user['umail'];
            print('$umail');
          }
          if (user.containsKey('umobilenumber')) {
            final umobilenumber = user['umobilenumber'];
            print('$umobilenumber');
          }
          if (user.containsKey('uaddress')) {
            final uaddress = user['uaddress'];
            print('$uaddress');
          }
          if (user.containsKey('profile_photo')) {
            final profile_photo = user['profile_photo'];
            print('$profile_photo');
          }

          // Extract user details
          String uname = user['uname'] ?? 'User';
          String umail = user['umail'] ?? 'User';
          String umobilenumber = user['umobilenumber']?.toString() ?? 'User';
          String uaddress = user['uaddress'] ?? 'User';
          String uid = user['uid']?.toString() ?? 'User';

          // Store token in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', token);
          await prefs.setString('userId', uid); // Save uid separately

          Get.snackbar('Success', 'Login successful', snackPosition: SnackPosition.BOTTOM);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => FindScreen()
              ),
              (route) => false);
        } else {
          Get.snackbar('Error', 'Unexpected response format', snackPosition: SnackPosition.BOTTOM);
        }
      } else if (response.statusCode == 401) {
        Get.snackbar('Error', 'Invalid email or password', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'Login failed', snackPosition: SnackPosition.BOTTOM);
        print(response.body);
      }
    } catch (error) {
      Get.snackbar('Error', 'An internal Server error occurred. Please try again. ',
          snackPosition: SnackPosition.BOTTOM);
      print(error);
    }
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
                        'Welcome to',
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
                          color: Color(0xFF51737A),
                        ),
                      ),
                      SizedBox(height: 40),
                      TextFormField(
                        controller: _emailicontroller,
                        focusNode: _emailFocusNode,
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
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_passwordFocusNode);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordcontroller,
                        focusNode: _passwordFocusNode,
                        obscureText: _obsecureText,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obsecureText
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obsecureText = !_obsecureText;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF51737A),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          _login();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Get.to(() => ForgotPassword());
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: Color(0xFF51737A)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login, // Call the _login function on button press
                          child: Text(
                            'Login',
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 7,
                            backgroundColor: Color(0xFF51737A),
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text('Don\'t have an account?'),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterScreen()),
                          );
                        },
                        child: Text(
                          'Create Account',
                          style: TextStyle(color: Color(0xFF51737A)),
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
