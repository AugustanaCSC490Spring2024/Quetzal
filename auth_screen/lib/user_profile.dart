

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserModel{
  final String firstName;
  final String lastName;
  final String email;
 

  const UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,


  });

  Map<String, dynamic> toJson(){
    return{
      "FirstName" : firstName,
      "LastName" : lastName,
      "Email" : email,

    };
  }
  Future<void> saveToFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('users').add(toJson());
      if (kDebugMode) {
        print('User data saved to Firestore');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error saving user data to Firestore: $error');
      }
    }
  }





}
