import 'package:flutter/foundation.dart';   
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:auth_screen/screens/sign_in_screen.dart';
import 'package:auth_screen/screens/SettingsScreen.dart'; 
import 'dart:io';  

class ProfileScreen extends StatefulWidget { 
  const ProfileScreen({Key? key}); 

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ImagePicker _picker = ImagePicker();
  String _profileImageUrl = "";

  void _loadProfileImage() async {
    final user = _auth.currentUser;
    if (user != null && user.photoURL != null) { 
      setState(() {
        _profileImageUrl = user.photoURL!; 
      });
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
                  onTap: _uploadProfilePicture, 
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                      _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl) 
                        : null,
                    child: _profileImageUrl == null
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
    Key? key,
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
