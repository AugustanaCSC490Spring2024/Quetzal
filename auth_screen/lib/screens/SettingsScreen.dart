// import 'package:flutter/material.dart';
// import 'package:auth_screen/screens/editProfileScreen.dart'; 

// class SettingsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Settings'),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           ElevatedButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => EditProfileScreen()),
//               );
//             },
//             child: Text("Edit Profile"),
//           ),
//           // Other settings options can be added here
//         ],
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:auth_screen/screens/sign_in_screen.dart'; // Adjust as needed

// class SettingsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Settings'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Settings',
//               style: Theme.of(context).textTheme.headline6,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 _showDeleteConfirmationDialog(context);
//               },
//               child: Text('Delete Profile and Account'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showDeleteConfirmationDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Delete Profile and Account'),
//           content: Text(
//               'Are you sure you want to delete your profile and account? This action cannot be undone.'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); 
//               },
//               child: Text('No'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); 
//                 _deleteUserAccount(context);
//               },
//               child: Text('Yes'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _deleteUserAccount(BuildContext context) async {
//     final currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('No current user found. Please sign in again.')),
//       );
//       return;
//     }

//     try {
//       // Delete the Firestore document
//       final userDocRef = FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid);

//       await userDocRef.delete(); // Delete user data from Firestore

//       // Delete the Firebase Auth user
//       await currentUser.delete(); // Delete the Firebase Auth account

//       // Redirect to sign-in screen after account deletion
//       Navigator.of(context).popUntil((route) => route.isFirst); // Pop all screens
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SignIn(), // Adjust as needed
//         ),
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Profile and account deleted successfully')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete profile and account: ${e.toString()}')),
//       );
//     }
//   }
// }  





// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:auth_screen/screens/editProfileScreen.dart'; 
// import 'package:auth_screen/screens/sign_in_screen.dart'; 

// class SettingsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Settings'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => EditProfileScreen()),
//                 );
//               },
//               child: Text("Edit Profile"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 _showDeleteConfirmationDialog(context);
//               },
//               child: Text('Delete Profile and Account'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showDeleteConfirmationDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Delete Profile and Account'),
//           content: Text(
//               'Are you sure you want to delete your profile and account? This action cannot be undone.'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close dialog
//               },
//               child: Text('No'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close dialog
//                 _deleteUserAccount(context);
//               },
//               child: Text('Yes'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _deleteUserAccount(BuildContext context) async {
//     final currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser == null) {
//       _showSnackBar(context, 'No current user found. Please sign in again.');
//       return;
//     }

//     try {
//       if (context.mounted) {
//         // Delete the Firestore document
//         final userDocRef = FirebaseFirestore.instance
//             .collection('users')
//             .doc(currentUser.uid);

//         await userDocRef.delete(); // Delete user data from Firestore

//         await currentUser.delete(); // Delete Firebase Auth account 

//         if (context.mounted) {
//           Navigator.of(context).popUntil((route) => route.isFirst); 
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SignIn(),
//             ),
//           );  

//           _showSnackBar(context, 'Profile and account deleted successfully');
//         }
//       }
//     } catch (e) {
//       if (context.mounted) {
//         _showSnackBar(context, 'Failed to delete profile and account: ${e.toString()}');
//       }
//     }
//   }

//   void _showSnackBar(BuildContext context, String message) {
//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }
// }


//import 'dart:ffi'; 

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:auth_screen/screens/sign_in_screen.dart'; // Adjust as needed
import 'package:auth_screen/screens/editProfileScreen.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );
              },
              child: Text("Edit Profile"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showDeleteConfirmationDialog(context);
              },
              child: Text('Delete Profile and Account'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Profile and Account'),
          content: Text(
              'Are you sure you want to delete your profile and account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                _deleteUserAccount(context); // Trigger the deletion process
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUserAccount(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _showSnackBar(context, 'No current user found. Please sign in again.');
      return;
    }

    try {
      final userDocRef = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid);

      // Delete Firestore document
      await userDocRef.delete();

      // Delete Firebase Auth user
      await currentUser.delete();

      // Redirect to sign-in screen
      Navigator.of(context).popUntil((route) => route.isFirst); // Clear navigation stack
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignIn(), 
        ),
      );
    } catch (e) {
      _showSnackBar(context, 'Failed to delete profile and account: ${e.toString()}');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
