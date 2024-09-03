import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel/api.dart';
import 'package:travel/trippreview.dart';



class Trips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Trips',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: Colors.transparent,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent, // change background color of whole tabbar
                  ),
                  child: const TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent, // underline of tabbar
                    indicator: BoxDecoration(
                      color: Color(0xFFece9ec),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,
                    tabs: [
                      TabItem(title: 'Active'),
                      TabItem(title: 'Recent'),
                      TabItem(title: 'Cancelled'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
             ActiveScreen(),
            RecentScreen(),
             CancelScreen(),
          ],
        ),
      ),
    );
  }
}

class ActiveScreen extends StatefulWidget {


  const ActiveScreen({super.key});

  @override
  State<ActiveScreen> createState() => _ActiveScreenState();
}

class _ActiveScreenState extends State<ActiveScreen> {
  List<Map<String, dynamic>> trips = [];

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    final response = await http.get(Uri.parse('${API.api1}/get-trips'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print(response.body);


      setState(() {
        trips = data.map((trip) {
          return {
            'userName': trip['uname'], // Placeholder for driver's name
            'userImage': 'https://picsum.photos/200/300', // Placeholder for driver's image
            'seatsLeft': trip['empty_seats'],
            'departure': trip['departure'],
            'destination': trip['destination'],
            'date': DateTime.parse(trip['leaving_date_time']),
          };
        }).toList();
      });
    } else {
      // Handle the error
      print('Failed to load trips');
    }
  }

  String getFirstNameOfCity(String city) {
    // Split the city name by spaces and return the first part
    return city.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('E, MMM d \'at\' h:mma');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 13),
      child: ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          String formattedDate = dateFormat.format(trip['date']);
          String departureFirstName = getFirstNameOfCity(trip['departure']);
          String destinationFirstName = getFirstNameOfCity(trip['destination']);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TripPreview(tripData: trip)),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                  color: Color(0xFF51737A),
                  width: 1.5,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color(0xFF51737A),
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                      trip['userImage']),
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(Icons.verified, color: Colors.blue),
                              SizedBox(width: 5),
                              Text(
                                trip['userName'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 35, bottom: 10.0, right: 20),
                              child: Text(
                                '${trip['seatsLeft']} seats left',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Image.asset(
                              'images/smallbag.png',
                              height: 25,
                              width: 25,
                              color: Color(0XFF2196f3),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: getFirstNameOfCity(trip['departure']),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '  ${trip['departure']}',
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 13, left: 15),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: getFirstNameOfCity(trip['destination']),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '  ${trip['destination']}',
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 13.0, left: 15),
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


class RecentScreen extends StatefulWidget {
  @override
  _RecentScreenState createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  List<Map<String, dynamic>> trips = [];

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    final response = await http.get(Uri.parse('http://202.21.32.153:8081/get-trips'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      setState(() {
        trips = data.map((trip) {
          return {
            'userName': trip['uname'], // Placeholder for driver's name
            'userImage': 'https://picsum.photos/200/300', // Placeholder for driver's image
            'seatsLeft': trip['empty_seats'],
            'departure': trip['departure'],
            'destination': trip['destination'],
            'date': DateTime.parse(trip['leaving_date_time']),
          };
        }).toList();
      });
    } else {
      // Handle the error
      print('Failed to load trips');
    }
  }

  String getFirstNameOfCity(String city) {
    // Split the city name by spaces and return the first part
    return city.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('E, MMM d \'at\' h:mma');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 13),
      child: ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          String formattedDate = dateFormat.format(trip['date']);
          String departureFirstName = getFirstNameOfCity(trip['departure']);
          String destinationFirstName = getFirstNameOfCity(trip['destination']);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TripPreview(tripData: trip)),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                  color: Color(0xFF51737A),
                  width: 1.5,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color(0xFF51737A),
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                      trip['userImage']),
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(Icons.verified, color: Colors.blue),
                              SizedBox(width: 5),
                              Text(
                                trip['userName'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 35, bottom: 10.0, right: 20),
                              child: Text(
                                '${trip['seatsLeft']} seats left',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Image.asset(
                              'images/smallbag.png',
                              height: 25,
                              width: 25,
                              color: Color(0XFF2196f3),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: getFirstNameOfCity(trip['departure']),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '  ${trip['departure']}',
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 13, left: 15),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: getFirstNameOfCity(trip['destination']),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '  ${trip['destination']}',
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 13.0, left: 15),
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}





class CancelScreen extends StatelessWidget {
  final int index = 3; // Replace with your actual variable or logic
  const CancelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('E, MMM d \'at\' h:mma').format(now);

    return Padding(
      padding: const EdgeInsets.only(left: 13.0,right: 13,top: 13),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TripPreview(tripData: {},)));
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                    color: Color(0xFF51737A),
                    width: 1.5,
                  ),
                ),
                child: SizedBox(
                  width: double.infinity, // Adjust dimensions as needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0,top: 10,bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white, // You can set a background color if needed
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFF51737A),
                                      width: 3,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage('https://picsum.photos/200/300'),
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Icon(Icons.verified,color: Colors.blue,),
                                SizedBox(width: 10,),
                                Text('Chandeep',// Add user id here
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ),
                          /* Padding(
                            padding: const EdgeInsets.only(top: 13.0, left: 15),
                            child: Text(
                              formattedDate,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),*/
                          SizedBox(width: 60,),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 35,bottom: 10.0),
                                child: Text(
                                  '$index seats left', // Display the number of seats left
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Image.asset('images/smallbag.png',height: 25,width: 25,color: Color(0XFF2196f3),),

                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  // TextSpan for 'Brampton' in bold black color
                                  TextSpan(
                                    text: 'Brampton',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  // TextSpan for ' windston' in grey color
                                  TextSpan(
                                    text: '  Brampton, ON, Canada',
                                    style: TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          /*Padding(
                            padding: const EdgeInsets.only(left: 35),
                            child: Image.asset('images/smallbag.png',height: 25,width: 25,color: Color(0XFF2196f3),),
                          ),*/
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 13,left: 15),
                        child: RichText(
                          text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Windsor',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                    text: '  Windsor, ON, Canada',
                                    style: TextStyle(
                                      color: Colors.black54,
                                    )
                                )
                              ]
                          ),
                        ),
                      ),


                      Padding(
                        padding: const EdgeInsets.only(top: 13.0, left: 15),
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      SizedBox(height: 10,)
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8,),



          ],
        ),
      ),
    );
  }
}




class TabItem extends StatelessWidget {
  final String title;

  const TabItem({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
          ),
        ],
      ),
    );
  }
}



