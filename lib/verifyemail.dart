//Booking mail verification screen

import 'package:flutter/material.dart';

class EmailVerify extends StatefulWidget {
  const EmailVerify({super.key});

  @override
  State<EmailVerify> createState() => _EmailVerifyState();
}

class _EmailVerifyState extends State<EmailVerify> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10,left: 20,right: 20),
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
            SizedBox(
              height: 15,
            ),
            Text(
              'Having a valid mail is reliable option to verify for further ride.',
              style: TextStyle(
                  fontSize: 16,
            ),),
            SizedBox(height: 10,),
            Text(
              'Please enter your valid email address',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54
              ),
            ),
            SizedBox(height: 10,),
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.mail),
                hintText: 'Enter valid mail',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none
                )
              ),
            ),
            SizedBox(height: 15,),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: (){},
                  child: Text(
                      'Send code to mail',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16
                    ),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2e2c2f),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  )
                ),
              ),
            ),
            SizedBox(height: 15,),
            Text(
              'Only the drivers you book with will receive your email address',
              style: TextStyle(
                color: Colors.black54,
                fontStyle: FontStyle.italic
              ),
            ),
          ],
        ),
      ),
    );
  }
}
