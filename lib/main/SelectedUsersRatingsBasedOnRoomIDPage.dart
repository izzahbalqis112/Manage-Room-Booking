import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tfrb_managerside/assets/Colors.dart';
import 'package:tfrb_managerside/main/homepage/viewUserRatings/ratingBar.dart';

class SelectedUsersRatingsBasedOnRoomIDPage extends StatelessWidget {
  final String roomID;

  SelectedUsersRatingsBasedOnRoomIDPage({required this.roomID});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: shadeColor2,
          title: Text(
            'Ratings and Reviews',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.white,),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Ratings and reviews are verified and are from people who use the same room that user use',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            FutureBuilder(
              future: _fetchRoomRatings(roomID),
              builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final ratings = snapshot.data!;
                if (ratings.isEmpty) {
                  double averageRating = 0.0;
                  int totalRatings = 0;

                  return Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Text(
                                '${averageRating.toStringAsFixed(1)}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 50,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 8),
                              _buildAverageRatingStar(averageRating),
                              SizedBox(height: 8),
                              Text(
                                '$totalRatings',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Rating Distribution:',
                          style: TextStyle(
                            color: shadeColor6,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          height: 300, 
                          child: SfCartesianChart(
                            primaryXAxis: CategoryAxis(),
                            series: <CartesianSeries>[
                              BarSeries<MapEntry<int, int>, String>(
                                dataSource: [],
                                xValueMapper: (MapEntry<int, int> entry, _) => entry.key.toString(),
                                yValueMapper: (MapEntry<int, int> entry, _) => entry.value,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                double averageRating = 0.0;
                for (var rating in ratings) {
                  final bookingRatings = rating['bookingRatings'] as Map<String, dynamic>;
                  final userRating = bookingRatings['userRating'] as double;
                  averageRating += userRating;
                }
                averageRating /= ratings.length;
                int totalRatings = ratings.length;
                Map<int, int> ratingDistribution = {
                  1: 0,
                  2: 0,
                  3: 0,
                  4: 0,
                  5: 0,
                };
                for (var rating in ratings) {
                  final bookingRatings = rating['bookingRatings'] as Map<String, dynamic>;
                  final userRating = bookingRatings['userRating'] as double;
                  if (ratingDistribution.containsKey(userRating)) {
                    ratingDistribution[userRating.toInt()] = (ratingDistribution[userRating.toInt()] ?? 0) + 1;
                  }
                }

                return Container(
                  padding: EdgeInsets.symmetric(vertical: 0.5, horizontal: 16),
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              '${averageRating.toStringAsFixed(1)}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            _buildAverageRatingStar(averageRating),
                            SizedBox(height: 5),
                            Text(
                              '$totalRatings',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Rating Distribution:',
                        style: TextStyle(
                          color: shadeColor6,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 300,
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(),
                          series: <CartesianSeries>[
                            BarSeries<MapEntry<int, int>, String>(
                              dataSource: ratingDistribution.entries.toList(),
                              xValueMapper: (MapEntry<int, int> entry, _) => entry.key.toString(),
                              yValueMapper: (MapEntry<int, int> entry, _) => entry.value,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            Expanded(
              child: RatingsList(roomID: roomID),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageRatingStar(double averageRating) {
    final filledStar = Icon(
      Icons.star,
      color: Colors.amber,
      size: 30,
    );
    final halfStar = Icon(
      Icons.star_half,
      color: Colors.amber,
      size: 30,
    );
    final emptyStar = Icon(
      Icons.star_border,
      color: Colors.amber,
      size: 30,
    );
    final filledStars = averageRating.floor();
    final hasHalfStar = averageRating - filledStars >= 0.5;
    final emptyStars = 5 - filledStars - (hasHalfStar ? 1 : 0);
    final List<Widget> starIcons = List.generate(
      filledStars,
          (index) => filledStar,
    );
    if (hasHalfStar) {
      starIcons.add(halfStar);
    }
    starIcons.addAll(List.generate(
      emptyStars,
          (index) => emptyStar,
    ));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: starIcons,
    );
  }
}

class RatingsList extends StatelessWidget {
  final String roomID;

  RatingsList({required this.roomID});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _fetchRoomRatings(roomID),
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
              final userRating = bookingRatings['userRating'] as double; 
              final room = rating['room'] as Map<String, dynamic>;
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
                    SizedBox(width: 10), 
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 16.0, 
                                color: Colors.black,
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
                            style: TextStyle(fontSize: 14.0, color: shadeColor2), 
                          ),
                          Text(
                            '${room['name']}',
                            style: TextStyle(fontSize: 14.0, color: shadeColor2),
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
                            initialRating: userRating, 
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
                            },
                          ),
                        ),
                        SizedBox(width: 10), 
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
}

Future<List<DocumentSnapshot>> _fetchRoomRatings(String roomID) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('roomBookingData')
      .where('room.roomID', isEqualTo: roomID)
      .where('bookingStatus.status', isEqualTo: 'Completed')
      .get();

  List<DocumentSnapshot> filteredDocs = snapshot.docs.where((doc) {
    final bookingRatings = doc['bookingRatings'] as Map<String, dynamic>?;
    if (bookingRatings == null || !bookingRatings.containsKey('userRating')) {
      return false;
    }
    return true;
  }).toList();

  return filteredDocs;
}
