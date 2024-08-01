import 'package:flutter/material.dart';
import 'package:travel/Inbox.dart';
import 'package:travel/drive.dart';
import 'package:travel/find.dart';
import 'package:travel/login.dart';
import 'package:travel/profilesetting.dart';
import 'package:get/get.dart';
import 'package:travel/trips.dart';
import 'package:travel/userinfo.dart';
import 'package:travel/verify.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  HomeScreen({this.initialIndex = 0});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Set initial index if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(_currentIndex);
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavBarItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(index,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Container(
            height: 40,
            width: 40,
            child: GestureDetector(
              onTap: () {
                Get.to(UserProfile());
              },
              child: Image.asset(
                'images/blogo.png',
              ),
            ),
          ),
        ),
        actions: [
          OutlinedButton.icon(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FindScreen()),
              );
            },
            label: Text(
              'Find',
              style: TextStyle(color: Colors.black),
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          InboxMain(), // Index 0
          Trips(), // Index 1
         // UserProfile(), // Index 2
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black12.withOpacity(0.46),
        currentIndex: _currentIndex,
        onTap: _onNavBarItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.message_rounded),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Trips',
          ),
         /* BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),*/
        ],
      ),
    );
  }
}

class InboxMain extends StatefulWidget {
  @override
  State<InboxMain> createState() => _InboxMainState();
}

class _InboxMainState extends State<InboxMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Inbox',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 134.0),
              child: TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Icon(Icons.archive_outlined, size: 25, color: Colors.black,),
                    SizedBox(width: 2,),
                    Text(
                      'Archived',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: Scrollbar(
          controller: ScrollController(),
          trackVisibility: true,
          thickness: 2,
          radius: Radius.circular(20),
          child: ListView.builder(
            controller: ScrollController(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Get.to(() => InboxScreen(),
                    transition: Transition.rightToLeft,
                  );
                },
                child: Inbox(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Inbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Row(
            children: [
              SizedBox(width: 17,),
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage('https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/200/300'),
              ),
              SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Smiely',
                        style: TextStyle(fontSize: 15),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 5),
                        child: Icon(Icons.circle, size: 6,),
                      ),
                      Text(
                        'Inquiry',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Brampton to Windsor',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        ' on ',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Fri, Jul 5',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://picsum.photos/200/300'),
            ),
            SizedBox(height: 10),
            Text(
              'User Name',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'abc@gmail.com',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  SizedBox(height: 10),
                  CylindricalTile(
                    leadingIcon: Icons.info_outline_rounded,
                    title: 'User Information',
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => UserInfo()));
                    },
                  ),
                  SizedBox(height: 10,),
                  CylindricalTile(
                    leadingIcon: Icons.perm_contact_calendar_outlined,
                    title: 'Profile settings',
                    onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ProfileSetting()));
                    },
                  ),
                  SizedBox(height: 10,),
                  CylindricalTile(
                    leadingIcon: Icons.credit_card,
                    title: 'Verify license',
                    onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => VerifyLicense()));
                    },
                  ),
                  SizedBox(height: 10,),
                  CylindricalTile(
                    leadingIcon: Icons.notifications,
                    title: 'Notifications',
                    onTap: (){},
                  ),
                  SizedBox(height: 10,),
                  CylindricalTile(
                    leadingIcon: Icons.help_center_outlined,
                    title: 'Help',
                    onTap: (){},
                  ),
                  SizedBox(height: 10,),
                  CylindricalTile(
                    leadingIcon: Icons.person,
                    title: 'Refer a friend',
                    onTap: (){},
                  ),
                  SizedBox(height: 10,),
                  CylindricalTile(
                    leadingIcon: Icons.logout,
                    title: 'Log Out',
                    onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginScreen()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget CylindricalTile({
  required IconData leadingIcon,
  required String title,
  required VoidCallback onTap,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30.0),
      border: Border.all(color: Colors.grey),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 7,
          offset: Offset(1, 10),
        ),
      ],
    ),
    child: ListTile(
      leading: Icon(leadingIcon),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    ),
  );
}
