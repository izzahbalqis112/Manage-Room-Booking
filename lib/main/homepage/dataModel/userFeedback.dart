import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfrb_managerside/main/homepage/dataModel/user.dart';
import 'booking.dart'; // Assuming there's a user model

class UserFeedbackModel {
  final String feedbackID;
  final RoomBookingModel booking;
  final int rating; // Numeric rating given by the user (e.g., on a scale of 1 to 5).
  final String reviews; // comment by user
  final UserModel user;
  final DateTime feedbackDateTime;

  UserFeedbackModel({
    required this.feedbackID,
    required this.booking,
    required this.rating,
    required this.reviews,
    required this.user,
    required this.feedbackDateTime,
  });

  factory UserFeedbackModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data()!;
    return UserFeedbackModel(
      feedbackID: doc.id,
      booking: RoomBookingModel.fromDocument(data['bookingID'] as DocumentSnapshot<Map<String, dynamic>>),
      rating: data['rating'] as int,
      reviews: data['reviews'] as String,
      user: UserModel.fromDocument(data['userID'] as DocumentSnapshot<Map<String, dynamic>>), // Assuming there's a user model
      feedbackDateTime: (data['feedbackDateTime'] as Timestamp).toDate(),
    );
  }

  factory UserFeedbackModel.fromJson(Map<String, dynamic> json) {
    return UserFeedbackModel(
      feedbackID: json['feedbackID'] as String,
      booking: RoomBookingModel.fromJson(json['bookingID'] as Map<String, dynamic>),
      rating: json['rating'] as int,
      reviews: json['reviews'] as String,
      user: UserModel.fromJson(json['userID'] as Map<String, dynamic>), // Assuming there's a user model
      feedbackDateTime: (json['feedbackDateTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feedbackID': feedbackID,
      'bookingID': booking.bookingID,
      'rating': rating,
      'reviews': reviews,
      'userID': user.userID,
      'feedbackDateTime': feedbackDateTime,
    };
  }
}
