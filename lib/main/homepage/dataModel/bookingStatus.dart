import 'package:cloud_firestore/cloud_firestore.dart';

class BookingStatusModel {
  final String bookingStatusID;
  final String status;
  final String? description;
  final int sortOrder;
  final bool active;

  BookingStatusModel({
    required this.bookingStatusID,
    required this.status,
    this.description,
    required this.sortOrder,
    required this.active,
  });

  factory BookingStatusModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data()!;
    return BookingStatusModel(
      bookingStatusID: doc.id,
      status: data['status'] as String,
      description: data['description'] as String?,
      sortOrder: data['sortOrder'] as int,
      active: data['active'] as bool,
    );
  }

  factory BookingStatusModel.fromJson(Map<String, dynamic> json) {
    return BookingStatusModel(
      bookingStatusID: json['bookingStatusID'] as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      sortOrder: json['sortOrder'] as int,
      active: json['active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingStatusID': bookingStatusID,
      'status': status,
      'description': description,
      'sortOrder': sortOrder,
      'active': active,
    };
  }
}
