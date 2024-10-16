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
    const History(),
  ];

  late int _currentIndex;
  late PageController _pageController;
  late AnimationController _historyAnimationController;
  late AnimationController _searchIconAnimationController;
  late Animation<double> _mirrorAnimation;

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

    _searchIconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Create a Tween animation to mirror the search icon
    _mirrorAnimation = Tween<double>(begin: 1.0, end: -1.0)
        .animate(_searchIconAnimationController)
      ..addListener(() {
        setState(() {});
      });


    if (_currentIndex == 3) {
      _historyAnimationController.forward().then((_) {
        _historyAnimationController.reverse();
      }
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _historyAnimationController.dispose();
    _searchIconAnimationController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
        _pageController.jumpToPage(0);
      });
      return false; // Prevent the app from closing
    } else {
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
      return result;
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
    _searchIconAnimationController.forward().then((_) {
      _searchIconAnimationController.reverse();
    });
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
            if (index == 0) {
              // Check if we're already on the Find tab
              if (_currentIndex != 0) {
                setState(() {
                  _currentIndex = 0;
                  _pageController.jumpToPage(0);
                });
              }
              // Trigger the search icon animation even if already on the Find tab
              _onFindTapped();
            } else if (index == 3) {
              _onHistoryTapped();
            } else {
              setState(() {
                _currentIndex = index;
                _pageController.jumpToPage(index);
                _historyAnimationController.reset(); // Reset history animation if navigating to another tab
              });
            }
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
                child: AnimatedBuilder(
                  animation: _mirrorAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scaleX: _mirrorAnimation.value,
                      child: const Icon(Icons.search),
                    );
                  },
                ),
              ),
              label: 'Find',
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
                child: Icon(
                  _currentIndex == 2 ? Icons.person : Icons.person_outline_outlined,
                ),
              ),
              label: 'Passenger',
            ),
            BottomNavigationBarItem(
              icon: Container(
                height: 30,
                width: 55,
                decoration: BoxDecoration(
                  color: _currentIndex == 3 ? kPrimaryColor.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AnimatedBuilder(
                  animation: _historyAnimationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _historyAnimationController.value * 2 * 3.14159,
                      child: const Icon(Icons.history),
                    );
                  },
                ),
              ),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
