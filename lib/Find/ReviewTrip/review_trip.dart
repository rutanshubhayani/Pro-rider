import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../SearchResult/FindBook.dart';
import '../Trips/GetBook.dart';


class FindReviewTrip extends StatelessWidget {
  final Map<String, dynamic> tripData;

  const FindReviewTrip({Key? key, required this.tripData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('review data :');
    print(tripData);
    // Use tripData to display details
    String departureCity = tripData['departure'] ?? 'Unknown Departure';
    String destinationCity = tripData['destination'] ?? 'Unknown Destination';
    String formattedDate = tripData['leaving_date_time'] != null
        ? DateFormat('E, MMM d \'at\' h:mma').format(DateTime.parse(tripData['leaving_date_time']))
        : 'Date not available';
    String description = tripData['description'] ?? 'No description available';

    return Scaffold(
      appBar: AppBar(
        title: Text('Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review trip details',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Itinerary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, bottom: 7),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      '$departureCity',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '$formattedDate',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(
                '$departureCity',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, bottom: 7),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      '$destinationCity',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '$formattedDate',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(
                '$destinationCity',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Booked Seats :',
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text('5 Seats',
                  style: TextStyle(
                    fontSize: 16,
                  ),),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Description:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(description, style: TextStyle(fontSize: 16)),
            // Add more widgets to display other details if needed
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Get.to(FindMeetDriver(tripData: tripData,),transition: Transition.fade);
          },
          child: Center(
            child: Text(
              'Next',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}














class GetReviewTrip extends StatelessWidget {
  final Map<String, dynamic> tripData;

  const GetReviewTrip({super.key, required this.tripData});

  @override
  Widget build(BuildContext context) {
    // Extract trip details from tripData
    String departureCity = tripData['departure'] ?? 'Unknown Departure';
    String destinationCity = tripData['destination'] ?? 'Unknown Destination';

    // Handle date parsing and formatting
    String leavingDateTime = tripData['date'].toString() ?? '';
    DateTime? dateTime;

    try {
      dateTime = DateTime.tryParse(leavingDateTime);
      if (dateTime == null) {
        // Try parsing with additional formats if needed
        // For example, if your date might not be in UTC:
        dateTime = DateTime.parse(leavingDateTime + 'Z'); // Append Z for UTC
      }
    } catch (e) {
      print('Date parsing error: $e'); // Log parsing error
    }
    print('Review trip data ==========================');
    print(tripData);

    // Format the dateTime or use fallback message
    String formattedDateTime = dateTime != null
        ? DateFormat('EE, MMM d \'at\' h:mm a').format(dateTime)
        : 'Unknown Date & Time'; // Fallback message

    print('Leaving date time: $formattedDateTime'); // Debug print

    String description = tripData['description'] ?? 'No description available';

    return Scaffold(
      appBar: AppBar(
        title: Text('Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review trip details',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Itinerary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, bottom: 7),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      departureCity,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      formattedDateTime,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(
                departureCity,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, bottom: 7),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      destinationCity,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      formattedDateTime,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(
                destinationCity,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Booked Seats :',
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text('5 Seats',
                    style: TextStyle(
                      fontSize: 16,
                    ),),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Description:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(description, style: TextStyle(fontSize: 16)),
            // Add more widgets to display other details if needed
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Get.to(() => GetMeetDriver(tripData: tripData,), transition: Transition.fade);
          },
          child: Center(
            child: Text(
              'Next',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

