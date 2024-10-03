import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel/widget/configure.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel/widget/Themeclass.dart';
import 'package:travel/auth/login.dart';
import 'HttpHandler.dart';
import 'Size.dart';
import '../Find/find.dart';

class OnInternet extends StatefulWidget {
  const OnInternet({Key? key}) : super(key: key);

  @override
  State<OnInternet> createState() => _OnInternetState();
}

class _OnInternetState extends State<OnInternet> {
  late KSize k;
  late HttpHandler hs;
  bool btnEdit = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: kbgColor,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    ThemeClass.setRotations();
    hs = HttpHandler(ctx: context);
  }

  void chkDB() async {
    setState(() {
      btnEdit = true;
      isLoading = true;
    });

    // Simulate a 5-second load process
    await Future.delayed(const Duration(seconds: 5));

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (token != null && token.isNotEmpty) {
      // Token exists, navigate to FindScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => FindScreen()),
            (Route<dynamic> route) => false,
      );
    } else {
      // Token does not exist, navigate to LoginScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }

    setState(() {
      btnEdit = false;
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    k = KSize(context, 0);
    return SafeArea(
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          width: k.w(100),
          height: (k.h(100) + MediaQuery.of(context).padding.top),
          padding: EdgeInsets.symmetric(horizontal: k.wd[5]),
          decoration: const BoxDecoration(
            color: kbgColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'images/no_internet.png',
                  width: k.w(100),
                  height: k.w(80),
                  fit: BoxFit.fill,
                ),
                SizedBox(
                  height: k.h(2),
                ),
                Center(
                  child: Text(
                    "Ooops!",
                    style: ThemeClass.setStyle(
                      fontSize: 26.kp,
                      fontWeight: FontWeight.w700,
                      textColor: textColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: k.h(1),
                ),
                Center(
                  child: Text(
                    "No internet connection. Please turn on internet connection to continue.",
                    textAlign: TextAlign.center,
                    style: ThemeClass.setStyle(
                      fontSize: 16.kp,
                      fontWeight: FontWeight.w400,
                      textColor: textColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: k.h(5),
                ),
                if (isLoading)
                  CircularProgressIndicator(
                    color: kPrimaryColor,
                  )
                else
                  Container(
                    width: k.w(100),
                    child: ElevatedButton(
                      onPressed: (btnEdit == false)
                          ? () {
                        chkDB();
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        elevation: 2,
                        padding: EdgeInsets.symmetric(
                            horizontal: k.w(5), vertical: k.h(1.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        "Try again",
                        textAlign: TextAlign.center,
                        style: ThemeClass.setStyle(
                          fontSize: 18.kp,
                          textColor: kbgColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.05,
                        ),
                      ),
                    ),
                  ),
                SizedBox(
                  height: k.h(5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
