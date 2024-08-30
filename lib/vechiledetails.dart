import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import 'package:travel/api.dart';

class VehicleDetails extends StatefulWidget {
  const VehicleDetails({super.key});

  @override
  State<VehicleDetails> createState() => _VehicleDetailsState();
}

class _VehicleDetailsState extends State<VehicleDetails> {
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
  String _selectedType = 'Sedan';
  String _selectedColor = 'Red';

  // Vehicle details
  Map<String, dynamic>? vehicleDetails;

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedImage = await _picker.pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      // Show error message if form is not valid or image is not selected
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill out all fields and select an image.'),
      ));
      return;
    }

    try {
      var stream =
      http.ByteStream(DelegatingStream.typed(_selectedImage!.openRead()));
      var length = await _selectedImage!.length();
      var uri = Uri.parse('${API.api1}/upload-vehicle-image');

      var request = http.MultipartRequest("POST", uri);

      var multipartFile = http.MultipartFile('vehicle_img', stream, length,
          filename: path.basename(_selectedImage!.path));

      request.files.add(multipartFile);
      request.fields['vehicle_model'] = _modelController.text;
      request.fields['vehicle_type'] = _selectedType;
      request.fields['vehicle_color'] = _selectedColor;
      request.fields['vehicle_year'] = _yearController.text;
      request.fields['licence_plate'] = _licenseController.text;

      var response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Vehicle details uploaded successfully!'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to upload vehicle details.'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred: $e'),
      ));
    }
  }

  Future<void> _fetchVehicleDetails(String vehicleId) async {
    try {
      final uri =
      Uri.parse('http://202.21.32.153:8081/vehicle-details/$vehicleId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          vehicleDetails = json.decode(response.body);
          _modelController.text = vehicleDetails?['vehicle_model'] ?? '';
          _selectedType = vehicleDetails?['vehicle_type'] ?? 'Sedan';
          _selectedColor = vehicleDetails?['vehicle_color'] ?? 'Red';
          _yearController.text = vehicleDetails?['vehicle_year'] ?? '';
          _licenseController.text = vehicleDetails?['licence_plate'] ?? '';
          // Update image and other fields as needed
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to fetch vehicle details.'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred: $e'),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch vehicle details with a given ID (for example, '12345')
    _fetchVehicleDetails('12345');
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
                          child: _selectedImage != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                              : Center(
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                  const EdgeInsets.only(top: 60.0),
                                  child: Icon(
                                    Icons.directions_car,
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
                          ),
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
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Model',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _modelController,
                        focusNode: modelFocusNode,
                        decoration: InputDecoration(
                            filled: true,
                            hintText: 'e.g. Ford Focus',
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            )),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(cartypeFocusNode);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a model';
                          }
                          return null;
                        },
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
                        'Type',
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField(
                        focusNode: cartypeFocusNode,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: ['Sedan', 'SUV', 'Truck', 'Coupe']
                            .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value as String;
                          });
                          FocusScope.of(context).requestFocus(colorFocusNode);
                        },
                        value: _selectedType,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Color',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField(
                        focusNode: colorFocusNode,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: ['Red', 'Blue', 'White', 'Black']
                            .map((color) => DropdownMenuItem(
                          value: color,
                          child: Text(color),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedColor = value as String;
                          });
                          FocusScope.of(context).requestFocus(yearFocusNode);
                        },
                        value: _selectedColor,
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
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _yearController,
                        focusNode: yearFocusNode,
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: 'YYYY',
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            )),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(licenseFocusNode);
                        },
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null) {
                            return 'Please enter a valid year';
                          }
                          return null;
                        },
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
                        'Licence Plate',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _licenseController,
                        focusNode: licenseFocusNode,
                        decoration: InputDecoration(
                            filled: true,
                            hintText: 'POP 123',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            )),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a license plate';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitData,
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 7,
                      backgroundColor: Color(0xFF2e2c2f),
                      padding:
                      EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
