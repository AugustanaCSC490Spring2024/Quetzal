import 'package:flutter/material.dart';
import 'package:auth_screen/screens/sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auth_screen/screens/home_screen.dart';


class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MARKET SIM'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.3),
                prefixIcon: Icon(Icons.email, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.3),
                prefixIcon: Icon(Icons.lock, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: true,
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ).copyWith(
                backgroundColor: MaterialStateProperty.resolveWith<Color>((states) => Colors.white),
              ),
              onPressed: () {
                String email = _emailController.text.trim();
                String password = _passwordController.text.trim();
                FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                        email: email, password: password)
                    .then((value) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) => const HomePage(),
                    ),
                  );
                }).onError((error, stackTrace) {
                  print("Error ${error.toString()}");
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  'Log In',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            signUpOption(),
          ],
        ),
      ),
    );
  }

  Widget signUpOption() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => const SignUp(),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don't have an account? ",
            style: TextStyle(color: Colors.white),
          ),
          Text(
            'Sign Up',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}

