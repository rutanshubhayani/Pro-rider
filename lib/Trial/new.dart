//verify screen with image rotation display

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VerifyRotateLicense extends StatefulWidget {
  const VerifyRotateLicense({Key? key}) : super(key: key);

  @override
  State<VerifyRotateLicense> createState() => _VerifyRotateLicenseState();
}

class _VerifyRotateLicenseState extends State<VerifyRotateLicense> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _photoUploaded = false; // Flag to track if photo is uploaded
  double _rotationAngle = 0; // Track rotation angle

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _photoUploaded = false; // Reset flag when image is removed
    });
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedImage = await _picker.pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
          _photoUploaded = true; // Set flag when image is selected
          _rotationAngle = 0; // Reset rotation angle when new image is selected
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _rotateImage() {
    setState(() {
      _rotationAngle += 90;
    });
  }

  Widget _buildRotatedImage() {
    if (_selectedImage != null) {
      return RotatedBox(
        quarterTurns: (_rotationAngle ~/ 90) % 4,
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Icon(
                Icons.credit_card,
                color: Colors.grey,
                size: 50,
              ),
            ),
            Text(
              'Add Photo',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify License'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SafeArea(
                      child: Wrap(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.photo_camera),
                            title: Text("Camera"),
                            onTap: () {
                              _getImage(ImageSource.camera);
                              Navigator.of(context).pop();
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.photo_library),
                            title: Text("Gallery"),
                            onTap: () {
                              _getImage(ImageSource.gallery);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      height: 200,
                      width: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _buildRotatedImage(),
                    ),
                    if (_selectedImage != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _removeImage,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                            ),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    if (_selectedImage != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: GestureDetector(
                          onTap: _rotateImage,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                            ),
                            child: Icon(
                              Icons.rotate_left,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_photoUploaded) {
                      // Show the snackbar with "Photo Submitted" message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Photo Submitted',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          backgroundColor:
                          Color(0xFF3d5a80), // Background color of the snackbar
                          behavior:
                          SnackBarBehavior.floating, // Makes the snackbar float above content
                        ),
                      );
                    } else {
                      // Show the snackbar with "Upload a photo first" message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Upload a photo first',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors
                              .red, // Example background color for error message
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3d5a80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
            // Display the uploaded image if _photoUploaded is true
            if (_photoUploaded && _selectedImage != null)
              Container(
                padding: EdgeInsets.all(10),
                height: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20), // Adjust the circular radius as needed
                  child: _buildRotatedImage(),
                ),
              )

          ],
        ),
      ),
    );
  }
}
