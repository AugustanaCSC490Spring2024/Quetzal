import 'package:flutter/material.dart';
import 'package:auth_screen/screens/sign_in_screen.dart'; // next screen

class StartingScreen extends StatefulWidget {
  const StartingScreen({super.key});

  @override
  State<StartingScreen> createState() => _StartingScreenState();
}

class _StartingScreenState extends State<StartingScreen> {
  @override
  void initState() {
    super.initState();
    const delayDuration = Duration(seconds: 4);

    Future.delayed(delayDuration, () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignIn()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
