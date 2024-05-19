import 'package:flutter/material.dart';
import 'package:auth_screen/screens/sign_in_screen.dart';

class DynamicSplashScreen extends StatefulWidget {
  const DynamicSplashScreen({super.key});

  @override
  State<DynamicSplashScreen> createState() => _DynamicSplashScreenState();
}

class _DynamicSplashScreenState extends State<DynamicSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() { 
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1), 
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        _controller.reverse();
      });
    });

    loadData();
  }

  Future<void> loadData() async {
    await Future.delayed(const Duration(seconds: 5));
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SignIn()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              'MARKETSIM',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Image.asset("assets/icon/MSIM1024_1024.png", width: 180),
            FadeTransition(
              opacity: _fadeAnimation, 
              child: const Text(
                'Trade Smart',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const Spacer(),
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            const Text('Loading...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
