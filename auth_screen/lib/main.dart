import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:auth_screen/screens/sign_in_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import the firebase_options.dart file.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Firebase with the default Firebase options for the current platform.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    if (kDebugMode) {
      print("Firebase initialization error: $e");
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignIn(),
    );
  }
}
