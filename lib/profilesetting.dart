import 'package:flutter/material.dart';
import 'package:travel/userinfo.dart';
import 'Userprofile.dart';
import 'home.dart';

class ProfileSetting extends StatelessWidget {
  const ProfileSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Setting'),
      ),
      body: ListView(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CylindricalTile(
              leadingIcon: Icons.password,
              title: 'Change Password',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePassword()));
              },),
          ),
        ],
      ),
    );
  }
}

