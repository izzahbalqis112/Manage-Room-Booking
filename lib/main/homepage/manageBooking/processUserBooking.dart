import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../assets/Colors.dart';

class ProcessUserBookingPage extends StatefulWidget {
  @override
  _ProcessUserBookingPageState createState() => _ProcessUserBookingPageState();
}

class _ProcessUserBookingPageState extends State<ProcessUserBookingPage> {
  late Future<List<DocumentSnapshot>> _PendingBookingsFuture;

  @override
  void initState() {
    super.initState();
    _PendingBookingsFuture = _fetchPendingBookings();
  }

  Future<List<DocumentSnapshot>> _fetchPendingBookings() async {

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('roomBookingData')
        .where('bookingStatus.status', isEqualTo: 'Pending Payment')
        .get();

    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shadeColor2,
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _PendingBookingsFuture,
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
    var pendingStatus = booking['bookingStatus']['status'] ?? '';
    var totalPrice = booking['totalBookingPrice'] ?? 0;
    var checkInDate = DateTime.parse(booking['checkInDateTime'] as String).toLocal();
    var checkOutDate = DateTime.parse(booking['checkOutDateTime'] as String).toLocal();
    var userFirstName = booking['user']['firstName'] ?? '';
    var userLastName = booking['user']['lastName'] ?? '';
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

    return  Container(
      width: 500,
      height: 240,
      decoration: BoxDecoration(
        color: shadeColor3,
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
                color: shadeColor2,
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
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 110,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$numberOfDays days',
                  style: TextStyle(
                    fontSize: 14,
                    color: shadeColor5,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 160,
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
          Padding(
            padding: const EdgeInsets.only(top: 190),
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
                  'Waiting for $userFirstName $userLastName to complete the payment...',
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
