import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import 'Inbox.dart';
import 'book.dart';

class GetTripPreview extends StatefulWidget {
  final Map<String, dynamic> tripData;

  const GetTripPreview({Key? key, required this.tripData}) : super(key: key);

  @override
  _GetTripPreviewState createState() => _GetTripPreviewState();
}

class _GetTripPreviewState extends State<GetTripPreview> {
  late String formattedDate;
  late List<String> otherItems;

  @override
  void initState() {
    super.initState();
    _formatDate();
    _processOtherItems();
  }

  void _formatDate() {
    final dateValue = widget.tripData['date'];

    if (dateValue is String && dateValue.isNotEmpty) {
      try {
        final date = DateTime.parse(dateValue).toLocal();
        formattedDate = DateFormat('E, MMM d \'at\' h:mma').format(date);
      } catch (e) {
        print('Date parsing error: $e');
        formattedDate = 'Invalid date format';
      }
    } else if (dateValue is DateTime) {
      formattedDate = DateFormat('E, MMM d \'at\' h:mma').format(dateValue.toLocal());
    } else {
      formattedDate = 'Date not available';
    }
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

    // Define a map for luggage icons
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
            Column(
              children: [
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(10.0),
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
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Luggage: '),
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
              ],
            ),
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
                  Icon(Icons.arrow_forward_ios_rounded),
                ],
              ),
            ),
            SizedBox(height: 5),
            Divider(thickness: 15, color: Colors.black12),
            if (stopsData.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Stops:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              ListView.builder(
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
            // Assuming otherItems is a list of strings
            Padding(
              padding: const EdgeInsets.only(right: 150.0, bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // "Other" label at the top
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
                  // List of items
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: otherItems.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
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
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            right: 82.0,
            bottom: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7, // 80% of screen width
              child: FloatingActionButton(
                backgroundColor: Color(0xFFff4400),
                onPressed: () {
                  Get.to(Book(), transition: Transition.fade);
                },
                child: Row(
                  children: [
                    SizedBox(width: 25),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Request to book',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white)),
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
                backgroundColor: Color(0xFF2e2c2f),
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(60),
                  borderSide: BorderSide.none,
                ),
                onPressed: () {
                  Get.to(InboxMain(), transition: Transition.leftToRight);
                },
                child: Icon(Icons.message, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),

    );
  }
}
