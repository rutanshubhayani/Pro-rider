import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel/Find/Inbox/receiveInbox.dart';
import 'package:travel/Find/Passenger/findrequests.dart';
import 'package:travel/Find/find.dart';
import 'package:travel/Find/history.dart';
import 'package:travel/widget/configure.dart';

class MyHomePage extends StatefulWidget {
  final int initialIndex;

  MyHomePage({this.initialIndex = 0});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final List<Widget> _screens = [
    const FindScreen(),
    const InboxList(),
    const FindRequests(),
    // const History(),
  ];

  late int _currentIndex;
  late PageController _pageController;
  late AnimationController _historyAnimationController;
  late AnimationController _bikeAnimationController;
  late AnimationController _passengerAnimationController;
  late Animation<double> _bikeAnimation;
  late Animation<double> _passengerAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    // Initialize AnimationControllers
    _historyAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _bikeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _passengerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Create a Tween animation for the bike icon
    _bikeAnimation = Tween<double>(begin: 1.0, end: -1.0).animate(_bikeAnimationController)
      ..addListener(() {
        setState(() {});
      });

    // Create a Tween animation for the passenger icon
    _passengerAnimation = Tween<double>(begin: 1.0, end: -1.0).animate(_passengerAnimationController)
      ..addListener(() {
        setState(() {});
      });

    // Start the history animation if initialIndex is 3
    if (_currentIndex == 3) {
      _historyAnimationController.forward().then((_) {
        _historyAnimationController.reverse();
      });
    } else if (_currentIndex == 0) {
      _passengerAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _historyAnimationController.dispose();
    _bikeAnimationController.dispose();
    _passengerAnimationController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0; // Set current index to Passenger
        _pageController.jumpTo(0); // Navigate to Passenger screen
      });
      return false; // Prevent the app from closing
    } else {
      // Confirm exit logic
      final result = await CustomDialog.show(
        context,
        title: 'Exit App',
        content: 'Are you sure you want to exit the app?',
        cancelButtonText: 'No',
        confirmButtonText: 'Yes',
        onConfirm: () {
          SystemNavigator.pop(); // Close the app
        },
      );
      return result; // Return the result of the dialog
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;

      // Trigger the history animation when the page changes to History
      if (index == 3) {
        _historyAnimationController.forward().then((_) {
          _historyAnimationController.reverse();
        });
      } else if (index == 2) { // For the Rider screen
        _bikeAnimationController.forward();
        _passengerAnimationController.reverse(); // Reset passenger animation
      } else if (index == 0) { // For the Passenger screen
        _passengerAnimationController.forward();
        _bikeAnimationController.reverse(); // Reset bike animation
      } else {
        _bikeAnimationController.reverse();
        _passengerAnimationController.reverse();
      }
    });
  }

  void _onHistoryTapped() {
    if (_currentIndex != 3) {
      setState(() {
        _currentIndex = 3;
        _historyAnimationController.forward().then((_) {
          _historyAnimationController.reverse();
        });
      });
      _pageController.jumpToPage(3);
    } else {
      _historyAnimationController.forward().then((_) {
        _historyAnimationController.reverse();
      });
    }
  }

  void _onFindTapped() {
    // Not used for the bike animation
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _screens,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: const Color(0xFF757575),
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _pageController.jumpToPage(index);
              _historyAnimationController.reset(); // Reset history animation if navigating to another tab
              if (index == 0) {
                _passengerAnimationController.forward();
              } else {
                _passengerAnimationController.reverse();
              }
              if (index == 2) {
                _bikeAnimationController.forward();
              } else {
                _bikeAnimationController.reverse();
              }
            });
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Container(
                height: 30,
                width: 55,
                decoration: BoxDecoration(
                  color: _currentIndex == 0 ? kPrimaryColor.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Transform.scale(
                  scaleX: _passengerAnimation.value,
                  child: Icon(
                    _currentIndex == 0 ? Icons.person : Icons.person_outline_outlined,
                  ),
                ),
              ),
              label: 'Passenger',
            ),
            BottomNavigationBarItem(
              icon: Container(
                height: 30,
                width: 55,
                decoration: BoxDecoration(
                  color: _currentIndex == 1 ? kPrimaryColor.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _currentIndex == 1 ? Icons.email_rounded : Icons.email_outlined,
                ),
              ),
              label: 'Inbox',
            ),
            BottomNavigationBarItem(
              icon: Container(
                height: 30,
                width: 55,
                decoration: BoxDecoration(
                  color: _currentIndex == 2 ? kPrimaryColor.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Transform.scale(
                  scaleX: _bikeAnimation.value,
                  child: Icon(Icons.directions_car),
                ),
              ),
              label: 'Rider',
            ),
          ],
        ),
      ),
    );
  }
}
