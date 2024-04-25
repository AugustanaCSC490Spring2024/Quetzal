// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; 
// import 'package:auth_screen/screens/ChangePasswordScreen.dart'; 

// class EditProfileScreen extends StatefulWidget {
//   @override
//   _EditProfileScreenState createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       final displayNameParts = currentUser.displayName?.split(' ') ?? [];
//       _firstNameController.text = displayNameParts.isNotEmpty ? displayNameParts[0] : '';
//       _lastNameController.text = displayNameParts.length > 1 ? displayNameParts[1] : '';
//       _emailController.text = currentUser.email ?? '';
//     }
//   }

//   Future<void> _saveChanges() async {
//     final currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser != null) {
//       try {
//         await currentUser.updateEmail(_emailController.text);
//         await currentUser.updateDisplayName('${_firstNameController.text} ${_lastNameController.text}');
        
//         // Update Firestore with the new information
//         await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .update({
//             'firstName': _firstNameController.text,
//             'lastName': _lastNameController.text,
//             'email': _emailController.text,
//           });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Profile updated successfully')),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to update profile: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Profile'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextField(
//                 controller: _firstNameController,
//                 decoration: InputDecoration(
//                   labelText: 'First Name',
//                 ),
//               ),
//               TextField(
//                 controller: _lastNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Last Name',
//                 ),
//               ),
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                 ),
//               ),
//               const SizedBox(height: 20),

//               ElevatedButton(
//                 onPressed: _saveChanges,
//                 child: Text('Save Changes'),
//               ),

//               const SizedBox(height: 20),

//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ChangePasswordScreen(),  
//                     ),
//                   );
//                 },
//                 child: Text('Change Password'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   } 
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:auth_screen/user_profile.dart';   
import 'package:auth_screen/screens/ChangePasswordScreen.dart'; 

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final displayNameParts = currentUser.displayName?.split(' ') ?? [];
      _firstNameController.text = displayNameParts.isNotEmpty ? displayNameParts[0] : '';
      _lastNameController.text = displayNameParts.length > 1 ? displayNameParts[1] : '';
      _emailController.text = currentUser.email ?? '';
    }
  }

  Future<void> _saveChanges() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No current user found. Please sign in again.')),
      );
      return;
    }

    try {
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid);

      // Update Firestore with new user information
      await userDocRef.set({
        'FirstName': _firstNameController.text,
        'LastName': _lastNameController.text,
        'Email': _emailController.text,
      }, SetOptions(merge: true)); // SetOptions with merge to update without overwriting

      // Update Firebase Authentication
      if (_emailController.text != currentUser.email) {
        final AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: 'current-password', // Placeholder for actual re-authentication
        );
        await currentUser.reauthenticateWithCredential(credential);
        await currentUser.updateEmail(_emailController.text);
      }

      await currentUser.updateDisplayName('${_firstNameController.text} ${_lastNameController.text}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                ),
              ),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                ),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes'),
              ),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(), 
                    ),
                  );
                },
                child: Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
