import 'package:flutter/material.dart';
import 'package:travel/login.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obsecureText = true;

  TextEditingController _namecontroller = TextEditingController();
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _numbercontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();
  TextEditingController _confirmpasswordcontroller = TextEditingController();

  FocusNode _nameFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _numberFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _confirmpasswordFocusNode = FocusNode();

  // Handle Form Submission
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Registration complete'),
      ));
    }
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
                        'Lets join in',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Next Trip.',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF51737A),
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
                              color: Color(0xFF51737A),
                              width: 20.0,
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
                              color: Color(0xFF51737A),
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
                            return 'Please enter your mail';
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter valid mail address';
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
                              color: Color(0xFF51737A),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (number) {
                          FocusScope.of(context).requestFocus(_passwordFocusNode);
                          print("Phone Number ------------------------------------------- $number");
                        },
                        validator: (value) {
                          if (value == null || value.number.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.number.length != 10) {
                            return 'Phone number must be at least 10 digits long';
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
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_confirmpasswordFocusNode);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
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
                              width: 20.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
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
                            backgroundColor: Color(0xFF51737A),
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
