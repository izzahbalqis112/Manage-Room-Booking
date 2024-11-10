import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfrb_managerside/main/homepage/dataModel/user.dart';
import 'booking.dart';

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}

class PaymentMethodModel {
  final String paymentID;
  final UserModel user;
  final RoomBookingModel roomBooking; // booking id
  final dynamic payment;
  final dynamic paymentType; //integrate with API
  final DateTime expirationTime; //give 30 minutes to complete the payment
  final PaymentStatus paymentStatus; //e.g., pending, completed, failed, refunded

  PaymentMethodModel({
    required this.paymentID,
    required this.user,
    required this.roomBooking,
    required this.payment,
    required this.paymentType,
    required this.expirationTime,
    required this.paymentStatus,
  });

  factory PaymentMethodModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data()!;
    return PaymentMethodModel(
      paymentID: doc.id,
      user: UserModel.fromDocument(data['user'] as DocumentSnapshot<Map<String, dynamic>>),
      roomBooking: RoomBookingModel.fromDocument(data['roomBooking'] as DocumentSnapshot<Map<String, dynamic>>),
      payment: data['payment'],
      paymentType: data['paymentType'],
      expirationTime: (data['expirationTime'] as Timestamp).toDate(),
      paymentStatus: _parsePaymentStatus(data['paymentStatus'] as String),
    );
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      paymentID: json['paymentID'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      roomBooking: RoomBookingModel.fromJson(json['roomBooking'] as Map<String, dynamic>),
      payment: json['payment'],
      paymentType: json['paymentType'],
      expirationTime: DateTime.parse(json['expirationTime'] as String),
      paymentStatus: _parsePaymentStatus(json['paymentStatus'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentID': paymentID,
      'user': user.toJson(),
      'roomBooking': roomBooking.toJson(),
      'payment': payment,
      'paymentType': paymentType,
      'expirationTime': expirationTime.toIso8601String(),
      'paymentStatus': paymentStatus.toString().split('.').last,
    };
  }

  // Method to set expiration time to 30 minutes from now
  static DateTime calculateExpirationTime() {
    return DateTime.now().add(Duration(minutes: 30));
  }

  // Method to parse payment status string to enum
  static PaymentStatus _parsePaymentStatus(String status) {
    switch (status) {
      case 'pending':
        return PaymentStatus.pending;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        throw ArgumentError('Invalid payment status: $status');
    }
  }
}


