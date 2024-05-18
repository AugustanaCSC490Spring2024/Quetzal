import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserModel {  
  final String firstName;
  final String lastName;
  final String email;
  final String? profileImageUrl;

  UserModel({ 
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      "FirstName": firstName,
      "LastName": lastName,
      "Email": email,
      "ProfileImageUrl": profileImageUrl,
    };
  }

  static UserModel fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: json['FirstName'] ?? '',
      lastName: json['LastName'] ?? '',
      email: json['Email'] ?? '',
      profileImageUrl: json['ProfileImageUrl'],
    );
  }

  Future<void> saveToFirestore(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(toJson());
      if (kDebugMode) {
        print('User data saved to Firestore');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error saving user data to Firestore: $error');
      }
    }
  }

  Future<void> updateProfileImage(String uid, String downloadUrl) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'ProfileImageUrl': downloadUrl});
      if (kDebugMode) {
        print('User profile image updated in Firestore');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error updating profile image in Firestore: $error');
      }
    }
  }
}
