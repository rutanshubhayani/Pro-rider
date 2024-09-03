import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel/license1.dart';
import 'package:travel/profilesetting.dart';
import 'package:travel/userinfo.dart';
import 'package:travel/vechiledetails.dart';
import 'login.dart';
import 'new.dart';
import 'package:http/http.dart' as http;

class UserProfile extends StatefulWidget {
  final String userName1; // UserName passed from the previous screen
  final String usermail; // Usermail passed from the previous screen
  final String unumber; // Usermail passed from the previous screen
  final String uaddress; // Usermail passed from the previous screen

  const UserProfile({Key? key, required this.userName1, required this.usermail, required this.unumber, required this.uaddress}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();


  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedImage = await _picker.pickImage(source: source);
      if (pickedImage != null) {
        _showConfirmationDialog(File(pickedImage.path));
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _showConfirmationDialog(File image) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(image, height: 300, width: 300, fit: BoxFit.cover),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                setState(() {
                  _selectedImage = image; // Confirm the image selection
                });
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              if (_selectedImage != null) // Show delete option only if an image is selected
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text("Delete Image", style: TextStyle(color: Colors.red)),
                  onTap: () {
                    _removeImage();
                    Navigator.of(context).pop();
                  },
                ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text("Camera"),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Gallery"),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String get userName => widget.userName1; // Getter for userName
  String get usermail => widget.usermail; // Getter for usermail
  String get unumber => widget.unumber; // Getter for usermail
  String get uaddress => widget.uaddress; // Getter for usermail


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 80.0, left: 16, right: 16, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _showImageOptions,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : AssetImage('images/Userpfp.png') as ImageProvider,
                    child: _selectedImage == null
                        ? CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('images/Userpfp.png'),
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(5.0),
                      child: Icon(
                        Icons.add_a_photo_rounded,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              userName, // Use the getter here
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              usermail,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  SizedBox(height: 30),
                  CylindricalTile(
                    leadingIcon: Icons.info_outline_rounded,
                    title: 'Profile Information',
                    onTap: () {
                      final String uname = userName; // Use the getter here
                      final String umail = usermail;
                      final String umobilenumber = unumber;
                      final String useraddress = uaddress ;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserInfo(uname: uname, usermail: umail, umobilenumber: umobilenumber, uaddress: useraddress,),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  CylindricalTile(
                    leadingIcon: Icons.directions_car,
                    title: 'Vehicle details',
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => VehicleDetails()));
                    },
                  ),
                  SizedBox(height: 10,),
                  CylindricalTile(
                    leadingIcon: Icons.perm_contact_calendar_outlined,
                    title: 'Profile settings',
                    onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ProfileSetting()));
                    },
                  ),
                  SizedBox(height: 10,),
                  CylindricalTile(
                    leadingIcon: Icons.credit_card,
                    title: 'Verify license',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoPickerScreen(fetchImageOnStart: true),
                        ),
                      );
                    },
                  ),


                  SizedBox(height: 10,),
                  CylindricalTile(
                    leadingIcon: Icons.help_center_outlined,
                    title: 'Help',
                    onTap: (){},
                  ),
                  SizedBox(height: 10,),
                  CylindricalTile(
                    leadingIcon: Icons.logout,
                    title: 'Log Out',
                    onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginScreen()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget CylindricalTile({
  required IconData leadingIcon,
  required String title,
  required VoidCallback onTap,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30.0),
      border: Border.all(color: Colors.grey),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 7,
          offset: Offset(1, 10),
        ),
      ],
    ),
    child: ListTile(
      leading: Icon(leadingIcon),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    ),
  );
}
