import 'package:flutter/material.dart';
import 'package:travel/login.dart';
import 'package:travel/register.dart';



class First extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0xFFf0f7f9),
      body: Stack(
        children: [
        Positioned(
        top: 20,
        right: -470,
        child: Container(
          height: 200,
          width: 600,
          decoration: BoxDecoration(
            color:Color(0xFFfefffa),
            border: Border.all(color:Color(0xFFfefffa), width: 0.0),
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
            color:Color(0xFFfefffa),
            border: Border.all(color:Color(0xFFfefffa), width: 0.0),
            borderRadius: BorderRadius.all(Radius.elliptical(90, 45)),
          ),
        ),
      ),
      Positioned(
        bottom:170,
        left: 50,
        child: Container(
          height: 150,
          width: 140,
          decoration: BoxDecoration(
            color:Color(0xFFfefffa),
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        top:90,
        left: -100,
        child: Container(
          height: 270,
          width: 270,
          decoration: BoxDecoration(
            color:Color(0xFFfefffa),

            shape: BoxShape.circle,
          ),
        ),
      ),
       Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Image.asset(
              'images/main.png',
              // Add your image to assets and update the path
              height: 500,
            ),

            Text(
              "Let's Travel With Everyone",
              style: TextStyle(
                fontSize: 20,
                color:Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "Find your destination partner,\nAnd take a ride with them!",
              style: TextStyle(
                fontSize: 16,
                color:Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
                // Handle login action
              },
              child: Text('Log in',
              style: TextStyle(
                color: Colors.white,
              ),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF51737A),
                minimumSize: Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => RegisterScreen()));
                // Handle create account action
              },
              child: Text('Create Account'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFfefffa),
                foregroundColor: Colors.grey[700],
                minimumSize: Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                 // side: BorderSide(color: Colors.grey[700]!),
                ),
              ),
            ),
            Spacer(),
            Spacer(),
          ],
        ),
       ),
      ],
      ),
    );
  }
}
