import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfrb_managerside/main/homepage/manageBooking/viewMoreBookingDetails.dart';
import '../../../assets/Colors.dart';
import 'PDFViewer.dart';

class ProcessBeforeFinalizedBookingPage extends StatefulWidget {
  @override
  _ProcessBeforeFinalizedBookingPageState createState() => _ProcessBeforeFinalizedBookingPageState();
}

class _ProcessBeforeFinalizedBookingPageState extends State<ProcessBeforeFinalizedBookingPage> {
  late Future<List<DocumentSnapshot>> _ProcessBeforeFinalizedBookingsFuture;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _ProcessBeforeFinalizedBookingsFuture = _fetchProcessBeforeFinalizedBookings();
  }

  Future<List<DocumentSnapshot>> _fetchProcessBeforeFinalizedBookings() async {
    // Query Firestore for pending bookings
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('roomBookingData')
        .where('bookingStatus.status', isEqualTo: 'Processing')
        .get();

    return snapshot.docs;
  }

  void _updateBookingStatus(String bookingId) async {
    try {
      DocumentSnapshot bookingSnapshot = await FirebaseFirestore.instance
          .collection('roomBookingData')
          .doc(bookingId)
          .get();

      // Extract booking details from the snapshot
      Map<String, dynamic> bookingData = bookingSnapshot.data() as Map<String, dynamic>; // Cast to Map<String, dynamic>
      String displayBookingID = bookingData['displayBookingID'] ?? '';

      await FirebaseFirestore.instance
          .collection('roomBookingData')
          .doc(bookingId)
          .update({
        'bookingStatus.status': 'Completed',
        'bookingStatus.description': 'The booking has been successfully fulfilled.',
        'bookingStatus.bookingStatusID': 'Completed',
        'bookingStatus.sortOrder': '7',
        'bookingStatus.active': 'true',
      });

      // Reload the page
      setState(() {
        _ProcessBeforeFinalizedBookingsFuture = _fetchProcessBeforeFinalizedBookings();
      });

      bool isBookingUpdate = true;
      String userEmail = bookingData['user']['email'] ?? '';

      if (isBookingUpdate) {
        // Save notification data to Firestore
        await _firestore.collection('notifications').add({
          'title': 'Teaching Factory',
          'body': 'Room booking request $displayBookingID has been complete!',
          'payload': 'completed_booking',
          'userEmail': userEmail, //based on selected booking id details data user email
          'displayBookingID': displayBookingID, ////based on selected booking id details data
        });
      }

    } catch (error) {
      print('Error updating booking status: $error');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shadeColor2,
      body:  FutureBuilder<List<DocumentSnapshot>>(
        future: _ProcessBeforeFinalizedBookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<DocumentSnapshot> bookings = snapshot.data ?? [];
            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                var booking = bookings[index];
                return Column(
                  children: [
                    SizedBox(height: 20),
                    SingleChildScrollView(
                      child: ContainerWidget(
                        booking: booking,
                        onUpdateStatus: _updateBookingStatus, // Pass the callback function
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ContainerWidget extends StatelessWidget {
  final DocumentSnapshot booking;
  final Function(String) onUpdateStatus;

  const ContainerWidget({
    Key? key,
    required this.booking,
    required this.onUpdateStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract data from the booking document
    var displayBookingID = booking['displayBookingID'] ?? '';
    var roomName = booking['room']['name'] ?? '';
    var pendingStatus = booking['bookingStatus']['status'] ?? '';
    var totalPrice = booking['totalBookingPrice'] ?? 0;
    var checkInDate = DateTime.parse(booking['checkInDateTime'] as String).toLocal();
    var checkOutDate = DateTime.parse(booking['checkOutDateTime'] as String).toLocal();

    var checkInDateNoTime = DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
    var checkOutDateNoTime = DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);

    var numberOfDays = checkOutDateNoTime.difference(checkInDateNoTime).inDays;


    List<dynamic> roomImages = booking['room']['images'] ?? [];
    DecorationImage? backgroundImage;

    if (roomImages.isNotEmpty) {
      // Assuming you want to use the first image in the list
      String imageUrl = roomImages[0];
      backgroundImage = DecorationImage(
        image: CachedNetworkImageProvider(imageUrl),
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: 500,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            right: 10,
            child: Text(
              pendingStatus,
              style: TextStyle(
                fontSize: 16,
                color: shadeColor7,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Text(
              roomName,
              style: TextStyle(
                fontSize: 18,
                color: shadeColor6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 10,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                color: Colors.white,
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                image: backgroundImage,
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking ID : $displayBookingID',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 80,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$numberOfDays days', //no of days based on check-in date & check-out date
                  style: TextStyle(
                    fontSize: 14,
                    color: shadeColor5,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 150,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalPrice',
                  style: TextStyle(
                    fontSize: 16,
                    color: shadeColor6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 90,
            left: 130,
            child: TextButton(
              onPressed: () {
                // Navigate to ViewMoreSelectedBookingIDDetailsPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewMoreSelectedBookingIDDetailsPage(
                      bookingId: booking.id, // Pass the booking ID
                    ),
                  ),
                );
              },
              child: Text(
                'View Booking Details >', //click text button and go to the view selected booking details
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: shadeColor2,
                ),
              ),
            ),
          ),
          Positioned(
            top: 196,
            child: TextButton( // Use TextButton for button appearance
              onPressed: () {
                // Navigate to PDFViewerPage based on selected booking id
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFViewerPage(
                      bookingId: booking.id, // Pass the booking ID
                    ),
                  ),
                );
              },
              child: Text(
                'View Payment Details >', //click text button and go to the view selected booking details
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 185),
            child: HorizontalLine(
              width: 480,
              color: Colors.grey.withOpacity(0.6),
            ),
          ),
          Positioned(
            top: 198,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    onUpdateStatus(booking.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: shadeColor7,
                  ),
                  child: Text('Proceed', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HorizontalLine extends StatelessWidget {
  final double width;
  final Color color;

  HorizontalLine({required this.width, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.0, // Height is 1.0 for a horizontal line
      width: width, // Adjust the width of the line as needed
      color: color,
    );
  }
}
