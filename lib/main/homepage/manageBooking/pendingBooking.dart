import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tfrb_managerside/main/homepage/manageBooking/requestPendingBookingUser.dart';
import 'package:tfrb_managerside/main/homepage/manageBooking/viewMoreBookingDetails.dart';
import '../../../assets/Colors.dart';
import '../../../localNotifications.dart';

class PendingBookingPage extends StatefulWidget {
  @override
  _PendingBookingPageState createState() => _PendingBookingPageState();
}

class _PendingBookingPageState extends State<PendingBookingPage> {
  late Future<List<DocumentSnapshot>> _pendingBookingsFuture;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _pendingBookingsFuture = _fetchPendingBookings();
  }

  Future<List<DocumentSnapshot>> _fetchPendingBookings() async {
    // Query Firestore for pending bookings
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('roomBookingData')
        .where('bookingStatus.status', isEqualTo: 'Pending')
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
        'bookingStatus.status': 'Confirmed',
        'bookingStatus.description': 'The booking has been successfully reserved and is confirmed for the specified date and time.',
        'bookingStatus.bookingStatusID': 'Confirmed',
        'bookingStatus.sortOrder': '2',
        'bookingStatus.active': 'true',
      });

      // Reload the page
      setState(() {
        _pendingBookingsFuture = _fetchPendingBookings();
      });

      // Assuming the booking is successfully saved
      bool isBookingUpdate = true;
      String userEmail = bookingData['user']['email'] ?? '';

      if (isBookingUpdate) {
        LocalNotifications.showSimpleNotification(
          title: 'Teaching Factory',
          body: 'User booking request has been confirm!',
          payload: 'confirm_booking',
        );

        // Save notification data to Firestore
        await _firestore.collection('notifications').add({
          'title': 'Teaching Factory',
          'body': 'Room booking request $displayBookingID has been confirm!',
          'payload': 'confirm_booking',
          'userEmail': userEmail, //based on selected booking id details data user email
          'displayBookingID': displayBookingID, ////based on selected booking id details data
        });
      }
    } catch (error) {
      print('Error updating booking status: $error');
      // Handle error
    }
  }

  void _rejectBooking(String bookingId) async {
    try {
      // Show rejection reason form
      _showRejectionReasonForm(bookingId);
    } catch (error) {
      print('Error rejecting booking: $error');
      // Handle error
    }
  }


  void _showRejectionReasonForm(String bookingId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return RejectionReasonForm(
          bookingId: bookingId,
          onReasonSubmitted: (String reason) {
            _saveRejectionReason(bookingId, reason);
          },
          onCancel: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _saveRejectionReason(String bookingId, String reason) async {
    try {
      // Update Firestore with the rejection reason
      await FirebaseFirestore.instance
          .collection('roomBookingData')
          .doc(bookingId)
          .update({
        'bookingStatus.status': 'Rejected',
        'bookingStatus.description': 'The booking has been rejected by our staff TF',
        'bookingStatus.bookingStatusID': 'Rejected',
        'bookingStatus.sortOrder': '3',
        'bookingStatus.active': 'true',
        'bookingStatus.reason': reason,
      });

      // Reload the page
      setState(() {
        _pendingBookingsFuture = _fetchPendingBookings();
      });

      // Navigate to the rejected page after saving the reason
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RequestPendingBookingPage(initialTabIndex: 4)),
      );
    } catch (error) {
      print('Error saving rejection reason: $error');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shadeColor2,
      body:  FutureBuilder<List<DocumentSnapshot>>(
        future: _pendingBookingsFuture,
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
                        onReject: _rejectBooking, // Pass the reject callback

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
  final Function(String) onReject;

  const ContainerWidget({
    Key? key,
    required this.booking,
    required this.onUpdateStatus,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract data from the booking document
    var displayBookingID = booking['displayBookingID'] ?? '';
    var roomName = booking['room']['name'] ?? '';
    var userFirstName = booking['user']['firstName'] ?? '';
    var userLastName = booking['user']['lastName'] ?? '';
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
      height: 300,
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
            top: 80,
            left: 130,
            child: TextButton( // Use TextButton for button appearance
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
                  'Request room booking from $userFirstName $userLastName',
                  style: TextStyle(
                    fontSize: 14,
                    color: shadeColor5,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 230,
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
                  child: Text('Accept', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
          Positioned(
            top: 230,
            right: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    onReject(booking.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Reject', style: TextStyle(color: Colors.white),),
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

class RejectionReasonForm extends StatefulWidget {
  final String bookingId;
  final Function(String) onReasonSubmitted;
  final VoidCallback onCancel;

  RejectionReasonForm({required this.bookingId, required this.onReasonSubmitted, required this.onCancel});

  @override
  _RejectionReasonFormState createState() => _RejectionReasonFormState();
}

class _RejectionReasonFormState extends State<RejectionReasonForm> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Reason for Rejection',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter reason here...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: Text('Cancel'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  String reason = _reasonController.text.trim();
                  if (reason.isNotEmpty) {
                    widget.onReasonSubmitted(reason);
                    Navigator.pop(context); // Close the bottom sheet after submitting reason
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(shadeColor2),
                ),
                child: Text('Submit', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}