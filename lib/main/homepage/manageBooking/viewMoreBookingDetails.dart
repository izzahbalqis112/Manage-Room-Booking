import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../assets/Colors.dart';

class ViewMoreSelectedBookingIDDetailsPage extends StatefulWidget {
  final String bookingId;

  ViewMoreSelectedBookingIDDetailsPage({required this.bookingId});

  @override
  _ViewMoreSelectedBookingIDDetailsPageState createState() =>
      _ViewMoreSelectedBookingIDDetailsPageState();
}

class _ViewMoreSelectedBookingIDDetailsPageState extends State<ViewMoreSelectedBookingIDDetailsPage> {
  DocumentSnapshot? bookingSnapshot;
  bool _isMounted = false;
  DateFormat dateFormat = DateFormat('dd/MM/yyyy , hh:mm a');

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    fetchBookingDetails();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void fetchBookingDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('roomBookingData')
          .doc(widget.bookingId)
          .get();
      if (_isMounted) {
        setState(() {
          bookingSnapshot = snapshot;
        });
      }
    } catch (error) {
      if (_isMounted) {
        print('Error fetching booking details: $error');
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get roomImages list
    List<dynamic> roomImages = bookingSnapshot?['room']['images'] ?? [];
    var roomName = bookingSnapshot?['room']['name'] ?? '';
    var userFirstName = bookingSnapshot?['user']['firstName'] ?? '';
    var userLastName = bookingSnapshot?['user']['lastName'] ?? '';
    var userPhoneNumber = bookingSnapshot?['user']['phoneNumber'] ?? '';

    // Get the first image URL from the list
    String firstImage = roomImages.isNotEmpty ? roomImages[0] : '';

    return Scaffold(
      backgroundColor: shadeColor3,
      appBar: AppBar(
        backgroundColor: shadeColor2,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        /*
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: Colors.white,),
            onPressed: () {
              // Implement download PDF functionality
            },
          ),
        ],

         */
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: shadeColor3,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60.0),
                  topRight: Radius.circular(60.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3), // Color of the shadow
                    spreadRadius: 5, // Spread radius
                    blurRadius: 7, // Blur radius
                    offset: Offset(0, 3), // Changes position of shadow
                  ),
                ],
              ),
              height: 160,
              width: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 46.0, top: 20.0,),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Please confirm the room booking....",
                          style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Color.fromRGBO(74, 77, 84, 1),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Office Hours",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              "Monday – Friday",
                              style: TextStyle(
                                color: shadeColor5,
                                fontSize: 14.0,
                              ),
                            ),
                            Text(
                              "8:00 am – 5:00 pm",
                              style: TextStyle(
                                color: shadeColor5,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 20, top: 10),
                          child: Image.asset(
                            "lib/assets/img/TF-logo1.png",
                            width: 80.0, // Adjust width as needed
                            height: 80.0, // Adjust height as needed
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Details About\n",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: shadeColor2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (bookingSnapshot != null)
                          TextSpan(
                            text: "Room Booking ${bookingSnapshot?['displayBookingID'] ?? ''}",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: shadeColor5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                        bottomRight:Radius.circular(60.0),
                        bottomLeft: Radius.circular(60.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3), // Color of the shadow
                          spreadRadius: 5, // Spread radius
                          blurRadius: 7, // Blur radius
                          offset: Offset(0, 3), // Changes position of shadow
                        ),
                      ],
                    ),
                    height: 550,
                    width: 480,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10,),
                        // Room Images
                        Stack(
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 100, // Adjust height as needed
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
                                        border: Border.all(color: Colors.white, width: 2), // Adjust the border color and width as needed
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: firstImage,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => CircularProgressIndicator(),
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8), // Add some spacing between the image and text
                              ],
                            ),
                            Positioned(
                              top: 55,
                              left: 130,
                              child: Text(
                                roomName,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: shadeColor6,
                                        borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0), // Adjust padding as needed
                                      child: Text(
                                        '${bookingSnapshot?['bookingStatus']['bookingStatusID'] ?? ''}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 80,
                              left: 130,
                              child: Text(
                                "${dateFormat.format(DateTime.parse(bookingSnapshot?['checkInDateTime'] ?? DateTime.now().toString()))}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 110),
                              child: HorizontalLine(
                                width: 480,
                                color: Colors.grey.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  "Guest",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Adult: ",
                                              style: TextStyle(
                                                  color: shadeColor5,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            TextSpan(
                                              text: "${bookingSnapshot?['guestsDetails']['adults'] ?? ''}",
                                              style: TextStyle(
                                                color: shadeColor6,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 40),
                                  Container(
                                    width: 1, // Adjust line width as needed
                                    height: 20, // Adjust line height as needed
                                    color: Colors.grey, // Adjust line color as needed
                                    margin: EdgeInsets.symmetric(horizontal: 10), // Add some margin around the line
                                  ),// Add
                                  SizedBox(width: 40),// some space between the texts
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Children: ",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: shadeColor5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "${bookingSnapshot?['guestsDetails']['children'] ?? ''}",
                                            style: TextStyle(
                                              color: shadeColor6,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: HorizontalLine(
                            width: 480,
                            color: Colors.grey.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  "Check-Out",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Center(
                                child: Text(
                                  "${dateFormat.format(DateTime.parse(bookingSnapshot?['checkOutDateTime'] ?? DateTime.now().toString()))}",
                                  style: TextStyle(
                                    color: shadeColor6,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: HorizontalLine(
                            width: 480,
                            color: Colors.grey.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  "Total Booking Price",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Center(
                                child: Text(
                                  "${bookingSnapshot?['totalBookingPrice'] ?? ''}",
                                  style: TextStyle(
                                    color: shadeColor6,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: HorizontalLine(
                            width: 480,
                            color: Colors.grey.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  "Booking Made By",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "$userFirstName $userLastName",
                                              style: TextStyle(
                                                  color: shadeColor5,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Container(
                                    width: 1, // Adjust line width as needed
                                    height: 20, // Adjust line height as needed
                                    color: Colors.grey, // Adjust line color as needed
                                    margin: EdgeInsets.symmetric(horizontal: 10), // Add some margin around the line
                                  ),// Add
                                  SizedBox(width: 20),// some space between the texts
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "$userPhoneNumber",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: shadeColor5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: HorizontalLine(
                            width: 480,
                            color: Colors.grey.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(height: 10,),
                        if (bookingSnapshot != null && bookingSnapshot!['note'] != null && bookingSnapshot!['note'].isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  "Note",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Center( // Center the text widget containing the note data
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Text(
                                    "${bookingSnapshot?['note'] ?? ''}",
                                    textAlign: TextAlign.center, // Align the text to the center
                                    style: TextStyle(
                                      color: shadeColor5,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                      ],
                    ),
                  ),
                ],
              ),
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
