import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel/UserProfile/License/verifylicenese.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import '../../api/api.dart';



class RejectedScreen extends StatefulWidget {
  final String imagePath;
  final bool fetchImageOnStart;

  RejectedScreen({this.fetchImageOnStart = true, required this.imagePath});

  @override
  _RejectedScreenState createState() => _RejectedScreenState();
}

class _RejectedScreenState extends State<RejectedScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  late Future<void> _fetchImageFuture;
  bool _isUploading = false; // Variable to track upload state
  String? _storedImagePath; // To hold the path of the stored image


  @override
  void initState() {
    super.initState();
    _loadStoredImagePath();
    if (widget.fetchImageOnStart) {
      _fetchImageFuture = _fetchUploadedImage();
    }
  }

  Future<void> _loadStoredImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    _storedImagePath = prefs.getString('storedImagePath');
    if (_storedImagePath != null && File(_storedImagePath!).existsSync()) {
      setState(() {
        _image = XFile(_storedImagePath!);
      });
    }
  }




  Future<void> _fetchUploadedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';

    final directory = await getApplicationDocumentsDirectory();
    final uniqueFilename = '${Uuid().v4()}.jpg';
    final imagePath = path.join(directory.path, uniqueFilename);
    final File imageFile = File(imagePath);

    try {
      final response = await http.get(
        Uri.parse('${API.api1}/images'),
        headers: {
          'Authorization': 'Bearer $token',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final base64Image = jsonResponse['image'];
        final status = jsonResponse['status'];

        print('Retrieved status: $status'); // Debugging

        // Decode the base64 image
        final imageBytes = base64Decode(base64Image);
        await imageFile.writeAsBytes(imageBytes);
        await prefs.setString('storedImagePath', imagePath);

        if (mounted) {
          setState(() {
            // Clear the image if status is 2
            if (status == 2 || status == '2') {
              _image = null;
            } else {
              _image = XFile(imageFile.path);
            }
          });
        }

        print('License status: $status');

        // Check the status and navigate based on its value
        if (mounted) {
          if (status == 1 || status == '1') {
          /*  final imageUploadController = Get.find<ImageUploadController>();
            imageUploadController.saveUploadStatus(true); // Save upload status*/
            print('Navigating to PhotoDisplayScreen');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PhotoDisplayScreen(imagePath: imageFile.path),
              ),
            );
          } else if (status == 2 || status == '2') {
            print('Navigating to RejectedScreenScreen');
            // Do not navigate or show any further UI for status 2
          } else if (status == 0 || status == '0') {
            print('Navigating to WaitingForApprovalScreen');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WaitingForApprovalScreen(imagePath: imageFile.path),
              ),
            );
          } else {
            print('Unhandled status: $status');
            // Handle any other statuses if needed, or do nothing
          }
        }

        // Display success message with status
        if (mounted) {
          // Show success snackbar if needed
        }
      } else {
        print(response.body);
        if (mounted) {
          /* Get.snackbar(
            'Error',
            'Failed to fetch image',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );*/
        }
      }
    } catch (error) {
      print(error);
      if (mounted) {
        /*  Get.snackbar(
          'Error',
          'A server error occurred',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );*/
      }
    }
  }





  Future<void> _submitImage() async {
    if (_image == null) return;

    setState(() {
      _isUploading = true; // Set loading state to true
    });

    try {
      // Compress the image before uploading
      final originalFile = File(_image!.path);
      final compressedFile = await _compressImage(originalFile);

      // Get the size of the compressed file
      final imageSize = compressedFile.lengthSync(); // Size in bytes

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';

      final url = Uri.parse('${API.api1}/upload');
      final stream = http.ByteStream(compressedFile.openRead().cast());
      final length = await compressedFile.length();

      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['filename'] = 'license';
      request.fields['status'] = '0';
      request.files.add(http.MultipartFile('image', stream, length, filename: path.basename(compressedFile.path)));

      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {

        Get.snackbar(
          'Success',
          'Image uploaded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );


        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WaitingForApprovalScreen(imagePath: compressedFile.path),
          ),
        );
      } else {
        print(responseString);
        Get.snackbar(
          'Error',
          'Failed to upload image',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (error) {
      print(error);
      Get.snackbar(
        'Error',
        'An server error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print(error);
    } finally {
      setState(() {
        _isUploading = false; // Set loading state to false
      });
    }
  }


  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }


  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Picker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info,
                  color: Colors.blue, // Change color as needed
                  size: 20, // Adjust size if needed
                ),
                SizedBox(width: 4), // Small space for visual separation
                Expanded(
                  child: Text(
                    'Note: Your license application has been rejected. Please review the requirements and reapply with the necessary corrections.',
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 25,),
            SafeArea(
              child: Center(
                child: FutureBuilder<void>(
                  future: _fetchImageFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              GestureDetector(
                                onTap: _showImageSourceBottomSheet,
                                child: Container(
                                  width: 300,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: _image == null
                                      ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.credit_card, size: 50, color: Colors.grey),
                                        Text(
                                          'Add Photo',
                                          style: TextStyle(color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  )
                                      : Image.file(
                                    File(_image!.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            height: 45,
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0XFF008000),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  )
                              ),
                              onPressed: _isUploading
                                  ? null // Disable the button if uploading
                                  : () async {
                                await _submitImage(); // Upload the selected image
                              },
                              child: _isUploading
                                  ? CircularProgressIndicator(color: Colors.white) // Show loading spinner
                                  : Text('Submit'),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}