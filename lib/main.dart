import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel/first.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
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
      home: First(),
    );
  }
}


