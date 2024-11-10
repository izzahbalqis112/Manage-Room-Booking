import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfrb_managerside/main/homepage/dataModel/paymentMethod.dart';
import 'package:tfrb_managerside/main/homepage/dataModel/user.dart';
import 'booking.dart';

class PaymentHistoryModel {
  final String paymentID;
  final UserModel user;
  final RoomBookingModel roomBooking;
  final dynamic payment;
  final dynamic paymentType;
  final DateTime paymentTime;
  final PaymentStatus paymentStatus;

  PaymentHistoryModel({
    required this.paymentID,
    required this.user,
    required this.roomBooking,
    required this.payment,
    required this.paymentType,
    required this.paymentTime,
    required this.paymentStatus,
  });

  factory PaymentHistoryModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data()!;
    return PaymentHistoryModel(
      paymentID: doc.id,
      user: UserModel.fromDocument(data['user'] as DocumentSnapshot<Map<String, dynamic>>),
      roomBooking: RoomBookingModel.fromDocument(data['roomBooking'] as DocumentSnapshot<Map<String, dynamic>>),
      payment: data['payment'],
      paymentType: data['paymentType'],
      paymentTime: (data['paymentTime'] as Timestamp).toDate(),
      paymentStatus: _parsePaymentStatus(data['paymentStatus'] as String),
    );
  }

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
