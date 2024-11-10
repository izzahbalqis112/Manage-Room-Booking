import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerModel {
  final String managerID;
  final String email;
  final String password;
  final String firstName;
  final String? lastName;
  final String? picture;
  final String utemStaffID;
  final String role; // Change type to String

  ManagerModel({
    required this.managerID,
    required this.email,
    required this.password,
    required this.utemStaffID,
    required this.role, // Change type to String
    required this.firstName,
    this.lastName,
    this.picture,
  });

  factory ManagerModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data()!;
    return ManagerModel(
      managerID: doc.id,
      email: data['email'] as String,
      password: data['password'] as String,
      firstName: data['firstName'] as String,
      lastName: data['lastName'] as String?,
      utemStaffID: data['utemStaffID'] as String,
      role: data['role'] as String, // Store role directly as a string
      picture: data['picture'] as String?,
    );
  }

  factory ManagerModel.fromJson(Map<String, dynamic> json) {
    return ManagerModel(
      managerID: json['managerID'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      utemStaffID: json['utemStaffID'] as String,
      role: json['role'] as String, // Store role directly as a string
      picture: json['picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'managerID': managerID,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'utemStaffID': utemStaffID,
      'role': role,
      'picture': picture,
    };
  }
}
