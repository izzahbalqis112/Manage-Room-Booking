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

List<Map<String, dynamic>> roomStatusJson = [
  {
    'roomStatusID': 'rs001',
    'roomStatus': 'Available', 
    'sortOrder': 1,
    'active': true,
  },
  {
    'roomStatusID': 'rs002',
    'roomStatus': 'Occupied', 
    'sortOrder': 2,
    'active': true,
  },
  {
    'roomStatusID': 'rs003',
    'roomStatus': 'Reserved', 
    'description': 'The room has been booked but not yet occupied.',
    'sortOrder': 3,
    'active': true,
  },
  {
    'roomStatusID': 'rs004',
    'roomStatus': 'Maintenance',
    'sortOrder': 4,
    'active': true,
  },
  {
    'roomStatusID': 'rs005',
    'roomStatus': 'Out of Service',
    'sortOrder': 5,
    'active': true,
  },
  {
    'roomStatusID': 'rs006',
    'roomStatus': 'In Use', 
    'sortOrder': 6,
    'active': true,
  },
];

List<RoomStatusModel> roomStatusList = roomStatusJson
    .map((json) => RoomStatusModel.fromJson(json))
    .toList();
