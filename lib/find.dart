import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:travel/searchresult.dart';

class FindScreen extends StatefulWidget {
  const FindScreen({Key? key}) : super(key: key);

  @override
  State<FindScreen> createState() => _FindScreenState();
}

class _FindScreenState extends State<FindScreen> {
  TextEditingController departureController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  FocusNode departureFocusNode = FocusNode();
  FocusNode destinationFocusNode = FocusNode();
  FocusNode dateFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    departureController.addListener(updateEraseController);
    destinationController.addListener(updateEraseController);
  }

  @override
  void dispose() {
    departureController.removeListener(updateEraseController);
    destinationController.removeListener(updateEraseController);
    departureFocusNode.dispose();
    destinationFocusNode.dispose();
    dateFocusNode.dispose();
    super.dispose();
  }

  void updateEraseController() {
    setState(() {}); // Trigger rebuild to update clear icon visibility
  }

  void handleClearClick(TextEditingController controller) {
    setState(() {
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Find a trip'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Column(
                  children: [
                    buildTextField(
                      controller: departureController,
                      hintText: 'Departure Location',
                      focusNode: departureFocusNode,
                      nextFocusNode: destinationFocusNode,
                    ),
                    SizedBox(height: 15),
                    buildTextField(
                      controller: destinationController,
                      hintText: 'Destination Location',
                      focusNode: destinationFocusNode,
                      nextFocusNode: dateFocusNode,
                    ),
                  ],
                ),
                Positioned(
                  right: 50,
                  top: 37,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.arrowsUpDown,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _swapLocations,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            buildDateTextField(),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Searchresult()),
                  );
                },
                child: Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2e2c2f),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
  }) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            filled: true,
            prefixIcon: Icon(Icons.location_on),
            hintText: hintText,
            suffixIcon: Visibility(
              visible: controller.text.isNotEmpty,
              child: IconButton(
                icon: FaIcon(FontAwesomeIcons.times),
                onPressed: () => handleClearClick(controller),
              ),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onEditingComplete: () {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            }
          },
        ),
      ],
    );
  }

  Widget buildDateTextField() {
    return TextField(
      controller: dateController,
      focusNode: dateFocusNode,
      decoration: InputDecoration(
        hintText: 'Departure date',
        filled: true,
        prefixIcon: Icon(Icons.calendar_today),
        suffixIcon: dateController.text.isNotEmpty
            ? IconButton(
          icon: Icon(FontAwesomeIcons.times),
          onPressed: () {
            setState(() {
              dateController.clear();
            });
          },
        )
            : null,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
      onChanged: (text) {
        setState(() {
          // Trigger rebuild to update suffixIcon visibility
        });
      },
    );
  }

  void _swapLocations() {
    setState(() {
      String temp = departureController.text;
      departureController.text = destinationController.text;
      destinationController.text = temp;
    });
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
