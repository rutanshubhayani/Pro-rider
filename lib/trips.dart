import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:travel/ride.dart';
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
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: Colors.transparent,
                ),
                child: const TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
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
        body: const TabBarView(
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

class ActiveScreen extends StatelessWidget {

  final int index = 3; // Replace with your actual variable or logic
  const ActiveScreen({super.key});
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
                    MaterialPageRoute(builder: (context) => Trippreview()));
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
                  height: 230,
                  width: double.infinity, // Adjust dimensions as needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
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
                          SizedBox(width: 60,),
                          Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: Text(
                              '$index seats left', // Display the number of seats left
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 13.0, left: 15),
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
                        padding: const EdgeInsets.only(top: 13.0,left: 30),
                        child: Image.asset('images/smallbag.png',height: 25,width: 25,),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 15.0,top: 15),
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
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8,),
            GestureDetector(
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Trippreview()));
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
                  height: 230,
                  width: double.infinity, // Adjust dimensions as needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
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
                          SizedBox(width: 60,),
                          Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: Text(
                              '$index seats left', // Display the number of seats left
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 13.0, left: 15),
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
                        padding: const EdgeInsets.only(top: 13.0,left: 30),
                        child: Image.asset('images/smallbag.png',height: 25,width: 25,),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 15.0,top: 15),
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
                    ],
                  ),
                ),
              ),
            ),SizedBox(height: 8,),
            GestureDetector(
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Trippreview()));
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
                  height: 230,
                  width: double.infinity, // Adjust dimensions as needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
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
                          SizedBox(width: 60,),
                          Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: Text(
                              '$index seats left', // Display the number of seats left
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 13.0, left: 15),
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
                        padding: const EdgeInsets.only(top: 13.0,left: 30),
                        child: Image.asset('images/smallbag.png',height: 25,width: 25,),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 15.0,top: 15),
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
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8,),
            GestureDetector(
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Trippreview()));
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
                  height: 230,
                  width: double.infinity, // Adjust dimensions as needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
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
                          SizedBox(width: 60,),
                          Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: Text(
                              '$index seats left', // Display the number of seats left
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 13.0, left: 15),
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
                        padding: const EdgeInsets.only(top: 13.0,left: 30),
                        child: Image.asset('images/smallbag.png',height: 25,width: 25,),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 15.0,top: 15),
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
                    ],
                  ),
                ),
              ),
            ),




          ],
        ),
      ),
    );
  }
}

class RecentScreen extends StatelessWidget {
  final int index = 3;
  const RecentScreen({super.key});

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
                    MaterialPageRoute(builder: (context) => Trippreview()));
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
                  height: 230,
                  width: double.infinity, // Adjust dimensions as needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
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
                          SizedBox(width: 60,),
                          Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: Text(
                              '$index seats left', // Display the number of seats left
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 13.0, left: 15),
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
                        padding: const EdgeInsets.only(top: 13.0,left: 30),
                        child: Image.asset('images/smallbag.png',height: 25,width: 25,),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 15.0,top: 15),
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
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8,),
            GestureDetector(
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Trippreview()));
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
                  height: 230,
                  width: double.infinity, // Adjust dimensions as needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
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
                          SizedBox(width: 60,),
                          Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: Text(
                              '$index seats left', // Display the number of seats left
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 13.0, left: 15),
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
                        padding: const EdgeInsets.only(top: 13.0,left: 30),
                        child: Image.asset('images/smallbag.png',height: 25,width: 25,),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 15.0,top: 15),
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
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8,),
            GestureDetector(
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Trippreview()));
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
                  height: 230,
                  width: double.infinity, // Adjust dimensions as needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
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
                          SizedBox(width: 60,),
                          Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: Text(
                              '$index seats left', // Display the number of seats left
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 13.0, left: 15),
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
                        padding: const EdgeInsets.only(top: 13.0,left: 30),
                        child: Image.asset('images/smallbag.png',height: 25,width: 25,),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 15.0,top: 15),
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
                    MaterialPageRoute(builder: (context) => Trippreview()));
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
                  height: 230,
                  width: double.infinity, // Adjust dimensions as needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
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
                          SizedBox(width: 60,),
                          Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: Text(
                              '$index seats left', // Display the number of seats left
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 13.0, left: 15),
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
                        padding: const EdgeInsets.only(top: 13.0,left: 30),
                        child: Image.asset('images/smallbag.png',height: 25,width: 25,),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 15.0,top: 15),
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
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8,),
            GestureDetector(
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Trippreview()));
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
                  height: 230,
                  width: double.infinity, // Adjust dimensions as needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
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
                          SizedBox(width: 60,),
                          Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: Text(
                              '$index seats left', // Display the number of seats left
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 13.0, left: 15),
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
                        padding: const EdgeInsets.only(top: 13.0,left: 30),
                        child: Image.asset('images/smallbag.png',height: 25,width: 25,),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 15.0,top: 15),
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
                    ],
                  ),
                ),
              ),
            ),


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



