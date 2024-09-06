import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel/Inbox.dart';
import 'package:travel/find.dart';
import 'package:travel/login.dart';
import 'package:travel/postrequest.dart';
import 'package:travel/posttrip.dart';
import 'package:travel/profilesetting.dart';
import 'package:get/get.dart';
import 'package:travel/trips.dart';
import 'Userprofile.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  HomeScreen({this.initialIndex = 0});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Set initial index if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(_currentIndex);
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavBarItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(index,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Container(
            height: 40,
            width: 40,
            child: GestureDetector(
              onTap: () {
               Get.to(UserProfile(),transition: Transition.leftToRight);
              },
              child: Image.asset(
                'images/blogo.png',
              ),
            ),
          ),
        ),
        actions: [
          OutlinedButton.icon(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FindScreen()),
              );
            },
            label: Text(
              'Find',
              style: TextStyle(color: Colors.black),
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          Inbox1(), // Index 0
          Trips(), // Index 1
          // UserProfile(), // Index 2
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white, // Background color of the bottom navigation bar
        height: kBottomNavigationBarHeight,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.to(() => PostTrip()); // Navigate to HomeScreen
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_car,size: 20,),
                    Text('Driver',style: TextStyle(fontSize: 14),),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0,bottom: 15),
              child: VerticalDivider(
                width: 1,
                color: Colors.grey, // Color of the divider
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.to(() => Inbox1()); // Navigate to HomeScreen
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox,size: 20,),
                    Text('Inbox',style: TextStyle(fontSize: 14),),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0,bottom: 15),
              child: VerticalDivider(
                width: 1,
                color: Colors.grey, // Color of the divider
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  _currentIndex = 2; // Set index for Trips screen
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trip_origin,size: 20,),
                    Text('Trips',style: TextStyle(fontSize: 14),),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0,bottom: 15),
              child: VerticalDivider(
                width: 1,
                color: Colors.grey, // Color of the divider
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.to(Postrequest());
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person,size: 20,),
                    Text('Passenger',style: TextStyle(fontSize: 14),),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/*
class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

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
        padding: const EdgeInsets.only(top: 80.0,left: 16,right: 16,bottom: 10),
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
                        : AssetImage('assets/Poparide.jpg') as ImageProvider,
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
              'User Name',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'abc@gmail.com',
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
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => UserInfo()));
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
                    onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => VerifyLicense()));
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
*/