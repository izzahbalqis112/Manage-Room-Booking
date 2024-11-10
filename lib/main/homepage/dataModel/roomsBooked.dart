import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfrb_managerside/main/homepage/dataModel/rooms.dart';
import 'package:tfrb_managerside/main/homepage/dataModel/userFeedback.dart';
import 'booking.dart';

class RoomsBookedModel {
  final String roomBookedID;
  final RoomBookingModel booking;
  final RoomsModel room;
  final UserFeedbackModel userFeedback;

  RoomsBookedModel({
    required this.roomBookedID,
    required this.booking,
    required this.room,
    required this.userFeedback,
  });

  factory RoomsBookedModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data()!;
    return RoomsBookedModel(
      roomBookedID: doc.id,
      booking: RoomBookingModel.fromDocument(data['bookingID'] as DocumentSnapshot<Map<String, dynamic>>),
      room: RoomsModel.fromDocument(data['roomID'] as DocumentSnapshot<Map<String, dynamic>>),
      userFeedback: UserFeedbackModel.fromDocument(data['feedbackID'] as DocumentSnapshot<Map<String, dynamic>>),
    );
  }

  factory RoomsBookedModel.fromJson(Map<String, dynamic> json) {
    return RoomsBookedModel(
      roomBookedID: json['roomBookedID'] as String,
      booking: RoomBookingModel.fromJson(json['bookingID'] as Map<String, dynamic>),
      room: RoomsModel.fromJson(json['roomID'] as Map<String, dynamic>),
      userFeedback: UserFeedbackModel.fromJson(json['feedbackID'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomBookedID': roomBookedID,
      'bookingID': booking.bookingID,
      'roomID': room.roomID,
      'feedbackID': userFeedback.feedbackID,
    };
  }
}
