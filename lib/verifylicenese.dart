import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel/Licenese.dart';

class VerifyLicense extends StatefulWidget {
  const VerifyLicense({Key? key}) : super(key: key);

  @override
  State<VerifyLicense> createState() => _VerifyLicenseState();
}

class _VerifyLicenseState extends State<VerifyLicense> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _photoUploaded = false; // Flag to track if photo is uploaded
  double _rotationAngle = 0; // Track rotation angle
  bool _submitted = false; // Flag to track if form is submitted

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
    return Stack(
      children: [
        Container(
          height: 200,
          width: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: _selectedImage != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Transform.rotate(
              angle: _rotationAngle * (3.14 / 180),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
              ),
            ),
          )
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.credit_card,
                  color: Colors.grey,
                  size: 50,
                ),
                Text(
                  'Add Photo',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
        if (_photoUploaded && _submitted)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                Icons.verified,
                color: Colors.green,
                size: 20,
              ),
            ),
          ),
      ],
    );
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
            if (!_submitted) // Show image selection only if form is not submitted
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
                child: _submitted
                    ? SizedBox.shrink() // Hide submit button if form is submitted
                    : ElevatedButton(
                  onPressed: () {
                    if (_photoUploaded) {
                      // Navigate to the ImageScreen when form is submitted
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => License(
                            imageFile: _selectedImage!,
                          ),
                        ),
                      );
                      setState(() {
                        _submitted = true; // Mark form as submitted
                      });
                    } else {
                      // Show the snackbar with "Upload a photo first" message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Upload a photo first',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
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
                    backgroundColor: Color(0xFF2e2c2f),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
            // Display the uploaded image if _photoUploaded is true and form is submitted
            if (_submitted && _photoUploaded && _selectedImage != null)
              Container(
                padding: EdgeInsets.all(10),
                height: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _buildRotatedImage(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
