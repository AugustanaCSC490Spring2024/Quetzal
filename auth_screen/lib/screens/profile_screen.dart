// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart'; // Add Firebase Storage
// import 'package:image_picker/image_picker.dart'; 
// import 'package:auth_screen/screens/sign_in_screen.dart';
// import 'package:auth_screen/screens/SettingsScreen.dart'; 
// import 'dart:io';  


// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final ImagePicker _picker = ImagePicker();
//   String? _profileImageUrl; // To store the profile picture URL

//   // Fetch the profile image URL from Firebase Auth
//   void _loadProfileImage() {
//     final user = _auth.currentUser;
//     if (user != null && user.photoURL != null) {
//       setState(() {
//         _profileImageUrl = user.photoURL;
//       });
//     }
//   }

//   // Upload a new profile picture and update Firebase Auth
//   Future<void> _uploadProfilePicture() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       final filePath = pickedFile.path;
//       final user = _auth.currentUser;

//       if (user != null) {
//         final storageRef = _storage.ref().child('profile_pictures/${user.uid}.jpg');

//         try {
//           await storageRef.putFile(File(filePath)); // Upload to Firebase Storage
//           final downloadUrl = await storageRef.getDownloadURL(); // Get the download URL

//           await user.updatePhotoURL(downloadUrl); // Update Firebase Auth profile
//           _loadProfileImage(); // Refresh the profile picture
//         } catch (e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to upload picture: $e')),
//           );
//         }
//       }
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadProfileImage(); // Load the current profile picture on init
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUser = _auth.currentUser;

//     return Scaffold(
//       appBar: AppBar(actions: const []),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             GestureDetector(
//               onTap: _uploadProfilePicture, // Upload on tap
//               child: CircleAvatar(
//                 radius: 60,
//                 backgroundColor: Colors.grey,
//                 backgroundImage:
//                   _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
//                 child: _profileImageUrl == null
//                   ? Icon(Icons.add, size: 40) // Placeholder '+' icon if no image
//                   : null, // No icon if there's an image
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               '${currentUser!.displayName}',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             Text(
//               '${currentUser.email}',
//               style: Theme.of(context).textTheme.titleMedium, 
//             ),
//             const SizedBox(height: 20), 
//             ProfileMenuWidget(
//               title: 'Settings',
//               iconData: Icons.settings,
//               onPress: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => SettingsScreen()),
//                 );
//               },
//             ),
//             const Divider(),
//             ProfileMenuWidget(
//               title: 'Log Out',
//               iconData: Icons.logout,
//               textColor: Colors.red,
//               onPress: () {
//                 _auth.signOut().then((value) {
//                   if (kDebugMode) {
//                     print("Signed Out.");
//                   }
//                   Navigator.of(context).popUntil((route) => route.isFirst);
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (BuildContext context) => const SignIn(),
//                     ),
//                   );
//                 });
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ProfileMenuWidget extends StatelessWidget {
//   const ProfileMenuWidget({
//     super.key,
//     required this.title,
//     required this.iconData,
//     required this.onPress,
//     this.textColor,
//   });

//   final String title;
//   final IconData iconData;
//   final VoidCallback onPress;
//   final Color? textColor;

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       onTap: onPress,
//       leading: SizedBox(
//         width: 40,
//         height: 40,
//         child: Icon(
//           iconData,
//           color: Colors.black,
//           size: 30,
//         ),
//       ),
//       title: Text(
//         title,
//         style: TextStyle(color: textColor),
//       ), 
//     );
//   }
// }


// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:auth_screen/screens/sign_in_screen.dart';
import 'package:auth_screen/screens/SettingsScreen.dart'; 
import 'dart:io';
// // // //
//import 'package:auth_screen/image_upload_service.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
// // // //

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ignore: unused_field
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  String? _profileImageUrl;
  // // // //
  //final ImageUploadService _uploadService = ImageUploadService();
  // // // //

  void _loadProfileImage() {
    final user = _auth.currentUser;
    if (user != null && user.photoURL != null) {
      setState(() {
        _profileImageUrl = user.photoURL;
      });
    }
  }
  //test picker // // // // // ///
/*
      Future<void> _pickAndUploadImage() async {
        try {
          final downloadUrl = await _uploadService.uploadProfilePicture();
          if (downloadUrl != null) {
            User? user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              await user.updatePhotoURL(downloadUrl);
              await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                'photoURL': downloadUrl,
              });
              setState(() {
                _profileImageUrl = downloadUrl;
              });
            }
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload picture: ${e.toString()}')),
          );
        }
      }

      @override
      void initState() {
        super.initState();
        _loadProfileImage();
      }
*/
  //test picker // // // // // ///


  
  Future<void> _uploadProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) { 
      final filePath = pickedFile.path;
      final user = _auth.currentUser;

      if (user != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${user.uid}.jpg'); 

        try {
          await storageRef.putFile(File(filePath));
          final downloadUrl = await storageRef.getDownloadURL();

          await user.updatePhotoURL(downloadUrl);
          _loadProfileImage();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload picture: $e')),
          );
        }
      }
    }
  }
@override 
void initState() { 
  super.initState();
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    if (kDebugMode) {
      print("User authenticated: ${user.uid}");
    }
  } else {
    if (kDebugMode) {
      print("User not authenticated");
    }
  }
  _loadProfileImage(); 
}


  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(actions: const []),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: currentUser == null
          ? const Center(
              child: Text("No user data available."),
          )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _uploadProfilePicture, ////////////////////////////////////////////////////////////////////////////////////////////////
                  //_pickAndUploadImage,  // // // // // //////////////////////////////////////////////////////////////////////////////////////////////
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                      _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : null,
                    child: _profileImageUrl == null
                      ? const Icon(Icons.add, size: 40) // Placeholder '+' icon
                      : null, 
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currentUser.displayName ?? "User",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  currentUser.email ?? "No email",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                ProfileMenuWidget(
                  title: 'Settings',
                  iconData: Icons.settings,
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
                const Divider(),
                ProfileMenuWidget(
                  title: 'Log Out',
                  iconData: Icons.logout,
                  textColor: Colors.red,
                  onPress: () {
                    _auth.signOut().then((value) {
                      if (kDebugMode) {
                        print("Signed Out.");
                      }
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const SignIn(),
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.iconData,
    required this.onPress,
    this.textColor,
  });

  final String title;
  final IconData iconData;
  final VoidCallback onPress;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: SizedBox(
        width: 40,
        height: 40,
        child: Icon(
          iconData,
          color: Colors.black,
          size: 30,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
    );
  }
}

