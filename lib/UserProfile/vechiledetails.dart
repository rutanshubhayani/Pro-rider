import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:async/async.dart';
import 'package:image/image.dart' as img;
import '../api/api.dart';



class VehicleDetailsController extends GetxController {
  var isDetailsPosted = false.obs;
}

class VehicleDetails extends StatefulWidget {
  const VehicleDetails({super.key});

  @override
  State<VehicleDetails> createState() => _VehicleDetailsState();
}

class _VehicleDetailsState extends State<VehicleDetails> {
  bool isEditing = false;  // Variable to manage editing state
  bool _isLoadingImage = false;
  bool _isSubmitting = false;


  FocusNode modelFocusNode = FocusNode();
  FocusNode cartypeFocusNode = FocusNode();
  FocusNode colorFocusNode = FocusNode();
  FocusNode yearFocusNode = FocusNode();
  FocusNode licenseFocusNode = FocusNode();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  // Form fields
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  String _selectedType = 'Select';
  String _selectedColor = 'Select';

  // Vehicle details
  Map<String, dynamic>? vehicleDetails;

  @override
  void initState() {
    super.initState();
    // Initialize default values
    _selectedType = 'Select';
    _selectedColor = 'Select';
    _fetchVehicleData();
    // Set up FocusNode listeners
    modelFocusNode.addListener(() {
      if (modelFocusNode.hasFocus && !isEditing) {
        _showToast('Click on edit button to change details');
      }
    });
    cartypeFocusNode.addListener(() {
      if (cartypeFocusNode.hasFocus && !isEditing) {
        _showToast('Click on edit button to change details');
      }
    });
    colorFocusNode.addListener(() {
      if (colorFocusNode.hasFocus && !isEditing) {
        _showToast('Click on edit button to change details');
      }
    });
    yearFocusNode.addListener(() {
      if (yearFocusNode.hasFocus && !isEditing) {
        _showToast('Click on edit button to change details');
      }
    });
    licenseFocusNode.addListener(() {
      if (licenseFocusNode.hasFocus && !isEditing) {
        _showToast('Click on edit button to change details');
      }
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
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
        final file = File(pickedImage.path);

        // Read and compress the image
        final img.Image? image = img.decodeImage(file.readAsBytesSync());
        if (image != null) {
          final compressedImage = img.encodeJpg(image, quality: 10);

          // Save compressed image
          final directory = await getTemporaryDirectory();
          final compressedImageFile = File('${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
          await compressedImageFile.writeAsBytes(compressedImage);

          setState(() {
            _selectedImage = compressedImageFile;
          });
        }
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }


  String _formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes Bytes';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }



  Future<void> _fetchVehicleData() async {
    setState(() {
      // Start loading data
      _isLoadingImage = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Authentication token not found. Please log in again.'),
        ));
        return;
      }

      // Fetch vehicle details
      final url = Uri.parse('${API.api1}/get-vehicle-data');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          vehicleDetails = data['vehicles'].isNotEmpty ? data['vehicles'][0] : null;
          if (vehicleDetails != null) {
            _modelController.text = vehicleDetails!['vehicle_model'];
            _selectedType = vehicleDetails!['vehicle_type'] ?? 'Select';
            _selectedColor = vehicleDetails!['vehicle_color'] ?? 'Select';
            _yearController.text = vehicleDetails!['vehicle_year']?.toString() ?? '';
            _licenseController.text = vehicleDetails!['licence_plate'] ?? '';
            _fetchVehicleImage(); // Fetch the image
          } else {
            // No vehicle details found
            _isLoadingImage = false;  // End loading
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['message']),
        ));
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('You have not uploaded any details.'),
        ));
        setState(() {
          _isLoadingImage = false;  // End loading
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to retrieve vehicle data.'),
        ));
        setState(() {
          _isLoadingImage = false;  // End loading
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred: $e'),
      ));
      setState(() {
        _isLoadingImage = false;  // End loading
      });
    }
  }

  Future<void> _fetchVehicleImage() async {
    setState(() {
      // Start loading image
      _isLoadingImage = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Authentication token not found. Please log in again.'),
        ));
        return;
      }

      final url = Uri.parse('${API.api1}/get-vehicle-image');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final uniqueFilename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final imagePath = path.join(directory.path, uniqueFilename);
        final imageFile = File(imagePath);

        await imageFile.writeAsBytes(response.bodyBytes);

        setState(() {
          _selectedImage = imageFile;
          _isLoadingImage = false;  // End loading
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to retrieve vehicle image.'),
        ));
        setState(() {
          _isLoadingImage = false;  // End loading
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred: $e'),
      ));
      setState(() {
        _isLoadingImage = false;  // End loading
      });
    }
  }


  // Submit details of vehicles
  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill out all fields and select an image.'),
      ));
      return;
    }

    setState(() {
      _isSubmitting = true; // Set loading state to true
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Authentication token not found. Please log in again.'),
        ));
        setState(() {
          _isSubmitting = false; // Reset loading state
        });
        return;
      }

      var stream = http.ByteStream(DelegatingStream.typed(_selectedImage!.openRead()));
      var length = await _selectedImage!.length();
      var uri = Uri.parse('${API.api1}/update-vehicle-data');

      var request = http.MultipartRequest("POST", uri);
      var multipartFile = http.MultipartFile('vehicle_img', stream, length, filename: path.basename(_selectedImage!.path));
      request.files.add(multipartFile);

      request.fields['vehicle_model'] = _modelController.text;
      request.fields['vehicle_type'] = _selectedType;
      request.fields['vehicle_color'] = _selectedColor;
      request.fields['vehicle_year'] = _yearController.text;
      request.fields['licence_plate'] = _licenseController.text;

      request.headers['Authorization'] = 'Bearer $token';

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      // Get the size of the uploaded image
      final imageSize = length / 1024; // Size in KB

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Access the VehicleDetailsController
        final vehicleDetailsController = Get.find<VehicleDetailsController>();
        vehicleDetailsController.isDetailsPosted.value = true;
        setState(() {
          isEditing = false;
          _isSubmitting = false; // Reset loading state

        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Vehicle details uploaded successfully! Image size: ${imageSize.toStringAsFixed(2)} KB'),
        ));
      } else {
        setState(() {
          _isSubmitting = false; // Reset loading state
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to upload vehicle details: ${response.statusCode}'),
        ));
        print('Error details: $responseBody');
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false; // Reset loading state
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred: $e'),
      ));
    }
  }


  void toggleEditing() {
    setState(() {
      isEditing = !isEditing;  // Toggle the editing state
      if (isEditing) {
        // Request focus on the first editable field when entering edit mode
        Future.delayed(Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(modelFocusNode);
        });
      }
    });
  }

  @override
  void dispose() {
    modelFocusNode.dispose();
    cartypeFocusNode.dispose();
    colorFocusNode.dispose();
    yearFocusNode.dispose();
    licenseFocusNode.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  'Vehicle details',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'This will help you get more bookings and it will be easier for passengers to identify your vehicle during pick-up.',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: isEditing ? () async {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => BottomSheet(
                        onClosing: () {},
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Icons.camera_alt),
                              title: Text('Take a Photo'),
                              onTap: () {
                                Navigator.pop(context);
                                _getImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.image),
                              title: Text('Select from Gallery'),
                              onTap: () {
                                Navigator.pop(context);
                                _getImage(ImageSource.gallery);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.delete),
                              title: Text('Remove Image'),
                              onTap: () {
                                Navigator.pop(context);
                                _removeImage();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  } : null, // Disable GestureDetector if not editing
                  child: _isLoadingImage
                      ? Center(child: CircularProgressIndicator())  // Show loader while loading image
                      : _selectedImage != null
                      ? Image.file(
                    _selectedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Center(
                      child: Text('No Image Uploaded'),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Model',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _modelController,
                        focusNode: modelFocusNode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the model';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Car model',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: !isEditing,  // Set readOnly based on isEditing
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Car type',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child:DropdownButtonFormField<String>(
                        hint: Text('Select Type'),
                        value: _selectedType == 'Select' ? null : _selectedType,
                        focusNode: cartypeFocusNode,
                        onChanged: isEditing ? (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedType = newValue;
                            });
                            print('Selected Type Updated: $_selectedType');
                          }
                        } : null,  // Enable/disable based on isEditing
                        items: <String>[
                          'Sedan',
                          'SUV',
                          'Truck',
                          'Hatchback',
                          'Convertible',
                          'Coupe',
                          'Wagon',
                          'Van',
                          'Luxury'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          hintText: 'Car type',
                          border: OutlineInputBorder(),
                        ),
                      ),


                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Color',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        hint: Text('Select color'),
                        value: _selectedColor == 'Select' ? null : _selectedColor,
                        focusNode: colorFocusNode,
                        onChanged: isEditing ? (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedColor = newValue;
                            });
                          }
                        } : null,  // Enable/disable based on isEditing
                        items: <String>[
                          'Red',
                          'Blue',
                          'Green',
                          'Black',
                          'White',
                          'Gray',
                          'Yellow',
                          'Orange',
                          'Brown',
                          'Purple',
                          'Pink',
                          'Beige'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),


                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Year',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        maxLength: 4,
                        controller: _yearController,
                        focusNode: yearFocusNode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the year';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid year';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value){
                          FocusScope.of(context).requestFocus(licenseFocusNode);
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Year',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: !isEditing,  // Set readOnly based on isEditing
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'License',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _licenseController,
                        focusNode: licenseFocusNode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the license plate';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'License plate',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: !isEditing,  // Set readOnly based on isEditing
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isEditing)
                      Expanded(
                        child:ElevatedButton(
                          onPressed: _submitData,
                          child: _isSubmitting
                              ? SizedBox(
                            width: 24, // Adjust as needed
                            height: 24, // Adjust as needed
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                              : Text('Save & Continue'),
                          style: ElevatedButton.styleFrom(
                            elevation: 7,
                            backgroundColor: Color(0xFF2e2c2f),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )

                      ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: toggleEditing,
                        child: Text(isEditing ? 'Cancel' : 'Edit'),
                        style: ElevatedButton.styleFrom(
                          elevation: 7,
                          backgroundColor: Color(0xFF2e2c2f),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
