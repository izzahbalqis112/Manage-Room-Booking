import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tfrb_managerside/main/homepage/manageBooking/completedBooked/selectedBookedDetailsPage.dart';
import '../../../../Assets/Colors.dart';

class CompletedBookingPage extends StatefulWidget {
  @override
  _CompletedBookingPageState createState() => _CompletedBookingPageState();
}

class _CompletedBookingPageState extends State<CompletedBookingPage> {
  late Future<List<DocumentSnapshot>> _CompletedBookingsFuture;

  @override
  void initState() {
    super.initState();
    _CompletedBookingsFuture = _fetchCompletedBookings();
  }

  Future<List<DocumentSnapshot>> _fetchCompletedBookings() async {

    // Query Firestore for completed bookings
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('roomBookingData')
        .where('bookingStatus.status', isEqualTo: 'Completed')
        .get();

    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shadeColor2,
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _CompletedBookingsFuture,
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
                DocumentSnapshot booking = bookings[index];
                return Column(
                  children: [
                    SizedBox(height: 20),
                    SingleChildScrollView(
                      child: ContainerWidget(
                        booking: booking,
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

  const ContainerWidget({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract data from the booking document
    var displayBookingID = booking['displayBookingID'] ?? '';
    var roomName = booking['room']['name'] ?? '';
    var status = booking['bookingStatus']['status'] ?? '';
    var totalPrice = booking['totalBookingPrice'] ?? 0;
    var checkInDate = DateTime.parse(booking['checkInDateTime'] as String).toLocal();
    var checkOutDate = DateTime.parse(booking['checkOutDateTime'] as String).toLocal();

    var checkInDateNoTime = DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
    var checkOutDateNoTime = DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);
    var userFirstName = booking['user']['firstName'] ?? '';
    var userLastName = booking['user']['lastName'] ?? '';
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
      height: 240,
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
              status,
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
            top: 80,
            left: 130,
            child: TextButton( // Use TextButton for button appearance
              onPressed: () {
                // Navigate to ViewMoreSelectedBookingIDDetailsPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectedBookedDetailsPage(booking: booking,),
                  ),
                );
              },
              child: Text(
                'View More >', //click text button and go to the view selected booking details
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: shadeColor2,
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
            top: 200,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Room booking for $userFirstName $userLastName completed...',
                  style: TextStyle(
                    fontSize: 14,
                    color: shadeColor5,
                  ),
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