import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel/book.dart';
import 'package:travel/posttrip.dart';
import 'package:travel/home.dart';

import 'Inbox.dart';

class Trippreview extends StatefulWidget {
  const Trippreview({super.key});

  @override
  _TrippreviewState createState() => _TrippreviewState();
}

class _TrippreviewState extends State<Trippreview> {
  DateTime now = DateTime.now();
  final index = 3;

  String formattedDate = DateFormat('E, MMM d \'at\' h:mma').format(DateTime.now());
  bool seat1Selected = false;
  bool seat2Selected = false;
  bool seat3Selected = false;
  List<String> choices = ['Small luggage', 'No Bikes', 'No Skis/snowboards', ' No Pets','No witner tires'];
  List<IconData> icons = [Icons.work, Icons.directions_bike, Icons.downhill_skiing, Icons.pets, Icons.ac_unit];
  List<bool> isSelected2 = [false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Preview'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Brampton',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 105,),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Brampton, ON, Canada',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54
                    ),
                  ),
                  SizedBox(height: 15,),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Brampton',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Brampton, ON, Canada',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Divider(),
            SizedBox(height: 10,),
            Row(
              children: [
                SizedBox(width: 15,),
                Icon(Icons.keyboard_return_rounded),
                Text(
                  '  Returning',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  ' Wed, Jul 10 at 4:00pm',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 65,),
                Icon(Icons.arrow_forward_ios_rounded),
              ],
            ),
            SizedBox(height: 10,),
            Column(
              children: [
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    '3 Seats left',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),

                Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 10,bottom: 13),
                  child: Text(
                    '"Brampton to Windsor"',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15,
                    ),
                  ),
                ),
                Divider(
                  thickness: 15,
                  color: Colors.black12,
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PostTrip()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0,bottom: 5),
                    child: Row(
                      children: [
                        SizedBox(width: 20,),
                        Text(
                          'Booked:',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 10), // Adjust the space between text and icons as needed
        
                        // Integrated SeatSelectionWidget here
                        SeatSelectionWidget(
                          onSeatSelected: (int seatIndex, bool isSelected) {
                            setState(() {
                              // Update selected state based on seatIndex
                              switch (seatIndex) {
                                case 1:
                                  seat1Selected = isSelected;
                                  break;
                                case 2:
                                  seat2Selected = isSelected;
                                  break;
                                case 3:
                                  seat3Selected = isSelected;
                                  break;
                              }
                            });
                          },
                          seat1Selected: seat1Selected,
                          seat2Selected: seat2Selected,
                          seat3Selected: seat3Selected,
                        ),
        
        
                        Padding(
                          padding: const EdgeInsets.only(left: 155.0),
                          child: Icon(Icons.arrow_forward_ios_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  thickness: 15,
                  color: Colors.black12,
                ),
              ],
            ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              // Profile picture with border
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF51737A),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage('https://picsum.photos/200/300'), // Replace with your image URL
                ),
              ),
              SizedBox(width: 12),
              // User details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chandeep',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Driver\'s license verified',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios_rounded,
              ),
            ],
          ),
        ),
            SizedBox(height: 5,),
            Divider(
              thickness: 15,
              color: Colors.black12,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 150.0,bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    direction: Axis.vertical, // Display chips vertically
                    alignment: WrapAlignment.start, // Justify chips from the start (left)
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
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected2[index] ? Colors.white : Colors.black,
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
            ),
        
          ],
        ),
      ),
      floatingActionButton:
      Stack(
        children: [
          Positioned(
            right: 82.0 ,/*+ MediaQuery.of(context).size.width * 0.2 + 16.0, // Right position of second FAB*/
            bottom: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7, // 80% of screen width
              child: FloatingActionButton(
                backgroundColor: Color(0xFFff4400),
                onPressed: () {
                  Get.to(Book(),transition: Transition.fade);// Add onPressed functionality
                },
                child: Row(
                  children: [
                    SizedBox(width: 25,),
                    Text(
                        'Request to book',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 80,),
                    Icon(Icons.arrow_forward_ios_rounded,color: Colors.white,),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 0.0,
            bottom: 0.0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.15, // 20% of screen width
              child: FloatingActionButton(
               // heroTag: "btn1", if error = (There are multiple heroes that share the same tag within a subtree).
                backgroundColor: Color(0xFF2e2c2f),
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(60),
                  borderSide: BorderSide.none
                ),
                onPressed: () {
                  Get.to(InboxMain(),transition: Transition.leftToRight);// Add onPressed functionality
                },
                child: Icon(Icons.message,color: Colors.white,size: 30,),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SeatSelectionWidget extends StatelessWidget {
  final Function(int, bool) onSeatSelected;
  final bool seat1Selected;
  final bool seat2Selected;
  final bool seat3Selected;

  SeatSelectionWidget({
    required this.onSeatSelected,
    required this.seat1Selected,
    required this.seat2Selected,
    required this.seat3Selected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // First car seat icon
        GestureDetector(
          onTap: () {
            onSeatSelected(1, !seat1Selected);
          },
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: seat1Selected ? Colors.black : Colors.transparent,
            ),
            child: Icon(Icons.event_seat,
                color: seat1Selected ? Colors.white : Colors.black),
          ),
        ),

        SizedBox(width: 5), // Adjust spacing between icons if needed

        // Second car seat icon
        GestureDetector(
          onTap: () {
            onSeatSelected(2, !seat2Selected);
          },
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: seat2Selected ? Colors.black : Colors.transparent,
            ),
            child: Icon(Icons.event_seat,
                color: seat2Selected ? Colors.white : Colors.black),
          ),
        ),

        SizedBox(width: 5), // Adjust spacing between icons if needed

        // Third car seat icon
        GestureDetector(
          onTap: () {
            onSeatSelected(3, !seat3Selected);
          },
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: seat3Selected ? Colors.black : Colors.transparent,
            ),
            child: Icon(Icons.event_seat,
                color: seat3Selected ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }
}


