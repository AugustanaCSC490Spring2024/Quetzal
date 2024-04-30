

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:auth_screen/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auth_screen/user_profile.dart';
import 'package:auth_screen/password_strength.dart';
import 'package:auth_screen/sign_up_name.dart';
//import 'package:auth_screen/sign_up_email.dart';
import 'package:email_validator/email_validator.dart'; 

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MARKET SIM'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 107, 97, 7),
              Color.fromARGB(255, 7, 98, 10),
              Colors.black
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Text(
              'Join the Community',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(blurRadius: 10, color: Colors.black, offset: Offset(2, 2))
                ]
                  
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                hintText: 'First Name',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 7),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                hintText: 'Last Name',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder( 
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    // Icon for password visibility
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_passwordVisible, // switch to visible
            ),        

            const SizedBox(
              height: 7,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                hintText: 'Confirm Password',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    // Icon for password visibility
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_passwordVisible, // switch to visible
            ),
            const SizedBox(
              height: 20,
            ),
            signUpButton()
          ],
        ),
      ),
    );
  }

  Widget signUpButton() {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    onPressed: () {
      String firstName = _firstNameController.text.trim();
      String lastName = _lastNameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String confirmPassword = _confirmPasswordController.text.trim();
      String? passwordError = getPasswordStrengthError(password);

       if (firstName.isEmpty ||
            lastName.isEmpty ||
            email.isEmpty ||
            password.isEmpty ||
            confirmPassword.isEmpty
            ) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please fill in all fields'),
            backgroundColor: Colors.red,
          ));
          return;

        }
        if (!isFirstNameValid(firstName)) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('First name should be at least two letters'),
            backgroundColor: Colors.red,
          ));
          return;
      
        }

        if (!isLastNameValid(lastName)) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Last name should be at least two letters'),
            backgroundColor: Colors.red,
          ));
          return;
        

        }

        if (!EmailValidator.validate(email)) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Enter a valid email address'),
                backgroundColor: Colors.red,
              ));
              return;
            }


        if (password != confirmPassword) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ));
          return;
        }        
        
        
        if (passwordError != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(passwordError),
            backgroundColor: Colors.red,
          ));
          return;
        }


      UserModel user = UserModel(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
      user.saveToFirestore().then((_) {
        if (kDebugMode) {
          print("User data saved to Firestore");
        }
        FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((value) {
          if (kDebugMode) {
            print("Successfully created an account!");
          }
          value.user!.updateDisplayName('$firstName $lastName');
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const SignIn(),
            ),
          );
        }).catchError((error) {
          // Check if the error is related to email being already in use
          if (error is FirebaseAuthException && error.code == 'email-already-in-use') {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('The email address is already in use by another account'),
              backgroundColor: Colors.red,
            ));
          } else {
            // Handle other errors
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.red,
            ));
          }
          if (kDebugMode) {
            print("Error ${error.toString()}");
          }
        });
      });
    },
    child: const Text(
      'Sign Up',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

      
     }




  
