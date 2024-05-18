

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';

// class UserModel{
//   final String firstName;
//   final String lastName;
//   final String email;
 

//   const UserModel({
//     required this.firstName,
//     required this.lastName,
//     required this.email,


//   });

//   Map<String, dynamic> toJson(){
//     return{
//       "FirstName" : firstName,
//       "LastName" : lastName,
//       "Email" : email,

//     };
//   }
//   Future<void> saveToFirestore() async {
//     try {
//       await FirebaseFirestore.instance.collection('users').add(toJson());
//       if (kDebugMode) {
//         print('User data saved to Firestore');
//       }
//     } catch (error) {
//       if (kDebugMode) {
//         print('Error saving user data to Firestore: $error');
//       }
//     }
//   }





// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart'; 

// class UserModel {
//   final String firstName;
//   final String lastName;
//   final String email;
//   final String? profileImageUrl; // Make profileImageUrl optional by adding '?'

//   const UserModel({
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//     this.profileImageUrl, // Make profileImageUrl optional
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       "firstName": firstName, 
//       "lastName": lastName,
//       "email": email,
//       "profileImageUrl": profileImageUrl, // Include profile image URL in JSON data
//     };
//   }

//   Future<void> saveToFirestore() async { 
//     try {
//       await FirebaseFirestore.instance.collection('users').add(toJson());
//       if (kDebugMode) {
//         print('User data saved to Firestore');
//       }
//     } catch (error) {
//       if (kDebugMode) {
//         print('Error saving user data to Firestore: $error');
//       }
//     }
//   }
// }
 



// import 'package:cloud_firestore/cloud_firestore.dart';

// class UserModel {
//   final String firstName;
//   final String lastName;
//   final String email; 
//   final String? profileImageUrl;

//   UserModel({
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//     this.profileImageUrl,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       "FirstName": firstName,
//       "LastName": lastName,
//       "Email": email,
//       "ProfileImageUrl": profileImageUrl,
//     };
//   }

//   static UserModel fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       firstName: json['FirstName'] ?? '',
//       lastName: json['LastName'] ?? '',
//       email: json['Email'] ?? '',
//       profileImageUrl: json['ProfileImageUrl'],
//     );
//   }

//   Future<void> saveToFirestore(String uid) async {
//     try {
//       await FirebaseFirestore.instance.collection('users').doc(uid).set(toJson());
//       print('User data saved to Firestore');
//     } catch (error) {
//       print('Error saving user data to Firestore: $error');
//     }
//   }

//   Future<void> updateProfileImage(String uid, String downloadUrl) async {
//     try {
//       await FirebaseFirestore.instance.collection('users').doc(uid).update({'ProfileImageUrl': downloadUrl});
//       print('User profile image updated in Firestore');
//     } catch (error) {
//       print('Error updating profile image in Firestore: $error');
//     }
//   }
// }


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
