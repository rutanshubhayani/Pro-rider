import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';

import 'package:travel/Find/find.dart';

import '../api/api.dart';


class RideEmailVerify extends StatefulWidget {
  @override
  State<RideEmailVerify> createState() => _RideEmailVerifyState();
}

class _RideEmailVerifyState extends State<RideEmailVerify> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';

    if (token.isEmpty) {
      print('No auth token found');
      setState(() {
        _isLoading = false;
      });
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
          _emailController.text = data['umail'] ?? '';
          _isLoading = false;
        });
      } else {
        print('Failed to load user data: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text;
      final url = Uri.parse('${API.api1}/verify-ride');

      try {
        final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': email,
          }),
        );

        if (response.statusCode == 200) {
          // OTP sent successfully

          // Pass email to OTPVerificationScreen
          Get.to(() => RideOTPVerify(email: email));
        } else {
          print(response.body);
          // Handle error response
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send OTP: Internal server error'), behavior: SnackBarBehavior.fixed),
          );
        }
      } catch (e) {
        // Handle exception
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
        child: _isLoading
            ? _buildShimmer() // Show shimmer effect while loading
            : _buildForm(), // Show form when data is loaded
      ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 2,
            child: Container(
              height: 25,
              width: 200,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 15),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 2,
            child: Container(
              height: 16,
              width: 250,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 10),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 2,
            child: Container(
              height: 50,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let\'s verify your mail',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Having a valid mail is a reliable option to verify for further ride.',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'OTP will be sent to below email address.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            readOnly: true,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.mail),
              hintText: 'Enter valid mail',
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onFieldSubmitted: (mail) {},
          ),
          SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _sendOtp();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sending OTP...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Send code to mail',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2e2c2f),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Only the drivers you book with will receive your email address',
            style: TextStyle(
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}















class RideOTPVerify extends StatefulWidget {
  final String email;

  RideOTPVerify({required this.email});

  @override
  _RideOTPVerifyState createState() => _RideOTPVerifyState();
}

class _RideOTPVerifyState extends State<RideOTPVerify> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int? bookedSeats; // Variable to store the booked seats
  int? postATripId; // Variable to store the post_a_trip_id

  @override
  void initState() {
    super.initState();

    // Fetch the booked seats and post_a_trip_id from SharedPreferences
    _loadPreferences();

    for (int i = 0; i < 6; i++) {
      _otpControllers[i].addListener(() {
        String text = _otpControllers[i].text;
        if (text.length == 1) {
          // Move focus to next field when text is entered
          if (i < 5) {
            FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
          } else {
            FocusScope.of(context).unfocus(); // Hide keyboard when OTP is complete
            _verifyOTP();
          }
        }
      });
    }
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bookedSeats = prefs.getInt('bookedSeats');
      postATripId = prefs.getInt('post_a_trip_id'); // Retrieve post_a_trip_id
    });
    print('Loaded booked seats: $bookedSeats');
    print('Loaded post_a_trip_id: $postATripId'); // Print post_a_trip_id for debugging
  }




  Future<void> _verifyOTP() async {
    String otp = _otpControllers.map((controller) => controller.text).join();
    final otpUrl = Uri.parse('${API.api1}/verify-otp');
    final bookSeatsUrl = Uri.parse('${API.api1}/book-seat/${postATripId}');

    try {
      // Verify OTP
      final otpResponse = await http.post(
        otpUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'email': widget.email,
          'otp': otp,
          'post_a_trip_id': postATripId,
        }),
      );

      if (otpResponse.statusCode == 200) {
        // OTP verified successfully, now get the authToken from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final authToken = prefs.getString('authToken');

        if (authToken == null) {
          Get.snackbar('Error', 'Authentication token not found', snackPosition: SnackPosition.BOTTOM);
          return;
        }

        // Book seats
        final bookSeatsResponse = await http.post(
          bookSeatsUrl,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $authToken', // Use the authToken for authorization
          },
          body: jsonEncode(<String, dynamic>{
            'booked_seats': bookedSeats,
          }),
        );

        if (bookSeatsResponse.statusCode == 201) {
          Get.to(() => FindScreen());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ride booked successfully')),
          );
        } else {
          print('Failed to book seats: ${bookSeatsResponse.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to book seats: ${bookSeatsResponse.body}')),
          );
        }
      } else {
        print('Failed to verify OTP: ${otpResponse.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to verify OTP: ${otpResponse.body}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Confirm ride')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, bottom: 10),
                  child: Text(
                    'Enter OTP sent to your provided email.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Text(
                  'Enter provided OTP from email to schedule your memorable journey.',
                  style: TextStyle(
                      color: Colors.black54
                  ),
                ),
                /*if (bookedSeats != null) ...[
                  SizedBox(height: 20),
                  Text(
                    'Booked Seats: $bookedSeats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],*/
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 40,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none
                      ),
                      counterText: '',
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      if (value.isEmpty && index > 0) {
                        // Move focus to previous field if current field is empty
                        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                      } else if (value.length == 1 && index < 5) {
                        // Move focus to next field when text is entered
                        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                      }
                    },
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Row(
              children: [
                Text(
                  'Verifying OTP',
                  style: TextStyle(
                      color: Colors.black54
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _verifyOTP();
                },
                child: Text(
                  'Verify OTP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
