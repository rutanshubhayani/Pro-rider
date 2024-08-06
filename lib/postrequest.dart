import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:travel/searchresult.dart';

class Postrequest extends StatefulWidget {
  const Postrequest({Key? key}) : super(key: key);

  @override
  State<Postrequest> createState() => _PostrequestState();
}

class _PostrequestState extends State<Postrequest> {
  final _formKey = GlobalKey<FormState>();
  FocusNode fromFocusNode = FocusNode();
  FocusNode toFocusNode = FocusNode();
  FocusNode dateFocusNode = FocusNode();
  FocusNode seatFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();

  TextEditingController dateController = TextEditingController();
  int _selectedSeat = 1;

  @override
  void dispose() {
    fromFocusNode.dispose();
    toFocusNode.dispose();
    dateFocusNode.dispose();
    seatFocusNode.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Post a request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'From',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 10,),
              TextFormField(
                focusNode: fromFocusNode,
                decoration: InputDecoration(
                  filled: true,
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'Enter origin',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_){
                  FocusScope.of(context).requestFocus(toFocusNode);
                },
                validator: (value){
                  if (value == null || value.isEmpty) {
                    return 'Please enter origin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'To',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                focusNode: toFocusNode,
                decoration: InputDecoration(
                  filled: true,
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'Enter Destination',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onFieldSubmitted: (_){
                  FocusScope.of(context).requestFocus(dateFocusNode);
                },
               validator: (value){
                  if (value == null || value.isEmpty) {
                    return 'Please enter destination';
                  }
                  return null;
               },
              ),
              SizedBox(height: 20),
              Text(
                'Departure date',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10,),
              TextFormField(
                focusNode: dateFocusNode,
                controller: dateController,
                decoration: InputDecoration(
                  hintText: 'Pick departure date',
                  filled: true,
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_){
                  FocusScope.of(context).requestFocus(seatFocusNode);
                },
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value){
                  if (value == null || value.isEmpty) {
                    return 'Please pick a date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20,),
              Text(
                'Seats required',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17
                ),
              ),
              SizedBox(height: 10,),
              DropdownButtonFormField<int>(
                focusNode: seatFocusNode,
                value: _selectedSeat,
                decoration: InputDecoration(
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: List.generate(3, (index) => index + 1)
                    .map((seat) => DropdownMenuItem<int>(
                  value: seat,
                  child: Text(seat.toString()),
                ))
                    .toList(),
                onChanged: (newValue) {
                  FocusScope.of(context).requestFocus(descriptionFocusNode);
                  setState(() {
                    _selectedSeat = newValue!;
                  });
                },
                icon: Icon(Icons.arrow_forward_ios_rounded),
              ),
              SizedBox(height: 20,),
              Text(
                'Descriiption',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10,),
              TextFormField(
                focusNode: descriptionFocusNode,
                maxLines: 5,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Tell driver a little bit more about you and why you\'re\ travelling.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  )
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: GestureDetector(
          onTap: () {
            print('Post request tapped');
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Searchresult(initialTabIndex: 2,)));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              textAlign: TextAlign.center,
              'Post request',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
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




