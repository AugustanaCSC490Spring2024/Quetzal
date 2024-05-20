import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
//import 'package:auth_screen/screens/sign_in_screen.dart';
//import 'package:auth_screen/screens/startingscreen.dart'; 
import 'package:auth_screen/screens/splashscreen.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import the firebase_options.dart file.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Firebase 
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

  // This widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MarketSim',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // StartingScreen
      // // Change from SignIn >> StartingScreen
      home: const DynamicSplashScreen(),
    );
  }  
}  
 