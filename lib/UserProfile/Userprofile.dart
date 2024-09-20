import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:travel/UserProfile/Rides/all_booked_rides.dart';
import 'package:travel/UserProfile/Rides/all_posted_rides.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:travel/api/api.dart';
import '../auth/login.dart';
import 'package:travel/UserProfile/License/verifylicenese.dart';
import 'package:travel/UserProfile/profilesetting.dart';
import 'package:travel/UserProfile/userinfo.dart';
import 'package:travel/UserProfile/vechiledetails.dart';


class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  File? _selectedImage;
  XFile? _profileImageFile;
  final ImagePicker _picker = ImagePicker();
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  bool _isNewUser = false; // Added flag to check if the user is new
  bool _isLoadingImage =
      true; // To show loading indicator while the image is loading

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadUserData();
    _fetchProfilePhoto();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserName = prefs.getString('userName') ?? 'Loading...';
    final storedUserEmail = prefs.getString('userEmail') ?? 'Loading...';
    final storedIsNewUser = prefs.getBool('isNewUser') ?? true;

    setState(() {
      _userName = storedUserName;
      _userEmail = storedUserEmail;
      _isNewUser = storedIsNewUser;
    });
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      print('No auth token found');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${API.api1}/user'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await prefs.setString('userName', data['uname'] ?? 'No name');
        await prefs.setString('userEmail', data['umail'] ?? 'No email');
        await prefs.setBool('isNewUser', data['profilePhoto'] == null);

        setState(() {
          _userName = data['uname'] ?? 'No name';
          _userEmail = data['umail'] ?? 'No email';
          _isNewUser = data['profilePhoto'] ==
              null; // Assume 'profilePhoto' is null for new users
        });
      } else {
        print('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';

    try {
      final response = await http.get(
        Uri.parse('${API.api1}/profile-photo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final uniqueFilename = '${Uuid().v4()}.jpg';
        final imagePath = path.join(directory.path, uniqueFilename);
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(response.bodyBytes);

        if (mounted) {
          setState(() {
            _profileImageFile = XFile(imageFile.path);
            _isLoadingImage = false; // Image is loaded, stop loading
          });
        }
      }
    } catch (error) {
      if (mounted && !_isNewUser) {
        Get.snackbar(
          'Error',
          'An error occurred: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() {
          _isLoadingImage = false; // Stop loading even on error
        });
      }
    }
  }

  Future<void> _uploadProfilePhoto(File image) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${API.api1}/upload-profile-photo'),
    );
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    request.files
        .add(await http.MultipartFile.fromPath('profile_photo', image.path));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        // Get the image file size
        final imageSize = image.lengthSync();
        final imageSizeInMB = imageSize / (1024 * 1024); // Convert bytes to MB

        Get.snackbar(
          'Upload Successful',
          'Image uploaded successfully. Size: ${imageSizeInMB.toStringAsFixed(2)} MB',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        _fetchProfilePhoto(); // Refresh profile photo
      } else if (!_isNewUser) {
        // Only show error if the user is not new
        Get.snackbar(
          'Error',
          'Failed to upload profile photo',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (error) {
      if (!_isNewUser) {
        // Only show error if the user is not new
        Get.snackbar(
          'Error',
          'An error occurred: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<File> _compressImage(File file) async {
    // Read the image file
    final image = img.decodeImage(file.readAsBytesSync());

    // Resize the image (example: to a width of 800px while maintaining aspect ratio)
    final resizedImage = img.copyResize(image!, width: 800);

    // Encode the image as JPEG and write it to a new file
    final directory = await getTemporaryDirectory();
    final compressedFile = File('${directory.path}/${Uuid().v4()}.jpg')
      ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 85));

    return compressedFile;
  }

  Future<void> _showConfirmationDialog(File image) async {
    // Compress the image before showing the dialog
    final compressedImage = await _compressImage(image);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(compressedImage,
                  height: 300, width: 300, fit: BoxFit.cover),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                setState(() {
                  _selectedImage = compressedImage;
                });
                Navigator.of(context).pop();
                _uploadProfilePhoto(
                    compressedImage); // Upload the compressed image
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
              if (_selectedImage != null)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title:
                      Text("Delete Image", style: TextStyle(color: Colors.red)),
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
        padding:
            const EdgeInsets.only(top: 30.0, left: 16, right: 16, bottom: 10),
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
                        : _profileImageFile != null
                        ? FileImage(File(_profileImageFile!.path))
                        : AssetImage('images/Userpfp.png') as ImageProvider,
                    child: _isLoadingImage && (_selectedImage != null || _profileImageFile != null)
                        ? Center(child: CircularProgressIndicator()) // Show loading only if an image is being loaded
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
              _userName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _userEmail,
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserInfo(),
                        ),
                      );
                    },
                  ),
                  CylindricalTile(
                    leadingIcon: Icons.directions_car,
                    title: 'Vehicle details',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VehicleDetails(),
                        ),
                      );
                    },
                  ),
                  CylindricalTile(
                    leadingIcon: Icons.history,
                    title: 'Your posted rides',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostedUserRides(),
                        ),
                      );
                    },
                  ),
                  CylindricalTile(
                    leadingIcon: Icons.bookmark_border,
                    title: 'Your booked rides',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllPostedRides(),
                        ),
                      );
                    },
                  ),
                  CylindricalTile(
                    leadingIcon: Icons.perm_contact_calendar_outlined,
                    title: 'Profile settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileSetting(),
                        ),
                      );
                    },
                  ),
                  CylindricalTile(
                    leadingIcon: Icons.credit_card,
                    title: 'Verify license',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VerifyLicense(fetchImageOnStart: true),
                        ),
                      );
                    },
                  ),
                  CylindricalTile(
                    leadingIcon: Icons.help_center_outlined,
                    title: 'Help',
                    onTap: () {},
                  ),
                  CylindricalTile(
                    leadingIcon: Icons.logout,
                    title: 'Log Out',
                    onTap: () async {
                      // Clear the token from SharedPreferences
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.remove('authToken');

                      // Navigate to LoginScreen and clear the navigation stack
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                            (route) => false, // This will remove all the previous routes
                      );
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
  return Padding(
    padding: const EdgeInsets.only(top: 10.0),
    child: Container(
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
    ),
  );
}
