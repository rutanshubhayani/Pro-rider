import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel/api/api.dart';

class GetPostedPreview extends StatefulWidget {
  final Map<String, dynamic> tripData;

  const GetPostedPreview({Key? key, required this.tripData}) : super(key: key);

  @override
  _GetPostedPreviewState createState() => _GetPostedPreviewState();
}

class _GetPostedPreviewState extends State<GetPostedPreview> {
  late List<String> otherItems;
  List<dynamic> bookedUsers = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    // _formatDate();
    _processOtherItems();
    _fetchBookedUsers();
    print('Get trip data : ============================');
    print(widget.tripData);
  }


  void _processOtherItems() {
    final otherItemsRaw = widget.tripData['otherItems'];

    if (otherItemsRaw is String) {
      otherItems = otherItemsRaw.split(',').map((item) => item.trim()).toList();
    } else if (otherItemsRaw is List) {
      otherItems = otherItemsRaw.map((item) => item.toString().trim()).toList();
    } else {
      otherItems = [];
    }
  }


  Future<void> _fetchBookedUsers() async {
    final postATripId = widget.tripData['post_a_trip_id'].toString();
    final url = '${API.api1}/trip_booking_data/$postATripId';

    try {
      final response = await http.get(Uri.parse(url));
      print('Response of booked user: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Booked user details: ${response.body}');
        setState(() {
          bookedUsers = data['bookings'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
     /* Get.snackbar(
        'Error',
        'Failed to fetch booking data',
        snackPosition: SnackPosition.BOTTOM,
      );*/
    }
  }


  String getLuggageLabel(String code) {
    switch (code) {
      case '0':
        return 'No luggage';
      case '1':
        return 'Backpack';
      case '2':
        return 'Cabin bag (max. 23 kg)';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = widget.tripData['uid'].toString() ?? 'Unknown uid';

    final DateTime dateTime = DateTime.parse(widget.tripData['date'].toString());
    final String formattedDate = DateFormat('EE, MMM d \'at\' h:mm a').format(dateTime);
    final departureCity = widget.tripData['departure'] ?? 'Unknown Departure';
    final departureCityFirstName = widget.tripData['departure']?.split(' ').first ?? 'Unknown';
    final destinationCity = widget.tripData['destination'] ?? 'Unknown Destination';
    final destinationCityFirstName = widget.tripData['destination']?.split(' ').first ?? 'Unknown';
    final userName = widget.tripData['userName'] ?? 'Unknown';
    final price = widget.tripData['price']?.toString() ?? '0';
    final luggageCode = widget.tripData['luggage']?.toString() ?? '0';
    final luggage = getLuggageLabel(luggageCode);
    final description = widget.tripData['description']?.isNotEmpty == true
        ? widget.tripData['description']
        : 'Trip from $departureCity to $destinationCity';
    final rideSchedule = widget.tripData['rideSchedule'] ?? 'Unknown';
    final seatsLeft = widget.tripData['seatsLeft'] ?? 0;
    final backRowSitting = widget.tripData['backRowSitting'] ?? 'Not specified';
    final userImage = widget.tripData['userImage'] ?? 'images/Userpfp.png';
    final stopsData = widget.tripData['stops'] as List<dynamic>? ?? [];

    final Map<String, IconData> luggageIcons = {
      'No luggage': Icons.cancel,
      'Backpack': Icons.backpack,
      'Cabin bag (max. 23 kg)': Icons.luggage,
    };

    final Map<String, IconData> itemsIcons = {
      'Winter tires': Icons.ac_unit,
      'Skis & snowboards': Icons.downhill_skiing,
      'Pets': Icons.pets,
      'Bikes': Icons.directions_bike,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Preview'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          departureCityFirstName,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    departureCity,
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          destinationCityFirstName,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    destinationCity,
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      textAlign: TextAlign.center,
                      rideSchedule,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  VerticalDivider(),
                  Expanded(
                    child: Text(
                      textAlign: TextAlign.center,
                      '\$' + price,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '$seatsLeft Seats left',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 13),
              child: Text(
                description,
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
            ),
            Divider(thickness: 15, color: Colors.black12),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Luggage: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          luggageIcons[luggage] ?? Icons.help,
                          color: Colors.black,
                        ),
                        SizedBox(width: 10),
                        Text(
                          luggage,
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(thickness: 15, color: Colors.black12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
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
                      backgroundImage: NetworkImage(userImage),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
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
                ],
              ),
            ),
            SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(thickness: 15, color: Colors.black12),
                if (stopsData.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stops:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        Text(
                          'No stops included in your ride',
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, left: 20),
                    child: Text(
                      'Stops:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                  ListView.builder(
                    padding: EdgeInsets.only(left: 15),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: stopsData.length,
                    itemBuilder: (context, index) {
                      final stop = stopsData[index] as Map<String, dynamic>; // Cast to Map
                      final stopName = stop['stop_name'] ?? 'Unknown Stop';
                      final stopPrice = stop['stop_price'] ?? '0';
                      return ListTile(
                        title: Text(stopName),
                        subtitle: Text('Price: \$${stopPrice}'),
                      );
                    },
                  ),
                ],
                Divider(thickness: 15, color: Colors.black12),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 150.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Other:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: otherItems.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  itemsIcons[item] ?? Icons.help,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  item,
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Divider(thickness: 15, color: Colors.black12),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Who booked your ride:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            bookedUsers.isEmpty
                ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('No one has booked your ride yet.'),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: bookedUsers.length,
              itemBuilder: (context, index) {
                final user = bookedUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(user['profile_photo']),
                  ),
                  title: Row(
                    children: [
                      Text(user['uname'] ?? 'Unknown User'),
                      Spacer(),
                      Row(
                        children: [
                          Text(
                            'Booked Seats: ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(user['booked_seats'].toString() ?? 'N/A'),
                        ],
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Email: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(user['umail'].toString() ?? 'N/A'),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Mobile: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(user['umobilenumber'].toString() ?? 'N/A'),
                        ],
                      ),
                      // Show "this user has cancelled booking" if the status is "canceled"
                      if (user['status'] == 'canceled') ...[
                        SizedBox(height: 4),
                        Text(
                          'This user has cancelled booking',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 50,)
          ],
        ),
      ),
    );
  }
}
