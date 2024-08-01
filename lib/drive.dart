import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class drive extends StatefulWidget {
  @override
  State<drive> createState() => _driveState();
}

class _driveState extends State<drive> {
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController(text: 'Time');
  FocusNode departureFocusNode = FocusNode();
  FocusNode desinationFocusNode = FocusNode();
  FocusNode stopsFocusNode = FocusNode();
  FocusNode dateFocusNode = FocusNode();
  FocusNode timeFocusNode = FocusNode();
  FocusNode modelFocusNode = FocusNode();
  FocusNode cartypeFocusNode = FocusNode();
  FocusNode colorFocusNode = FocusNode();
  FocusNode yearFocusNode = FocusNode();
  FocusNode licenseFocusNode = FocusNode();
  TimeOfDay? selectedTime;
  List<bool> isSelected = [true, false];
  List<bool> isSelected1 = [true, false, false, false];
  List<String> choices = ['Winter tires', 'Bikes', 'Skis & snowboards', 'Pets'];
  List<IconData> icons = [Icons.ac_unit, Icons.directions_bike, Icons.downhill_skiing, Icons.pets];
  List<bool> isSelected2 = [false, false, false, false];
  int _selectedChoice = 1;
  bool _isChecked = false;
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  // Image selection state and methods
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
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  @override
  void dispose() {
    departureFocusNode.dispose();
    desinationFocusNode.dispose();
    stopsFocusNode.dispose();
    dateFocusNode.dispose();
    timeFocusNode.dispose();
    modelFocusNode.dispose();
    cartypeFocusNode.dispose();
    colorFocusNode.dispose();
    yearFocusNode.dispose();
    licenseFocusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Post a trip'),
      ),
      body: Material(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0, left: 16, right: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 3),
                      child: Text(
                        'Find your travel partner!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 5, left: 3.0, bottom: 10),
                      child: Text(
                        'Enter your departure, destination, and stops you are taking along the way',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0, bottom: 7),
                      child: Text(
                        'Departure',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    TextFormField(
                      focusNode: departureFocusNode,
                      decoration: InputDecoration(
                        filled: true,
                        prefixIcon: Icon(Icons.location_on),
                        hintText: 'Departure Location',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_){
                        FocusScope.of(context).requestFocus(desinationFocusNode);
                    },
                    ),
                    SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0, bottom: 7),
                      child: Text(
                        'Destination',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    TextFormField(
                      focusNode: desinationFocusNode,
                      decoration: InputDecoration(
                        filled: true,
                        prefixIcon: Icon(Icons.location_on),
                        hintText: 'Destination Location',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_){
                        FocusScope.of(context).requestFocus(stopsFocusNode);
                      },
                    ),
                    SizedBox(height: 20),
                    Divider(
                      height: 4,
                      thickness: 1,
                      color: Colors.black26,
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0, bottom: 7),
                      child: Text(
                        'Stops',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    TextFormField(
                      focusNode: stopsFocusNode,
                      decoration: InputDecoration(
                        filled: true,
                        prefixIcon: Icon(Icons.add_location_alt_sharp),
                        hintText: 'Add stops',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_){
                        FocusScope.of(context).requestFocus(dateFocusNode);
                      },
                    ),
                    SizedBox(height: 40),
                    Divider(
                      endIndent: 100,
                      height: 4,
                      thickness: 2,
                      color: Colors.black26,
                    ),
                    SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0, bottom: 7),
                      child: Text(
                        'Ride Schedule',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 21),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0),
                      child: Text(
                        'Enter precise date and time of your journey',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 10),
                      child: ToggleButtons(
                        borderRadius: BorderRadius.circular(20),
                        renderBorder: true,
                        borderWidth: 1,
                        selectedBorderColor: Colors.black,
                        selectedColor: Colors.white,
                        fillColor: Colors.black,
                        color: Colors.black,
                        constraints:
                        BoxConstraints(minHeight: 30, minWidth: 130),
                        children: [
                          Text('One-time trip'),
                          Text('Recurring trip'),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            for (int buttonIndex = 0;
                            buttonIndex < isSelected.length;
                            buttonIndex++) {
                              if (buttonIndex == index) {
                                isSelected[buttonIndex] = true;
                              } else {
                                isSelected[buttonIndex] = false;
                              }
                            }
                          });
                        },
                        isSelected: isSelected,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0, top: 10,bottom: 10),
                      child: Text(
                        "Leaving",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            focusNode: dateFocusNode,
                            controller: dateController,
                            decoration: InputDecoration(
                              hintText: 'Departure date',
                              filled: true,
                              prefixIcon: Icon(Icons.calendar_month),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              _selectDate();
                            },
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_){
                              FocusScope.of(context).requestFocus(timeFocusNode);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'at',
                            style: TextStyle(fontSize: 16),
                          ),
                        ), // Add some space between the two text fields
                        Expanded(
                          child: TextFormField(
                            focusNode: timeFocusNode,
                            onTap: () async {
                              final TimeOfDay? timeOfDay = await showTimePicker(
                                context: context,
                                initialTime: selectedTime ?? TimeOfDay.now(),
                                initialEntryMode: TimePickerEntryMode.dial,
                              );
                              if (timeOfDay != null) {
                                setState(() {
                                  selectedTime = timeOfDay;
                                  timeController.text =
                                  "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}";
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Time', // Added hint text for clarity
                              filled: true,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_){
                              FocusScope.of(context).requestFocus(modelFocusNode);
                            },
                            readOnly: true,
                            controller: timeController,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Divider(
                      endIndent: 100,
                      height: 4,
                      thickness: 2,
                      color: Colors.black26,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0, bottom: 7),
                      child: Text(
                        'Vehicle details',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0),
                      child: Text(
                        'This will help you get more bookings and it will be easier for passengers to identify your vehicle during pick-up.',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Integrated image selection from _AddThemeScreen1
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
                                border:
                                Border.all(color: Colors.grey, width: 2.0),
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
                                      padding: const EdgeInsets.only(
                                          top: 60.0),
                                      child: Icon(
                                        Icons.directions_car,
                                        color: Colors.grey,
                                        size: 50,
                                      ),
                                    ),
                                    Text(
                                      'Add Photo',
                                      style:
                                      TextStyle(color: Colors.black54),
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
                    SizedBox(
                      height: 40,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Text(
                              'Model',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            focusNode: modelFocusNode,
                            decoration: InputDecoration(
                                filled: true,
                                hintText: 'e.g. Ford Focus',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_){
                              FocusScope.of(context).requestFocus(cartypeFocusNode);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Text(
                              'Type',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black87),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 53,
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
                                FocusScope.of(context).requestFocus(colorFocusNode);
                              },

                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Text(
                              'Color',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 50,
                            child: DropdownButtonFormField(
                              focusNode: colorFocusNode,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: ['Red', 'Blue', 'White', 'Black']
                                  .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                FocusScope.of(context).requestFocus(yearFocusNode);
                              },
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
                          child: Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Text(
                              'Year',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 2,
                            child: TextFormField(
                              focusNode: yearFocusNode,
                              maxLength: 4,
                              /*inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,],*/
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  hintText: 'YYYY',
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_){
                                FocusScope.of(context).requestFocus(licenseFocusNode);
                              },
                            )),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.only(left: 3),
                            child: Text(
                              'Licence Plate',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 2,
                            child: TextFormField(
                              focusNode: licenseFocusNode,
                              decoration: InputDecoration(
                                  filled: true,
                                  hintText: 'POP 123',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  )),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Divider(
                      endIndent: 100,
                      height: 4,
                      thickness: 2,
                      color: Colors.black26,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0,bottom: 7),
                      child: Text(
                        'Trip prefrences',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0,bottom: 15),
                      child: Text(
                          'This informs passengers of how much space you have for their luggage and extras before they book.',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0),
                      child: Text(
                        'Luggage',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0,top: 10),
                      child: ToggleButtons(
                        borderRadius: BorderRadius.circular(20),
                        renderBorder: true,
                        borderWidth: 1,
                        selectedBorderColor: Colors.black,
                        selectedColor: Colors.white,
                        fillColor: Colors.black,
                        color: Colors.black,
                        constraints: BoxConstraints(minHeight: 33.0, minWidth: 70.0),
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 6,),
                              Icon(Icons.work),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('No luggage'),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.work),
                              SizedBox(width: 6,),
                              Text('S'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.work),
                              SizedBox(width: 6,),
                              Text('M'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.work),
                              SizedBox(width: 6,),
                              Text('L'),
                            ],
                          ),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            for (int buttonIndex = 0; buttonIndex < isSelected1.length; buttonIndex++) {
                              if (buttonIndex == index) {
                                isSelected1[buttonIndex] = true;
                              } else {
                                isSelected1[buttonIndex] = false;
                              }
                            }
                          });
                        },
                        isSelected: isSelected1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0,top: 15,bottom: 10),
                      child: Text(
                          'Back row sitting',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                          ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0),
                      child: Text(
                        'Pledge to a maximum of 2 people in the back for better reviews',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0,top: 10),
                      child: ToggleButtons(
                        borderRadius: BorderRadius.circular(20),
                        renderBorder: true,
                        borderWidth: 1,
                        selectedBorderColor: Colors.black,
                        selectedColor: Colors.white,
                        fillColor: Colors.black,
                        color: Colors.black,
                        constraints:
                        BoxConstraints(minHeight: 30, minWidth: 170),
                        children: [
                          Row(
                            children: [
                              Icon(Icons.group),
                              SizedBox(width: 7,),
                              Text('Max 2 people'),
                            ],
                          ),
                          Row(
                            children: [
                            Icon(Icons.group),
                              SizedBox(width: 7,),
                            Text('3 pepple'),],
                          ),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            for (int buttonIndex = 0;
                            buttonIndex < isSelected.length;
                            buttonIndex++) {
                              if (buttonIndex == index) {
                                isSelected[buttonIndex] = true;
                              } else {
                                isSelected[buttonIndex] = false;
                              }
                            }
                          });
                        },
                        isSelected: isSelected,
                      ),
                    ),
                    SizedBox(height: 20,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 3.0),
                          child: Text(
                            'Other',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 10, // Spacing between chips
                          children: List<Widget>.generate(
                            choices.length,
                                (int index) {
                              return ChoiceChip(
                                avatar: Icon(
                                  icons[index],
                                  color: isSelected2[index] ? Colors.white : Colors.black,
                                ),
                                label: Text(choices[index]),
                                selected: isSelected2[index],
                                selectedColor: Colors.black,
                                onSelected: (bool selected) {
                                  setState(() {
                                    isSelected2[index] = selected;
                                  });
                                },
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: BorderSide(
                                    color: isSelected2[index] ? Colors.black : Colors.grey,
                                  ),),
                                labelStyle: TextStyle(
                                  color: isSelected2[index] ? Colors.white : Colors.black,
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Divider(
                      endIndent: 100,
                      height: 4,
                      thickness: 2,
                      color: Colors.black26,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 3,top: 15,bottom: 35),
                      child: Text(
                        'Empty seats',
                        style: TextStyle(
                          fontSize:20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFe0e8ea),
                        border: Border.all(
                          color: Color(0xFF51737A),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'As a new driver, you can offer 3 seats and it increases to 7 once you\'ve driven 10 people.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Also, we recommend putting a maximum of 2 people per row to ensure everyone\'s comfort.',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 45,),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0,bottom: 15),
                      child: Text(
                        'Select number',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(3, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedChoice = index + 1;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _selectedChoice == index + 1 ? Colors.black : Colors.white,
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: _selectedChoice == index + 1 ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Divider(
                      endIndent: 100,
                      height: 4,
                      thickness: 2,
                      color: Colors.black26,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 3,bottom: 15,top: 15),
                      child: Text(
                        'Rules when posting a trip',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10,),
                        Image.asset('images/time.png',height: 100,width: 100,),
                        Padding(
                          padding: const EdgeInsets.only(left: 3.0,top: 10,bottom: 7),
                          child: Text(
                            'Be reliable',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 3.0),
                          child: Text(
                            'Only post a trip if you\'re sure you\'re driving and showup on time.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        SizedBox(height: 18,),
                        Image.asset('images/no_cash.png',height: 100,width: 100,),
                        Padding(
                          padding: const EdgeInsets.only(left: 3.0,top: 10,bottom: 7),
                          child: Text(
                            'No cash',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 3.0),
                          child: Text(
                            'All passengers pay online and you receive a payout after the trip.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        SizedBox(height: 18,),
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Image.asset('images/drive_safely.png',height: 80,width: 80,),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 3.0,top: 10,bottom: 7),
                          child: Text(
                            'Drive safely',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 3.0),
                          child: Text(
                            'Stick to the speed limit and do not use your phone while driving.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40,),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: _isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _isChecked = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'I agree to these rules, to the ',
                                  style: TextStyle(color: Colors.black),
                                ),
                                TextSpan(
                                  text: 'Driver Cancellation Policy',
                                  style: TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _launchURL('https://www.google.com/'),
                                ),
                                TextSpan(
                                  text: ', ',
                                  style: TextStyle(color: Colors.black),
                                ),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _launchURL('https://www.google.com/'),
                                ),
                                TextSpan(
                                  text: ' and the ',
                                  style: TextStyle(color: Colors.black),
                                ),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _launchURL('https://www.google.com/'),
                                ),
                                TextSpan(
                                  text:
                                  ', and I understand that my account could be suspended if I break the rules',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),




            SizedBox(height: 70.0),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFdfdfdf),
        child: GestureDetector(
          onTap: () {
            print('Post trip tapped');
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Post trip',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        dateController.text = picked.toString().split(" ")[0];
      });
    }
  }
}
