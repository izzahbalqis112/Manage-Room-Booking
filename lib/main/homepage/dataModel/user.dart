import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userID;
  final String email;
  final String password;
  final String firstName;
  final String? lastName;
  final String? picture;
  final String companyName;
  final String phoneNumber;

  UserModel({
    required this.userID,
    required this.email,
    required this.password,
    required this.firstName,
    this.lastName,
    this.picture,
    required this.companyName,
    required this.phoneNumber,
  });

  factory UserModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data()!;
    return UserModel(
      userID: doc.id,
      email: data['email'] as String,
      password: data['password'] as String,
      firstName: data['firstName'] as String,
      lastName: data['lastName'] as String?,
      companyName: data['companyName'] as String,
      phoneNumber: data['phoneNumber'] as String,
      picture: data['picture'] as String?,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userID: json['userID'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      companyName: json['companyName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      picture: json['picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'companyName': companyName,
      'phoneNumber': phoneNumber,
      'picture': picture,
    };
  }
}
