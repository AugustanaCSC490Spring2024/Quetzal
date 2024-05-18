// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});  

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState(); 
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); 

  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) { 
      final email = _emailController.text.trim();

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent. Check your email.')),
        );
        Navigator.pop(context);
      } catch (error) {
        String errorMessage = 'Failed to send reset email.';
        if (error is FirebaseAuthException) {
          switch (error.code) {
            case 'invalid-email':
              errorMessage = 'The email address is not valid.';
              break;
            case 'user-not-found':
              errorMessage = 'No user found with this email address.';
              break;
            default:
              errorMessage = 'An unexpected error occurred. Please try again.';
              break;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your email address:',
                style: TextStyle(fontSize: 16.0),
              ), 
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
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
               Center(
                child: ElevatedButton(
                  onPressed: _sendResetEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey, // Background color
                    foregroundColor: Colors.white, // Text and icon color
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Reset'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
