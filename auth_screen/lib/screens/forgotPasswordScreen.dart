// *******************THIS OPTION IS FOR DOING THINGS BY SENDING AN EMAIL *****************//
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:auth_screen/password_util.dart';   

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState(); 
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  //final TextEditingController _newPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); 

  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset email sent. Check your email.')),
        );
        Navigator.pop(context); // Go back after sending the reset email
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending reset email: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your email address:',
                style: TextStyle(fontSize: 16.0),
              ), 
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendResetEmail,
                child: Text('Send Reset Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// ************** THIS OPTION IS FOR DOING THINGS IN APP (NOT SENDING AN EMAIL) ***************//

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:auth_screen/password_util.dart'; 


// class ChangePasswordScreen extends StatefulWidget {
//   @override
//   _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
// }

// class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
//   final TextEditingController _newPasswordController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   Future<void> _changePassword() async {
//     if (_formKey.currentState!.validate()) {
//       final newPassword = _newPasswordController.text.trim();

//       try {
//         // Update password in Firebase
//         await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Password changed successfully.')),
//         );
//         Navigator.pop(context); // Go back after success
//       } catch (error) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error changing password: $error')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Change Password'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Enter your new password:',
//                 style: TextStyle(fontSize: 16.0),
//               ),
//               TextFormField(
//                 controller: _newPasswordController,
//                 decoration: inputuation(
//                   hintText: 'New Password',
//                   border: OutlineInputBorder(),
//                 ),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a new password.';
//                   }
//                   if (!isPasswordStrong(value)) {
//                     return 'Password must have at least 8 characters, with uppercase, lowercase, numbers, and special characters.';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _changePassword,
//                 child: Text('Change Password'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
