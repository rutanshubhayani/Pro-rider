import 'package:flutter/material.dart';
import 'package:travel/Find/Inbox/receiveInbox.dart';
import 'package:travel/Find/Passenger/findrequests.dart';
import 'package:travel/Find/find.dart';
import 'package:travel/Find/history.dart';

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
    const History(),
  ];

  late int _currentIndex;
  late AnimationController _historyAnimationController;
  late AnimationController _searchIconAnimationController;
  late Animation<double> _mirrorAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    // Initialize the AnimationController for the History icon
    _historyAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize the AnimationController for the Search icon mirroring effect
    _searchIconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Create a Tween animation to mirror the search icon
    _mirrorAnimation = Tween<double>(begin: 1.0, end: -1.0).animate(_searchIconAnimationController)
      ..addListener(() {
        setState(() {}); // Update the UI whenever the animation changes
      });
  }

  @override
  void dispose() {
    _historyAnimationController.dispose();
    _searchIconAnimationController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      // If the current tab is not 'Find', redirect to 'Find' tab
      setState(() {
        _currentIndex = 0;
      });
      return false; // Prevent the app from closing
    }
    return true; // Allow the app to close if already on the 'Find' tab
  }

  void _onHistoryTapped() {
    if (_currentIndex != 3) {
      setState(() {
        _currentIndex = 3;
        _historyAnimationController.forward().then((_) {
          _historyAnimationController.reverse(); // Reset the animation after playing
        });
      });
    } else {
      // If already on History, start the animation again
      _historyAnimationController.forward().then((_) {
        _historyAnimationController.reverse();
      });
    }
  }

  void _onFindTapped() {
    // Trigger the mirroring animation for the search icon
    _searchIconAnimationController.forward().then((_) {
      _searchIconAnimationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Handle back button press
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        body: SafeArea(child: _screens[_currentIndex]),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: const Color(0xFF757575),
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 0) {
              _onFindTapped();
            }
            if (index == 3) {
              _onHistoryTapped();
            } else {
              setState(() {
                _currentIndex = index;
                _historyAnimationController.reset(); // Reset history animation if navigating to another tab
              });
            }
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: AnimatedBuilder(
                animation: _mirrorAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scaleX: _mirrorAnimation.value, // Mirror the icon horizontally
                    child: const Icon(Icons.search),
                  );
                },
              ),
              label: 'Find',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 1 ? Icons.email_rounded : Icons.email_outlined,
              ),
              label: 'Inbox',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 2 ? Icons.person : Icons.person_outline_outlined,
              ),
              label: 'Passenger',
            ),
            BottomNavigationBarItem(
              icon: AnimatedBuilder(
                animation: _historyAnimationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _historyAnimationController.value * 2 * 3.14159, // Rotate based on the animation value
                    child: const Icon(Icons.history),
                  );
                },
              ),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
