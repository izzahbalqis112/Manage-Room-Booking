import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfrb_managerside/main/homepage/dataModel/roomStatus.dart';

class RoomsModel {
  final String roomID;
  List<String> images;
  final String name;
  final String about;
  final int capacity;
  final RoomStatusModel roomStatus;
  final double roomPrice; 
  List<String>? roomFacilities;
  final double roomArea;

  RoomsModel({
    required this.roomID,
    required this.name,
    required this.capacity,
    required this.roomStatus,
    required this.images,
    required this.about,
    required this.roomPrice, 
    this.roomFacilities,
    required this.roomArea, 
  });

  factory RoomsModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data()!;
    return RoomsModel(
      roomID: doc.id,
      name: data['name'] as String,
      about: data['about'] as String,
      capacity: data['capacity'] as int,
      roomStatus: RoomStatusModel.fromDocument(data['roomStatus'] as DocumentSnapshot<Map<String, dynamic>>),
      roomPrice: (data['roomPrice'] ?? 0.0) as double, 
      roomFacilities: (data['roomFacilities'] ?? []) as List<String>?,
      roomArea: (data['roomArea'] ?? 0.0) as double,
      images: (data['images'] ?? []) as List<String>,
    );
  }

  factory RoomsModel.fromJson(Map<String, dynamic> json) {
    return RoomsModel(
      roomID: json['roomID'] as String,
      name: json['name'] as String,
      about: json['about'] as String,
      capacity: json['capacity'] as int,
      roomStatus: RoomStatusModel.fromJson(json['roomStatus'] as Map<String, dynamic>),
      roomPrice: (json['roomPrice'] ?? 0.0) as double,
      roomFacilities: (json['roomFacilities'] ?? []) as List<String>?,
      roomArea: (json['roomArea'] ?? 0.0) as double,
      images: json['images'] != null ? List<String>.from(json['images'] as List<dynamic>) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomID': roomID,
      'name': name,
      'about': about,
      'capacity': capacity,
      'roomStatus': roomStatus.roomStatus,
      'roomPrice': roomPrice,
      'roomFacilities': roomFacilities,
      'roomArea': roomArea,
      'images': images,
    };
  }
}
