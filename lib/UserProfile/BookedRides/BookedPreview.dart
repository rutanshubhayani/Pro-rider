import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel/widget/configure.dart';

class GetBookedPreview extends StatefulWidget {
  final List<dynamic> tripData;

  const GetBookedPreview({super.key, required this.tripData});

  @override
  State<GetBookedPreview> createState() => _GetBookedPreviewState();
}

class _GetBookedPreviewState extends State<GetBookedPreview> {
  late List<String> otherItems;

  @override
  void initState() {
    super.initState();
    _processOtherItems();
    print('Booked trip data:${widget.tripData}');
  }

  void _processOtherItems() {
    if (widget.tripData.isNotEmpty) {
      var trip = widget.tripData[0];
      final otherItemsRaw = trip['other_items'];

      if (otherItemsRaw is String) {
        otherItems = otherItemsRaw.split(',').map((item) => item.trim()).toList();
      } else if (otherItemsRaw is List) {
        otherItems = otherItemsRaw.map((item) => item.toString().trim()).toList();
      } else {
        otherItems = [];
      }
    } else {
      otherItems = [];
    }
  }

  String formatDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('EE, MMM d \'at\' h:mm a').format(dateTime);
  }

  String formatPrice(double price) {
    var formattedPrice = NumberFormat.simpleCurrency().format(price);
    if (price == price.toInt()) {
      return formattedPrice.replaceAll('.00', '');
    }
    return formattedPrice;
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

  IconData getLuggageIcon(String code) {
    final Map<String, IconData> luggageIcons = {
      'No luggage': Icons.cancel,
      'Backpack': Icons.backpack,
      'Cabin bag (max. 23 kg)': Icons.luggage,
    };
    return luggageIcons[getLuggageLabel(code)] ?? Icons.help;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, IconData> itemsIcons = {
      'Winter tires': Icons.ac_unit,
      'Skis & snowboards': Icons.downhill_skiing,
      'Pets': Icons.pets,
      'Bikes': Icons.directions_bike,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booked Trip Preview'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (var trip in widget.tripData) ...[
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all( 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            trip['departure']?.split(',').first ?? 'Unknown Departure',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            formatDate(trip['leaving_date_time']),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      trip['departure'] ?? 'N/A',
                      style: const TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            trip['destination']?.split(',').first ?? 'Unknown Destination',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            formatDate(trip['leaving_date_time']),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      trip['destination'] ?? 'N/A',
                      style: const TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recurring trip',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const VerticalDivider(),
                    Expanded(
                      child: Text(
                        formatPrice(trip['price'] is double
                            ? trip['price']
                            : (trip['price'] as int).toDouble()),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${trip['booked_seats'] ?? 0} Seats booked',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 13),
                child: Text(
                  trip['description'] ?? 'N/A',
                  style: const TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ),
              const Divider(thickness: 15, color: Colors.black12),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Luggage: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            getLuggageIcon(trip['luggage'] ?? '0'),
                            color: Colors.black,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            getLuggageLabel(trip['luggage'] ?? '0'),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 15, color: Colors.black12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:  kPrimaryColor,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                            trip['profile_photo'] ?? 'images/default_user.png'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip['uname'] ?? 'Guest',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
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
                                  color: Colors.grey,
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
              const SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(thickness: 15, color: Colors.black12),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0,top: 20),
                    child: const Text(
                      'Stops:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                  if (trip['stops'].isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(25),
                      child: Text('No stops included in your ride'),
                    )
                  else
                    ...List<Widget>.from(
                        (jsonDecode(trip['stops']) as List).map((stop) {
                          final stopName = stop['stop_name'] ?? 'No Stop available for your ride';
                          return Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Icon(Icons.location_on),
                                  SizedBox(width: 5,),
                                  Text(stopName),
                                ],
                              ),
                            ),
                          );
                        }).toList()),
                  // Other items section
/*                  Padding(
                    padding: const EdgeInsets.only(right: 150.0, bottom: 100),
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
                        *//*Padding(
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
                        )*//*
                      ],
                    ),
                  )*/
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
