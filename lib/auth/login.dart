import 'dart:convert';
import 'dart:io'; // Import dart:io for connectivity checks
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel/auth/password.dart';
import 'package:travel/Find/find.dart';
import 'package:travel/auth/register.dart';
import 'package:travel/UserProfile/userinfo.dart';
import 'package:travel/home.dart';

import '../api/api.dart';
import '../widget/configure.dart';
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
  List<Map<String, dynamic>> _conversations = [];
  IOWebSocketChannel? _channel;

  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();

  bool get isWebSocketConnected => _channel != null && _channel!.closeCode == null;

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    hs = HttpHandler(contx: context);
    check();
  }

  void check() async {
    bool chki = await hs.InternetConnection(true);
    if (chki == false) {
      final res = Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Internet()),
          (Route<dynamic> route) => false);

      if (res != null && res.toString() == 'done') {
        check();
        return;
      }
    }
  }


  void _connectToWebSocket() async {
    String socketUrl = 'ws://202.21.32.153:8081/socket'; // Replace with your socket URL
    _channel = IOWebSocketChannel.connect(socketUrl);

    print('Attempting to connect to WebSocket...');

    // Retrieve the token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token != null) {
      // Send the token to the server
      _channel!.sink.add(jsonEncode({'token': token}));
      print('Token sent: $token');
    } else {
      print('No token found, unable to send.');
    }

    _channel!.stream.listen(
          (message) {
        // print("Message received: $message");
        _handleIncomingMessage(message);
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed.');
      },
    );

    Future.delayed(Duration(milliseconds: 100), () {
      if (isWebSocketConnected) {
        print('WebSocket is connected.');
      } else {
        print('WebSocket is not connected.');
      }
    });
  }

  void _handleIncomingMessage(String message) async {
    print('Received message raw: $message');
    try {
      final parsedMessage = json.decode(message);
      print('Parsed message: $parsedMessage');

      // Retrieve the current user's ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? currentUserIdString = prefs.getString('userId');
      int? currentUserId = int.tryParse(currentUserIdString ?? '');
      if (currentUserId == null) {
        print('Error: Unable to parse user ID from SharedPreferences');
        return;
      }

      // Check if the incoming message has 'latest_messages'
      if (parsedMessage != null && parsedMessage.containsKey('latest_messages')) {
        List<dynamic> latestMessages = parsedMessage['latest_messages'];

        for (var msg in latestMessages) {
          int? senderId = int.tryParse(msg['from']?.toString() ?? '');
          int? recipientId = int.tryParse(msg['to']?.toString() ?? '');

          if (senderId != null && recipientId != null) {
            int otherUserId = (senderId == currentUserId) ? recipientId : senderId;
            _updateOrAddConversation(msg, otherUserId);
          }
        }

        // Update the state with new conversations
        setState(() {});
      } else {
        // Handle new direct messages
        int? senderId = int.tryParse(parsedMessage['from']?.toString() ?? '');
        int? recipientId = int.tryParse(parsedMessage['to']?.toString() ?? '');

        if (senderId != null && recipientId != null) {
          int otherUserId = (senderId == currentUserId) ? recipientId : senderId;
          _updateOrAddConversation(parsedMessage, otherUserId);
        }
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  void _updateOrAddConversation(Map<String, dynamic> msg, int userId) async {
    bool conversationExists = _conversations.any((conv) => conv['recipientId'] == userId);

    if (conversationExists) {
      for (var existingConversation in _conversations) {
        if (existingConversation['recipientId'] == userId) {
          setState(() {
            // Update existing conversation with the latest message
            existingConversation['lastMessage'] = msg['message'] ?? msg['content'];
            existingConversation['lastMessageUnread'] = !(msg['read'] ?? true);
            existingConversation['timestamp'] = msg['time'] ?? msg['formatted_time'];
          });
          break; // Break the loop after finding the conversation
        }
      }
    } else {
      Map<String, dynamic>? userDetails = await _fetchUserDetails(userId);
      String recipientUserName = userDetails?['uname'] ?? 'User $userId';
      String recipientUserImage = userDetails?['profile_photo'] ?? '';

      setState(() {
        // Add the new conversation to the list
        _conversations.insert(0, {
          'recipientId': userId,
          'recipientUserName': recipientUserName,
          'recipientUserImage': recipientUserImage,
          'lastMessage': msg['message'] ?? msg['content'],
          'lastMessageUnread': !(msg['read'] ?? true),
          'timestamp': msg['time'] ?? msg['formatted_time'],
        });
      });
    }

  }

  Future<Map<String, dynamic>?> _fetchUserDetails(int uid) async {
    final prefs = await SharedPreferences.getInstance();
    final String baseUrl = '${API.api1}/user-details/$uid'; // Your API endpoint

    try {
      final response = await http.get(Uri.parse(baseUrl), headers: {
        'Authorization': 'Bearer ${prefs.getString('authToken')}', // Assuming you are using token-based authentication
      });

      if (response.statusCode == 200) {
        print('User details: ${response.body}');
        return json.decode(response.body);
      } else {
        print('Failed to load user details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }


  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      // If the form is not valid, return
      return;
    }

    // Set loading to true
    setState(() {
      _isLoading = true;
    });

    final String email = _emailicontroller.text.trim();
    final String password = _passwordcontroller.text.trim();

    try {
      final response = await http
          .post(
            Uri.parse('${API.api1}/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'umail': email,
              'upassword': password,
            }),
          )
          .timeout(Duration(seconds: 10));
      // Reset loading state regardless of outcome
      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey('token')) {
          final token = responseData['token'];
          final user = responseData['user'];

          // Print user information for debugging
          print('User: $user');
          print('Token: $token');
          List<String> userKeys = [
            'uid',
            'uname',
            'umail',
            'umobilenumber',
            'uaddress',
            'profile_photo'
          ];
          for (String key in userKeys) {
            if (user.containsKey(key)) {
              print('${key}: ${user[key]}');
            }
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

          Get.snackbar('Success', 'Login successful',
              duration: Duration(seconds: 1),
              snackPosition: SnackPosition.BOTTOM);
          _connectToWebSocket();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
              (route) => false);
        } else {
          Get.snackbar('Error', 'Unexpected response format',
              snackPosition: SnackPosition.BOTTOM);
        }
      } else if (response.statusCode == 401) {
        Get.snackbar('Error', 'Invalid email or password',
            duration: Duration(seconds: 1),
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'Login failed',
            duration: Duration(seconds: 1),
            snackPosition: SnackPosition.BOTTOM);
        print(response.body);
      }
    } catch (error) {
      // Reset loading state on error
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
          'Error', 'An internal Server error occurred. Please try again. ',
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
                          color: kPrimaryColor,
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
                              color: kPrimaryColor,
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
                              color: kPrimaryColor,
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
                              style: TextStyle(color: kPrimaryColor),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _login, // Disable button when loading
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.white),
                                ),
                          style: ElevatedButton.styleFrom(
                            elevation: 7,
                            backgroundColor: kPrimaryColor,
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
