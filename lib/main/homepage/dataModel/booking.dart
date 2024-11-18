import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfrb_managerside/main/homepage/dataModel/user.dart';
import '../../../managerModel.dart';
import 'bookingStatus.dart';

class RoomBookingModel {
  final String bookingID;
  final Timestamp dateTimeBookingMade;
  final UserModel user;
  final ManagerModel manager;
  final DateTime checkInDateTime;
  final DateTime checkOutDateTime;
  final BookingStatusModel bookingStatus;
  final int? guestsNo;
  final String totalBookingPrice;
  final dynamic cancellationPolicy;

  RoomBookingModel({
    required this.bookingID,
    required this.dateTimeBookingMade,
    required this.user,
    required this.manager,
    required this.checkInDateTime,
    required this.checkOutDateTime,
    required this.bookingStatus,
    this.guestsNo,
    required this.totalBookingPrice,
    required this.cancellationPolicy,
  });

  factory RoomBookingModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data()!;
    return RoomBookingModel(
      bookingID: doc.id,
      dateTimeBookingMade: data['dateTimeBookingMade'] as Timestamp,
      user: UserModel.fromDocument(data['user'] as DocumentSnapshot<Map<String, dynamic>>),
      manager: ManagerModel.fromDocument(data['manager'] as DocumentSnapshot<Map<String, dynamic>>),
      checkInDateTime: (data['checkInDateTime'] as Timestamp).toDate(),
      checkOutDateTime: (data['checkOutDateTime'] as Timestamp).toDate(),
      bookingStatus: BookingStatusModel.fromDocument(data['bookingStatus'] as DocumentSnapshot<Map<String, dynamic>>),
      guestsNo: data['guestsNo'] as int?,
      totalBookingPrice: data['totalBookingPrice'] as String,
      cancellationPolicy: data['cancellationPolicy'],
    );
  }

  factory RoomBookingModel.fromJson(Map<String, dynamic> json) {
    return RoomBookingModel(
      bookingID: json['bookingID'] as String,
      dateTimeBookingMade: json['dateTimeBookingMade'] as Timestamp,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      manager: ManagerModel.fromJson(json['manager'] as Map<String, dynamic>),
      checkInDateTime: DateTime.parse(json['checkInDateTime'] as String),
      checkOutDateTime: DateTime.parse(json['checkOutDateTime'] as String),
      bookingStatus: BookingStatusModel.fromJson(json['bookingStatus'] as Map<String, dynamic>),
      guestsNo: json['guestsNo'] as int?,
      totalBookingPrice: json['totalBookingPrice'] as String,
      cancellationPolicy: json['cancellationPolicy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingID': bookingID,
      'dateTimeBookingMade': dateTimeBookingMade,
      'user': user.toJson(),
      'manager': manager.toJson(),
      'checkInDateTime': checkInDateTime.toIso8601String(),
      'checkOutDateTime': checkOutDateTime.toIso8601String(),
      'bookingStatus': bookingStatus.toJson(),
      'guestsNo': guestsNo,
      'totalBookingPrice': totalBookingPrice,
      'cancellationPolicy': cancellationPolicy,
    };
  }
}
