// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auth_screen/screens/forgotPasswordScreen.dart';
import 'package:auth_screen/screens/home_screen.dart';
import 'package:auth_screen/screens/sign_up_screen.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // Controllers for form fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordHidden = true;

  // Define colors as static constants for better practice
  static const Color _primaryColor = Color(0xFF205295);
  static const Color _accentColor = Color(0xFF2C74B3);
  final Color _cardColor =
      Colors.white.withAlpha(230); // Updated from withOpacity(0.9)

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final size = MediaQuery.of(context).size;
    // Get bottom padding when keyboard is visible
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      // Remove AppBar for a more immersive experience
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // Add this to handle keyboard visibility
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background gradient only (remove the image)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF144272),
                  const Color(0xFF0A2647),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              // Always enable scrolling for better user experience
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Reduce top spacing when keyboard is visible
                    SizedBox(height: bottomPadding > 0 ? 20 : 40),

                    // App logo and name - with conditional visibility
                    if (bottomPadding ==
                        0) // Only show logo when keyboard is hidden
                      Container(
                        height: 100,
                        alignment: Alignment.center,
                        child: staticAppTitle('MARKETSIM'),
                      ),

                    SizedBox(height: bottomPadding > 0 ? 10 : 30),

                    // Login card with elevated design
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(
                                77), // Fixed: replaced withOpacity(0.3)
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome text
                          Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to continue',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Email field
                          buildTextField(
                              _emailController, 'Email', Icons.email),
                          const SizedBox(height: 20),

                          // Password field
                          buildPasswordField(),
                          const SizedBox(height: 15),

                          // Forgot password option
                          Align(
                            alignment: Alignment.centerRight,
                            child: forgotPasswordOption(),
                          ),
                          const SizedBox(height: 25),

                          // Login button
                          logInButton(),
                        ],
                      ),
                    ),

                    SizedBox(height: bottomPadding > 0 ? 20 : 30),

                    // Sign up option
                    signUpOptionWithBackground(),

                    // Add extra padding at bottom for better scrolling
                    SizedBox(height: bottomPadding > 0 ? 36 : 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Creates a static title text instead of animation
  Widget staticAppTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 2.0,
        shadows: [
          Shadow(
            color:
                Colors.black.withAlpha(77), // Fixed: replaced withOpacity(0.3)
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  /// Creates a styled text field with modern appearance
  Widget buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType:
          label == 'Email' ? TextInputType.emailAddress : TextInputType.text,
      style:
          const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      decoration: _getInputDecoration(label, icon),
    );
  }

  /// Creates a password field with visibility toggle
  Widget buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _isPasswordHidden,
      style:
          const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      decoration: _getInputDecoration(
        'Password',
        Icons.lock,
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
            color: _accentColor,
          ),
          onPressed: () =>
              setState(() => _isPasswordHidden = !_isPasswordHidden),
        ),
      ),
    );
  }

  /// Common input decoration for text fields
  InputDecoration _getInputDecoration(String label, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700]),
      prefixIcon: Icon(icon, color: _accentColor),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: Colors.grey.withAlpha(77)), // Updated from withOpacity(0.3)
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _accentColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.withAlpha(26), // Updated from withOpacity(0.1)
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  /// Creates a styled login button with animation
  Widget logInButton() {
    return Center(
      child: SizedBox(
        width: double.infinity, // Make button take full width of container
        child: ElevatedButton(
          onPressed: () async {
            // Get form values
            String email = _emailController.text.trim();
            String password = _passwordController.text.trim();

            try {
              // Attempt to sign in with Firebase
              await FirebaseAuth.instance
                  .signInWithEmailAndPassword(email: email, password: password);

              // Navigate to home on success
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => const HomePage()));
            } catch (error) {
              // Show error message on failure
              if (error is FirebaseAuthException) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Invalid email or password. Please try again.',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.all(10),
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            shadowColor:
                _primaryColor.withAlpha(128), // Updated from withOpacity(0.5)
          ),
          child: const Text(
            'Login',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  /// Creates a sign-up option with background styling
  Widget signUpOptionWithBackground() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38), // Updated from withOpacity(0.15)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Colors.white.withAlpha(51)), // Updated from withOpacity(0.2)
      ),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => const SignUpScreen()));
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 4),
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(fontSize: 16.0, color: Colors.white),
            children: <TextSpan>[
              TextSpan(text: "Don't have an account? "),
              TextSpan(
                text: 'Sign Up',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates a styled "forgot password" option
  Widget forgotPasswordOption() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => const ForgotPasswordScreen(),
          ),
        );
      },
      child: Text(
        "Forgot Password?",
        style: TextStyle(
          color: _accentColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
