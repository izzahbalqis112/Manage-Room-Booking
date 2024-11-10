import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tfrb_managerside/assets/Colors.dart';
import 'package:tfrb_managerside/main/homepage/viewUserRatings/ratingBar.dart';

class ViewAllRatingsPage extends StatefulWidget {
  @override
  _ViewAllRatingsPageState createState() => _ViewAllRatingsPageState();
}

class _ViewAllRatingsPageState extends State<ViewAllRatingsPage> {
  String? selectedDateFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: shadeColor2,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Ratings and Reviews',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedDateFilter,
              hint: Text('Filter by date'),
              onChanged: (newValue) {
                setState(() {
                  selectedDateFilter = newValue;
                });
              },
              items: <String>['Today', 'Yesterday', 'This Week', 'This Month', 'This Year']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(child: RatingsList(dateFilter: selectedDateFilter)),
        ],
      ),
    );
  }
}

class RatingsList extends StatelessWidget {
  final String? dateFilter;

  RatingsList({this.dateFilter});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _fetchCompletedBookings(),
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final ratings = snapshot.data!;

        return SingleChildScrollView(
          child: Column(
            children: ratings.map((rating) {
              final bookingRatings = rating['bookingRatings'] as Map<String, dynamic>;

              if (bookingRatings == null || !bookingRatings.containsKey('userRating') || bookingRatings['userRating'] == null) {
                // Return a ListTile with an empty state or a message
                return ListTile(
                  title: Text(
                    'No ratings available',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              final user = rating['user'] as Map<String, dynamic>;
              final userRating = bookingRatings['userRating'] as double; // Assuming userRating is a double
              final room = rating['room'] as Map<String, dynamic>;

              // Format the date and time
              final dateTime = (bookingRatings['dateTimeToday'] as Timestamp).toDate();
              final formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
              final formattedTime = DateFormat('hh:mm a').format(dateTime);

              return ListTile(
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        user['picture'] ?? '',
                      ),
                    ),
                    SizedBox(width: 10), // Add some spacing between the image and text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 16.0, // Adjust the font size as needed
                                color: Colors.black, // Define the text color
                              ),
                              children: [
                                TextSpan(text: '${user['firstName']} ', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: user['lastName']),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Booking ID ${rating['displayBookingID']}',
                            style: TextStyle(fontSize: 14.0, color: shadeColor2), // Adjust the font size as needed
                          ),
                          Text(
                            '${room['name']}',
                            style: TextStyle(fontSize: 14.0, color: shadeColor2), // Adjust the font size as needed
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: RatingBar.builder(
                            initialRating: userRating, // Set the initial rating
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 20.0,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              // Dummy function, as it won't be used
                            },
                          ),
                        ),
                        SizedBox(width: 10), // Add some spacing between the rating bar and text
                        Text('$formattedDate , $formattedTime', style: TextStyle(fontSize: 14.0)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('${bookingRatings['reviews']}', style: TextStyle(fontSize: 16.0)),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<List<DocumentSnapshot>> _fetchCompletedBookings() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('roomBookingData')
        .where('bookingStatus.status', isEqualTo: 'Completed')
        .get();

    DateTime now = DateTime.now();
    List<DocumentSnapshot> filteredDocs = snapshot.docs.where((doc) {
      final bookingRatings = doc['bookingRatings'] as Map<String, dynamic>?;
      if (bookingRatings == null || !bookingRatings.containsKey('userRating')) {
        return false;
      }
      final dateTime = (bookingRatings['dateTimeToday'] as Timestamp).toDate();

      switch (dateFilter) {
        case 'Today':
          return DateFormat('yyyy-MM-dd').format(dateTime) == DateFormat('yyyy-MM-dd').format(now);
        case 'Yesterday':
          return DateFormat('yyyy-MM-dd').format(dateTime) == DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: 1)));
        case 'This Week':
          DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
          DateTime weekEnd = weekStart.add(Duration(days: 6));
          return dateTime.isAfter(weekStart) && dateTime.isBefore(weekEnd.add(Duration(days: 1)));
        case 'This Month':
          return dateTime.month == now.month && dateTime.year == now.year;
        case 'This Year':
          return dateTime.year == now.year;
        default:
          return true;
      }
    }).toList();

    return filteredDocs;
  }
}
