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

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  final List<Widget> _screens = [
    const FindScreen(),
    const InboxList(),
    const FindRequests(),
    const History(),
  ];

  late int _currentIndex;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    // Initialize the AnimationController
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHistoryTapped() {
    if (_currentIndex != 3) {
      setState(() {
        _currentIndex = 3;
        _animationController.forward().then((_) {
          _animationController.reverse(); // Reset the animation after playing
        });
      });
    } else {
      // If already on History, start the animation again
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: SafeArea(child: _screens[_currentIndex]),
      bottomNavigationBar: Container(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: const Color(0xFF757575),
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 3) {
              _onHistoryTapped();
            } else {
              setState(() {
                _currentIndex = index;
                _animationController.reset(); // Reset animation if navigating to another tab
              });
            }
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.search),
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
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animationController.value * 2 * 3.14159, // Rotate based on the animation value
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
