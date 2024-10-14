import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel/UserProfile/BookedRides/BookedPreview.dart';
import 'package:travel/widget/configure.dart';
import '../../Find/Trips/trips.dart';
import '../../api/api.dart';

class RequestHistory extends StatelessWidget {
  const RequestHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'All Posted requests',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: Colors.transparent,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors
                        .transparent, // change background color of whole tabbar
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
            AllPostRequests(),
            CancelledRequests(),
          ],
        ),
      ),
    );
  }
}











class AllPostRequests extends StatefulWidget {
  const AllPostRequests({super.key});

  @override
  _AllPostRequestsState createState() => _AllPostRequestsState();
}

class _AllPostRequestsState extends State<AllPostRequests> {
  bool _isLoading = true;
  List<dynamic> _postRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchPostRequests();
  }

  Future<void> _fetchPostRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      Get.snackbar('Authentication Error', 'User not authenticated',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${API.api1}/post_requests_get'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('All post requests: ${response.body}');
        setState(() {
          _postRequests = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print(response.body);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
      Get.snackbar('Error', 'Internal server error.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Cancellation'),
          content: Text('Are you sure you want to cancel this post request?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User pressed No
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User pressed Yes
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  Future<void> _cancelPostRequest(int postId, dynamic requestData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      Get.snackbar('Authentication Error', 'User not authenticated',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('${API.api1}/cancel_post_request/$postId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Post request successfully cancelled',
          snackPosition: SnackPosition.BOTTOM,
          mainButton: TextButton(
            onPressed: () async {
              await _restorePostRequest(postId);
              Get.closeCurrentSnackbar(); // Close the snackbar
            },
            child: Text('Undo'),
          ),
        );
        // Refresh the list of post requests
        _fetchPostRequests();
      } else {
        Get.snackbar('Error', 'Failed to cancel post request: ${response.body}',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Error: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _restorePostRequest(int postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      Get.snackbar('Authentication Error', 'User not authenticated',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('${API.api1}/restore_post_request/$postId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Post request successfully restored',
            snackPosition: SnackPosition.BOTTOM);
        // Refresh the list of post requests
        _fetchPostRequests();
      } else {
        Get.snackbar('Error', 'Failed to restore post request: ${response.body}',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Error: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('E, MMM d \'at\' h:mma');

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchPostRequests,
        child: _isLoading
            ? _buildShimmerLoading()
            : _postRequests.isEmpty
            ? const Center(child: Text('No post requests found.'))
            : _buildPostRequestsList(dateFormat),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Color(0xFFE5E5E5),
          highlightColor: Color(0xFFF0F0F0),
          child: Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 20, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 20, width: 150, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 20, width: 100, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostRequestsList(DateFormat dateFormat) {
    return ListView.builder(
      itemCount: _postRequests.length,
      itemBuilder: (context, index) {
        final request = _postRequests[index];
        String formattedDate =
        dateFormat.format(DateTime.parse(request['departure_date']));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(color: kPrimaryColor, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: request['profile_photo'] != null &&
                            request['profile_photo'].isNotEmpty
                            ? NetworkImage(request['profile_photo'])
                            : AssetImage('images/Userpfp.png')
                        as ImageProvider,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          request['uname'],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${request['seats_required']} Seats required',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'From: ${request['from_location']}',
                    style: TextStyle(color: Colors.black54),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'To: ${request['to_location']}',
                    style: TextStyle(color: Colors.black54),
                  ),
                  SizedBox(height: 10),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        bool confirmed = await _showConfirmationDialog(context);
                        if (confirmed) {
                          await _cancelPostRequest(
                              request['post_a_request_id'], request);
                        }
                      },
                      child: Text('Cancel Request'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0XFFd90000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}






class CancelledRequests extends StatefulWidget {
  const CancelledRequests({super.key});

  @override
  _CancelledRequestsState createState() => _CancelledRequestsState();
}

class _CancelledRequestsState extends State<CancelledRequests> {
  bool _isLoading = true;
  List<dynamic> _cancelledPostRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchCancelledPostRequests();
  }

  Future<void> _fetchCancelledPostRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      Get.snackbar('Error', 'User not authenticated');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${API.api1}/cancelled_post_requests'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _cancelledPostRequests = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        print('Error fetching cancelled post requests: ${response.body}');
        setState(() {
          _isLoading = false;
        });
        // Get.snackbar('Error', 'Error fetching cancelled post requests.');
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('Error', 'Error fetching cancelled post requests.');
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Restore Request'),
          content: Text('Are you sure you want to restore this request?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Restore'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false); // Return false if dialog is dismissed
  }

  Future<void> _restoreRequest(String postRequestId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      Get.snackbar('Error', 'User not authenticated');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('${API.api1}/restore_post_request/$postRequestId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Post request successfully restored!');
        _fetchCancelledPostRequests(); // Refresh the list
      } else {
        print('Failed to restore post request.: ${response.body}');
        Get.snackbar('Error', 'Failed to restore post request.');
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Error restoring post request.');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('E, MMM d \'at\' h:mma');

    return Scaffold(
      body: _isLoading
          ? _buildShimmerLoading()
          : _cancelledPostRequests.isEmpty
          ? const Center(child: Text('No cancelled requests found.'))
          : _buildCancelledPostRequestsList(dateFormat),
    );
  }

  // Shimmer loading effect
  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Color(0xFFE5E5E5),
          highlightColor: Color(0xFFF0F0F0),
          child: Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 20, width: 150, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 20, width: 100, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // List of cancelled post requests
  Widget _buildCancelledPostRequestsList(DateFormat dateFormat) {
    return ListView.builder(
      itemCount: _cancelledPostRequests.length,
      itemBuilder: (context, index) {
        final request = _cancelledPostRequests[index];
        String formattedDate =
        dateFormat.format(DateTime.parse(request['departure_date']));

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: kPrimaryColor, width: 1.5),
          ),
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: request['profile_photo'] != null &&
                          request['profile_photo'].isNotEmpty
                          ? NetworkImage(request['profile_photo'])
                          : AssetImage('images/Userpfp.png') as ImageProvider,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        request['uname'],
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '${request['seats_required']} Seats cancelled',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'From: ${request['from_location']}',
                  style: TextStyle(color: Colors.black54),
                ),
                SizedBox(height: 10),
                Text(
                  'To: ${request['to_location']}',
                  style: TextStyle(color: Colors.black54),
                ),
                SizedBox(height: 10),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Show confirmation dialog
                      bool shouldRestore = await _showConfirmationDialog(context);
                      if (shouldRestore) {
                        await _restoreRequest(request['post_a_request_id'].toString());
                      }
                    },
                    child: Text('Restore Request'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
