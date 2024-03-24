

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,

  });

  Map<String, dynamic> toJson(){
    return{
      "FirstName" : firstName,
      "LastName" : lastName,
      "Email" : email,
      "Password": password,
    };
  }
  Future<void> saveToFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('users').add(toJson());
      print('User data saved to Firestore');
    } catch (error) {
      print('Error saving user data to Firestore: $error');
    }
  }





}
