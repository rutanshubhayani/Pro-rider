import 'package:flutter/material.dart';

class GetBookedPreview extends StatefulWidget {
  final List<dynamic> tripData;

  const GetBookedPreview({super.key, required this.tripData});

  @override
  State<GetBookedPreview> createState() => _GetBookedPreviewState();
}

class _GetBookedPreviewState extends State<GetBookedPreview> {
  @override
  void initState() {
    super.initState();
    print('Booked trip data: ${widget.tripData}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booked Trip Preview'),
      ),
      body: ListView.builder(
        itemCount: widget.tripData.length,
        itemBuilder: (context, index) {
          final trip = widget.tripData[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Departure: ${trip['departure']}', style: const TextStyle(fontSize: 18)),
                  Text('Destination: ${trip['destination']}', style: const TextStyle(fontSize: 18)),
                  Text('Leaving Date: ${trip['leaving_date_time']}', style: const TextStyle(fontSize: 18)),
                  Text('Booked Seats: ${trip['booked_seats']}', style: const TextStyle(fontSize: 18)),
                  Text('Price: \$${trip['price']}', style: const TextStyle(fontSize: 18)),
                  Text('User: ${trip['uname']}', style: const TextStyle(fontSize: 18)),
                  if (trip['profile_photo'] != null)
                    Image.network(trip['profile_photo']),
                  const SizedBox(height: 10),
                  const Text('Stops:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...trip['stops'].map<Widget>((stop) {
                    return Text('${stop['stop_name']} - \$${stop['stop_price']}', style: const TextStyle(fontSize: 16));
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
