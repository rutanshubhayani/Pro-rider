import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel/home.dart';
import 'package:travel/home/first.dart';
import 'package:travel/Find/find.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel/widget/splashscreen.dart';
import 'UserProfile/License/verifylicenese.dart';
import 'UserProfile/vechiledetails.dart';

void main() {
  /*Get.put(VehicleDetailsController()); // or Get.lazyPut(() => VehicleDetailsController());
  Get.put(ImageUploadController()); // or Get.lazyPut(() => VehicleDetailsController());*/
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
