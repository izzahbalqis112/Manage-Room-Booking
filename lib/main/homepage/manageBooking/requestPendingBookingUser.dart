import 'package:flutter/material.dart';
import 'package:tfrb_managerside/main/homepage/manageBooking/pendingBooking.dart';
import 'package:tfrb_managerside/main/homepage/manageBooking/processBeforeFinalizedBooking.dart';
import 'package:tfrb_managerside/main/homepage/manageBooking/processUserBooking.dart';
import 'package:tfrb_managerside/main/homepage/manageBooking/rejectedBookig.dart';
import '../../../assets/Colors.dart';
import 'cancelledBooking.dart';
import 'completedBooked/completedBooking.dart';

class RequestPendingBookingPage extends StatefulWidget {
  final int initialTabIndex;

  RequestPendingBookingPage({required this.initialTabIndex});

  @override
  _RequestPendingBookingPageState createState() => _RequestPendingBookingPageState();
}

class _RequestPendingBookingPageState extends State<RequestPendingBookingPage> with SingleTickerProviderStateMixin{
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: shadeColor3,
        title: Text(
          "Manage User Rooms Booking",
          style: TextStyle(
            color: shadeColor6,
            fontWeight: FontWeight.bold, // Making the text bold
          ),
          textAlign: TextAlign.center, // Centering the text
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.close, color: shadeColor7),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: shadeColor2,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.grey.withOpacity(0.8),
          ),
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Process'),
            Tab(text: 'Payment Details'),
            Tab(text: 'Complete'),
            Tab(text: 'Cancel'),
            Tab(text: 'Reject'),
          ],
          indicatorColor: shadeColor2,
          indicatorWeight: 4.0,
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PendingBookingPage(),
          ProcessUserBookingPage(),
          ProcessBeforeFinalizedBookingPage(),
          CompletedBookingPage(),
          CancelledBookingPage(),
          RejectingBookingPage(),
        ],
      ),
    );
  }
}
