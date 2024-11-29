
import 'package:accomodation_app/screens/profilepage/profilepage.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bookingpage/booking_page.dart';
import '../historyscreen/history_page.dart';
import '../homescreen/new_home.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final NotchBottomBarController _controller = NotchBottomBarController();
  int _currentIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HSMAccommodation(onBookingRequested: _navigateToBookingPage),
      const HistoryPage(),
      ProfilePage()
    ];
  }
  final List<String> _titles = [
    'Home Screen',
    'History',
    'Profile'
  ];

  final List<String> _imageAssets = [
    'assets/images/appBarImg.jpeg',
    'assets/images/appBarImg.jpeg',
    'assets/images/appBarImg.jpeg',
  ];


  final List<Map<String, dynamic>> _bottomBarItemsData = [
    {
      'inactiveIcon': Icons.home_filled,
      'activeIcon': Icons.home_outlined,
      'label': 'Home',
    },
    {
      'inactiveIcon': Icons.work_history,
      'activeIcon': Icons.work_history_outlined,
      'label': 'History',
    },
    {
      'inactiveIcon': Icons.person,
      'activeIcon': Icons.person_2_outlined,
      'label': 'Profile',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(shadowColor: Colors.white,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        title: Center(
          child: Container(
            color: Colors.white,
            height: Get.size.height/5,
            width: Get.size.width/2.3,
            child: Image.asset(
              _imageAssets[_currentIndex],
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        // children: _pages,
        children: _pages.map((page) => page is Function ? page : page).toList(),
      ),
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        kBottomRadius: 20.0,
        kIconSize: 24.0,
        onTap: (int value) {
          setState(() {
            _currentIndex = value;
          });
        },

        durationInMilliSeconds: 400,
        itemLabelStyle: const TextStyle(fontSize: 15, color: Colors.blueGrey),
        elevation: 2.0,
        bottomBarItems: _buildBottomBarItems(),
      ),
    );
  }

  void _navigateToBookingPage(int bedIndex, String roomNumber, String gender,String dateTime) {
    setState(() {
      _pages[1] = BookingPage(
        bedIndex: bedIndex,
        roomNumber: roomNumber,
        gender: gender,
        dateTime: dateTime,
      );
      _currentIndex = 1;
    });
  }
  List<BottomBarItem> _buildBottomBarItems() {
    return _bottomBarItemsData.map((itemData) {
      return BottomBarItem(
        inActiveItem: Icon(
          itemData['inactiveIcon'],
          color: Colors.blueGrey,
        ),
        activeItem: Icon(
          itemData['activeIcon'],
          color: Colors.deepOrangeAccent,
        ),
        itemLabel: itemData['label'],
      );
    }).toList();
  }
}
