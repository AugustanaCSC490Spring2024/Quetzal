import 'package:flutter/material.dart';
import 'landing_page.dart';

class AppNavigation {
  static void navigateToLanding(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LandingPage()));
  }

  // Add more navigation methods as needed
}
