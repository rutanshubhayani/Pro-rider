import 'package:flutter/material.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Info'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
          //  crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   'Lets join in',
              //   style: TextStyle(
              //     fontSize: 24,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // Text(
              //   'Next Trip.',
              //   style: TextStyle(
              //     fontSize: 32,
              //     fontWeight: FontWeight.bold,
              //     color: Color(0xFF51737A),
              //   ),
              // ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent, // Make the text field transparent
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF51737A),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent, // Make the text field transparent
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF51737A), // Border color set to #51737a
                      width: 1.0, // Adjust border width as needed
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent, // Make the text field transparent
                  labelText: 'Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF51737A), // Border color set to #51737a
                      width: 1.0, // Adjust border width as needed
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
               SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  labelText: 'Address (optional)',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  )
                ),
              ),
              SizedBox(height: 16,),
              // Row(
              //   children: [
              //     Expanded(
              //       flex: 1,
              //       child: ElevatedButton(
              //         onPressed: () {},
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             Text(
              //               'Edit',
              //               style: TextStyle(fontSize: 17, color: Colors.black54),
              //             ),
              //             Icon(
              //               Icons.mode_edit_outline,
              //               size: 20,
              //               color: Colors.black54,
              //             ),
              //           ],
              //         ),
              //         style: ElevatedButton.styleFrom(
              //           padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           primary: Color(0xFFdfdfdf),
              //         ),
              //       ),
              //     ),
              //     Spacer(flex: 1),
              //   ],
              // ),
              ElevatedButton(
                onPressed: (){},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Edit',
                      style: TextStyle(fontSize: 17,color: Colors.black54),),
                    Icon(Icons.mode_edit_outline,size: 20,color: Colors.black54,),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 7, backgroundColor: Color(0xFFdfdfdf),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )


            ],
          ),
        ),
      ),
    );
  }
}

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_open),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                labelText: 'Confirm Password',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16,),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: (){},
                  child: Text('Confirm',
                  style: TextStyle(
                    fontSize: 17,color: Colors.black54
                  ),),
                style: ElevatedButton.styleFrom(
                  elevation: 7, backgroundColor: Color(0xFFdfdfdf),
                  padding: EdgeInsets.symmetric(horizontal: 40,vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}


class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password',),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                fillColor: Colors.transparent,
                filled: true,
                labelText: 'Enter Mail',
                prefixIcon: Icon(Icons.mail),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: (){},
                   child: Text('Send Link',
                style: TextStyle(
                    fontSize: 17,color: Colors.white
                ),),
        style: ElevatedButton.styleFrom(
          elevation: 7,
            backgroundColor: Color(0xFF2e2c2f),
          padding: EdgeInsets.symmetric(horizontal: 40,vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
            ),
          ],
        ),
      ),
    );
  }
}
