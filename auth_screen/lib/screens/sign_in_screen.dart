// ignore_for_file: non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auth_screen/screens/home_screen.dart';
import 'package:auth_screen/screens/sign_up_screen.dart';
import 'package:auth_screen/screens/forgotPasswordScreen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordHidden = true; // Manage password visibility

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(''),
      centerTitle: true,
      backgroundColor: Colors.blueGrey,
    ),
    body: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage("assets/images/Growing Stock Index.gif"),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.5), BlendMode.dstATop),
            ),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 80,  // Fixed height container
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedText('MARKET SIM'),
                    AnimatedText('MARKET SIM'),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              buildTextField(_emailController, 'Email', Icons.email),
              const SizedBox(height: 15),
              buildPasswordField(),
              const SizedBox(height: 20),
              logInButton(),
              const SizedBox(height: 20),
              signUpOptionWithBackground(),
              const SizedBox(height: 10),
              forgotPasswordCentered(),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget AnimatedText(String text) {
  return DefaultTextStyle(
    style: const TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    child: AnimatedTextKit(
      animatedTexts: [ScaleAnimatedText(text, scalingFactor: 0.3)],
      repeatForever: true,
      pause: const Duration(milliseconds: 2000), // Optional: Adjust pause duration
    ),
  );
}


  Widget buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _isPasswordHidden,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock, color: Colors.white),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isPasswordHidden = !_isPasswordHidden;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget logInButton() {
    return ElevatedButton(
      onPressed: () {
        String email = _emailController.text.trim();
        String password = _passwordController.text.trim();
        FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((value) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const HomePage()));
        }).catchError((error) {
          if (error is FirebaseAuthException) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Incorrect password or email'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text('Log In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget signUpOptionWithBackground() {
    return Container(
      color: Colors.white.withOpacity(0.3),
      padding: const EdgeInsets.all(8),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const SignUp()));
        },
        child: RichText(
  text: const TextSpan(
            style: TextStyle( // Default text style for the entire block
              fontSize: 16.0,
              color: Colors.black,
            ),
            children: <TextSpan>[
              TextSpan(text: "Don't have an account? "), // Normal text
              TextSpan(
                text: 'Sign Up', // Bold part
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        )
      ),
    );
  }


  Widget forgotPasswordCentered() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
        },
        child: RichText(
            text: const TextSpan(
            style: TextStyle( // Default text style for the entire block
              fontSize: 16.0,
              color: Colors.black,
            ),
            children: <TextSpan>[
              TextSpan(text: "Did you forget your password? "), // Normal text
              TextSpan(
                text: 'Forgot Password.', // Bold part
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            
            ],
          ),
        ),
      ),
    );
    
  }
  
  Widget termsAndConditionsLink() {
  return GestureDetector(
    onTap: () {
      // Implement navigation to your terms and conditions screen
      if (kDebugMode) {
        print("Navigating to Terms and Conditions screen.");
      }
    },
    child: const Text(
      "Terms and Conditions",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white70, // Adjust the color to fit your theme
        fontSize: 12,
        decoration: TextDecoration.underline,
      ),
    ),
  );
  
}


}


