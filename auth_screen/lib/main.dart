import 'package:auth_screen/screens/splashscreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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

  @override
  Widget build(BuildContext context) {
    // Create a custom theme with Google Fonts that properly handles inheritance
    final textTheme = Theme.of(context).textTheme;
    final montserratTextTheme = GoogleFonts.montserratTextTheme(textTheme);

    // Define modern theme colors
    const primaryColor = Color(0xFF3A5199); // Deep blue
    const secondaryColor = Color(0xFF8C9EFF); // Periwinkle blue
    const backgroundColor = Color(0xFFF8FAFB); // Light gray background
    const accentColor = Color(0xFF62B6CB); // Teal accent

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MarketSim',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
          background: backgroundColor,
          tertiary: accentColor,
          brightness: Brightness.light,
        ),
        // Apply the Google Fonts as the default text theme with correct inheritance
        textTheme: montserratTextTheme,
        // Ensure other theme components use consistent text styles
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          titleTextStyle: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 3,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        // Set typography to handle inheritance properly
        typography: Typography.material2021(
          platform: Theme.of(context).platform,
        ),
      ),
      home: const DynamicSplashScreen(),
    );
  }
}
