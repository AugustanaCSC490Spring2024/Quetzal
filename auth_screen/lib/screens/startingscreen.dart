
import 'package:flutter/material.dart';
import 'package:auth_screen/screens/sign_in_screen.dart'; // next screen

class StartingScreen extends StatelessWidget {
  const StartingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const delayDuration = Duration(seconds: 4);

    Future.delayed(delayDuration, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignIn()),
      );
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/sim.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  } 
}
