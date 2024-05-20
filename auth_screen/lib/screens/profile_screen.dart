// ignore_for_file: use_build_context_synchronously, unused_import

import 'package:auth_screen/screens/SettingsScreen.dart'; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:auth_screen/user_profile.dart'; 
import 'sign_in_screen.dart'; 
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {  
  final FirebaseAuth _auth = FirebaseAuth.instance; 
  final ImagePicker _picker = ImagePicker(); 
  String _profileImageUrl = ""; 

  void _loadProfileImage() async {
    final user = _auth.currentUser; 
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final userModel = UserModel.fromJson(doc.data()!);
        setState(() {
          _profileImageUrl = userModel.profileImageUrl ?? "";
        });
      }    
    } 
  } 

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
          // Ensure the file path is valid
          if (filePath.isEmpty) {
            throw Exception("No image selected");
          }

          // Upload the file to Firebase Storage
          await storageRef.putFile(File(filePath));
          final downloadUrl = await storageRef.getDownloadURL();

          // Update the user's profile photo URL in FirebaseAuth
          await user.updatePhotoURL(downloadUrl);

          // Update the state to reflect the new profile image URL
          setState(() {
            _profileImageUrl = downloadUrl;
          });

          // Update Firestore with the new profile image URL
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'ProfileImageUrl': downloadUrl,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully')),
          );

        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload picture: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
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
                    onTap: _uploadProfilePicture,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey,
                      backgroundImage: _profileImageUrl.isNotEmpty
                          ? NetworkImage(_profileImageUrl)
                          : null,
                      child: _profileImageUrl.isEmpty
                          ? const Icon(Icons.add, size: 40)
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
                        MaterialPageRoute(
                            builder: (context) => const SettingsScreen()),
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
                        Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => const SignIn(), // Updated reference
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
