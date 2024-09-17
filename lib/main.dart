import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel/home/first.dart';
import 'package:travel/Find/find.dart';
import 'package:google_fonts/google_fonts.dart';
import 'UserProfile/License/verifylicenese.dart';
import 'UserProfile/vechiledetails.dart';

void main() {
  Get.put(VehicleDetailsController()); // or Get.lazyPut(() => VehicleDetailsController());
  Get.put(ImageUploadController()); // or Get.lazyPut(() => VehicleDetailsController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        fontFamily: GoogleFonts.rubik().fontFamily,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (token != null && token.isNotEmpty) {
      // User is logged in, navigate to FindScreen
      Get.off(() => FindScreen());
    } else {
      // User is not logged in, navigate to FirstScreen
      Get.off(() => First());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show a loader while checking login status
      ),
    );
  }
}