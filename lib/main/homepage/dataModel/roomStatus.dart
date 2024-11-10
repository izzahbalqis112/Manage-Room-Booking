import 'package:cloud_firestore/cloud_firestore.dart';

class RoomStatusModel {
  final String roomStatusID;
  final String roomStatus;
  final int sortOrder;
  final bool active;

  RoomStatusModel({
    required this.roomStatusID,
    required this.roomStatus,
    required this.sortOrder,
    required this.active,
  });

  factory RoomStatusModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data()!;
    return RoomStatusModel(
      roomStatusID: doc.id,
      roomStatus: data['roomStatus'] as String,
      sortOrder: data['sortOrder'] as int,
      active: data['active'] as bool,
    );
  }

  factory RoomStatusModel.fromJson(Map<String, dynamic> json) {
    return RoomStatusModel(
      roomStatusID: json['roomStatusID'] as String,
      roomStatus: json['roomStatus'] as String,
      sortOrder: json['sortOrder'] as int,
      active: json['active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomStatusID': roomStatusID,
      'roomStatus': roomStatus,
      'sortOrder': sortOrder,
      'active': active,
    };
  }

  bool isActive() {
    return active;
  }

  String formattedStatus() {
    return roomStatus.toUpperCase();
  }
}

// List of room status details
List<Map<String, dynamic>> roomStatusJson = [
  {
    'roomStatusID': 'rs001',
    'roomStatus': 'Available', //The room is vacant and can be booked.
    'sortOrder': 1,
    'active': true,
  },
  {
    'roomStatusID': 'rs002',
    'roomStatus': 'Occupied', //The room is currently in use.
    'sortOrder': 2,
    'active': true,
  },
  {
    'roomStatusID': 'rs003',
    'roomStatus': 'Reserved', //The room has been booked but not yet occupied.
    'description': 'The room has been booked but not yet occupied.',
    'sortOrder': 3,
    'active': true,
  },
  {
    'roomStatusID': 'rs004',
    'roomStatus': 'Maintenance',//The room is undergoing maintenance and is not available for booking.
    'sortOrder': 4,
    'active': true,
  },
  {
    'roomStatusID': 'rs005',
    'roomStatus': 'Out of Service', //The room is temporarily out of service and cannot be booked.
    'sortOrder': 5,
    'active': true,
  },
  {
    'roomStatusID': 'rs006',
    'roomStatus': 'In Use', //room already booked and currently use
    'sortOrder': 6,
    'active': true,
  },
];

// Convert roomStatusJson to List<RoomStatusModel>
List<RoomStatusModel> roomStatusList = roomStatusJson
    .map((json) => RoomStatusModel.fromJson(json))
    .toList();
