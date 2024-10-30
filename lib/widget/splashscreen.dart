import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home.dart';
import '../home/first.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final List<String> randomTexts = [
    'Find your ride.',
    'Easy travel.',
    'Find your ride partner.',
    'Book your trip effortlessly.',
    'Travel in comfort.',
    'Explore new destinations.',
    'Your journey begins here.',
    'Connecting you to the road.',
  ];

  late String selectedText;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    selectedText = randomTexts[Random().nextInt(randomTexts.length)];

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    startSplashScreen();
  }

  void startSplashScreen() async {
    _controller.forward(); // Start the animation
    await Future.delayed(Duration(seconds: 2)); // Wait for animation to finish
    _checkLoginStatus(); // Check login status after the delay
  }

  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (token != null && token.isNotEmpty) {
      // User is logged in, navigate to MyHomePage
      Get.off(() => MyHomePage());
    } else {
      // User is not logged in, navigate to FirstScreen
      Get.off(() => First());
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: _animation.value * 2, // Scale the logo
              child: Image.asset('images/blogo.png', width: 100, height: 100), // Change size as needed
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                textAlign: TextAlign.center,
                "\" $selectedText \"",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
