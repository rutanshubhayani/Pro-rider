import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:travel/Userprofile.dart';
import 'package:travel/find.dart';
import 'package:travel/register.dart';
import 'package:travel/userinfo.dart';
import 'api.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  Future<void> _login() async {
    final String email = _emailicontroller.text.trim();
    final String password = _passwordcontroller.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please enter both email and password',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

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
        if (responseData.containsKey('user')) {
          final user = responseData['user'];
          print('$user');
          if (user.containsKey('uid')) {
            final uid = user['uid'];
            print('$uid');
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
          String uname = user['uname'] ?? 'User';
          String umail = user['umail'] ?? 'User';
          String umobilenumber = user['umobilenumber'].toString() ?? 'User';
          String uaddress = user['uaddress'] ?? 'User';

          Get.snackbar('Success', 'Login successful', snackPosition: SnackPosition.BOTTOM);
          Get.to(() => UserProfile(userName1: uname, usermail : umail, unumber : umobilenumber, uaddress : uaddress)); // Pass details to UserProfile
          Get.to(() => FindScreen(userName: uname, usermail: umail,unumber : umobilenumber, uaddress : uaddress)); // Pass details to FindScreen
        } else {
          Get.snackbar('Error', 'Unexpected response format', snackPosition: SnackPosition.BOTTOM);
        }
      } else if (response.statusCode == 401) {
        Get.snackbar('Error', 'Invalid email or password', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'Login failed', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (error) {
      Get.snackbar('Error', 'An error occurred. Please try again.$error',
          snackPosition: SnackPosition.BOTTOM);
      print(error);
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      SizedBox(height: 16),
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
                            onPressed: () {
                              setState(() {
                                _obsecureText = !_obsecureText;
                              });
                            },
                            icon: Icon(
                              _obsecureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 20.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Get.to(ForgotPassword());
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
