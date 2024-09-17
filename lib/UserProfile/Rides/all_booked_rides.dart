import 'package:flutter/material.dart';
import '../../Find/Trips/trips.dart';

class BookedUserRides extends StatelessWidget {
  const BookedUserRides({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'All User Rides',
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
                      TabItem(title: 'All'),
                      TabItem(title: 'Cancel'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            AllBookedRides(),
            CancelledBookedRides(),
          ],
        ),
      ),
    );
  }
}



class AllBookedRides extends StatelessWidget {
  const AllBookedRides({super.key});

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Text('Booked rides'),
    );
  }
}












class CancelledBookedRides extends StatelessWidget {
  const CancelledBookedRides({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Cancelled rides'),
    );
  }
}


