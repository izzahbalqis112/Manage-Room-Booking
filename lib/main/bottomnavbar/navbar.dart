import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:tfrb_managerside/main/managestaff/navDropdownMenu.dart';
import 'package:tfrb_managerside/main/notifications/notification.dart';
import '../../Assets/Colors.dart';
import '../homepage.dart';
import '../profile/profilepage.dart';

class ButtomNavBar extends StatefulWidget {
  @override
  _ButtomNavBarState createState() => _ButtomNavBarState();
}

class _ButtomNavBarState extends State<ButtomNavBar> {
  int index = 1;

  final screens = [
    NavDropdownMenu(title: "Manager"),
    Homepage(),
    NotificationPage(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    final items = <Widget> [
      Icon(Icons.people, size: 20, color: Colors.white,),
      Icon(Icons.home, size: 20, color: Colors.white,),
      Icon(Icons.notifications, size: 20, color: Colors.white,),
      Icon(Icons.person, size: 20, color: Colors.white,),
    ];
    return Container(
      color: shadeColor1,
      child: SafeArea(
        top: false,
        child: Scaffold(
          extendBody: true,
          body: screens[index],
          bottomNavigationBar: CurvedNavigationBar(
            height: 60,
            index: index,
            items: items,
            color: shadeColor2,
            //buttonBackgroundColor: shadeColor1,
            animationDuration: Duration(milliseconds: 300),
            backgroundColor: Colors.transparent,
            onTap: (newIndex) {
              setState(() {
                index = newIndex;
              });
            },
          ),
        ),
      ),
    );
  }
}
