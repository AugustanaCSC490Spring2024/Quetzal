// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auth_screen/user_profile.dart';
import 'package:email_validator/email_validator.dart';

/// A screen that provides a user registration form.
///
/// This screen allows new users to create an account by providing their
/// personal information and credentials. The screen includes form validation
/// and responsive layout adjustments for different screen sizes and keyboard visibility.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // MARK: - Properties

  /// Firebase authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form field values
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  // UI state
  bool _passwordVisible = false;

  // Theme colors (matching sign-in screen)
  static const Color _primaryColor = Color(0xFF205295);
  static const Color _accentColor = Color(0xFF2C74B3);
  final Color _cardColor = Colors.white.withAlpha(230);

  // MARK: - Main Build Method

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardVisible = bottomPadding > 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Gradient background
          _buildBackground(),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                    // Dynamic spacing based on keyboard visibility
                    SizedBox(height: isKeyboardVisible ? 10 : 20),

                    // Header section
                    _buildHeaderSection(),

                    // Form card
                    _buildSignUpForm(),

                    const SizedBox(height: 20),

                    // Sign in option
                    _buildSignInOption(),

                    // Bottom padding for scrolling
                    SizedBox(height: isKeyboardVisible ? 36 : 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - UI Components

  /// Builds the app bar with transparent background
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Create Account'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  /// Builds the gradient background
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF144272),
            Color(0xFF0A2647),
          ],
        ),
      ),
    );
  }

  /// Builds the header section with title and subtitle
  Widget _buildHeaderSection() {
    return Column(
      children: [
        // Title
        const Text(
          'Join MARKETSIM',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Start your trading journey today',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withAlpha(179),
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  /// Builds the main sign-up form inside a card
  Widget _buildSignUpForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form fields
            _buildTextField(
              label: 'First Name',
              icon: Icons.person_outline,
              onSaved: (value) => _firstName = value ?? '',
              validator: _validateName,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              label: 'Last Name',
              icon: Icons.person,
              onSaved: (value) => _lastName = value ?? '',
              validator: _validateName,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              onSaved: (value) => _email = value ?? '',
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),

            _buildPasswordField(
              label: 'Password',
              onSaved: (value) => _password = value ?? '',
              validator: _validatePassword,
            ),
            const SizedBox(height: 16),

            _buildPasswordField(
              label: 'Confirm Password',
              onSaved: (value) => _confirmPassword = value ?? '',
              validator: _validateConfirmPassword,
            ),
            const SizedBox(height: 25),

            // Sign-up button
            _buildSignUpButton(),
          ],
        ),
      ),
    );
  }

  /// Builds the sign-up button
  Widget _buildSignUpButton() {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            shadowColor: _primaryColor.withAlpha(128),
          ),
          onPressed: _signUp,
          child: const Text(
            'Create Account',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the "Already have an account" option
  Widget _buildSignInOption() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withAlpha(230),
            ),
            children: const [
              TextSpan(text: 'Already have an account? '),
              TextSpan(
                text: 'Sign In',
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

  // MARK: - Form Fields

  /// Creates a standard text input field
  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      decoration: _getInputDecoration(label, icon),
      keyboardType: keyboardType,
      style:
          const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      onSaved: onSaved,
      validator: validator,
    );
  }

  /// Creates a password input field with visibility toggle
  Widget _buildPasswordField({
    required String label,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      decoration: _getInputDecoration(
        label,
        Icons.lock,
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: _accentColor,
          ),
          onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
        ),
      ),
      obscureText: !_passwordVisible,
      style:
          const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      onSaved: onSaved,
      validator: validator,
    );
  }

  /// Provides consistent input decoration for all text fields
  InputDecoration _getInputDecoration(String label, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700]),
      prefixIcon: Icon(icon, color: _accentColor),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withAlpha(77)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _accentColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.withAlpha(26),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  // MARK: - Form Validation

  /// Validates name fields (first name and last name)
  String? _validateName(String? value) {
    return (value?.isEmpty ?? true) ? 'This field is required' : null;
  }

  /// Validates the email address format
  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }
    if (!EmailValidator.validate(value!)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates the password strength
  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Password is required';
    }
    if ((value?.length ?? 0) < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validates that the confirmation password matches
  String? _validateConfirmPassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please confirm your password';
    }
    return null;
  }

  // MARK: - Authentication Logic

  /// Handles the sign-up process including validation, account creation, and user profile setup
  void _signUp() async {
    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Save form values
    _formKey.currentState?.save();

    // Check if passwords match
    if (_password != _confirmPassword) {
      _showErrorSnackBar('Passwords do not match');
      return;
    }

    // Show loading indicator
    _showLoadingDialog();

    try {
      // Create account in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      // Create user profile in Firestore
      User? user = userCredential.user;
      if (user != null) {
        await _createUserProfile(user.uid);

        // Close loading dialog
        Navigator.of(context).pop();

        if (kDebugMode) {
          print('User registered successfully');
        }

        // Show success message and return to sign-in
        _showSuccessMessage();
        Navigator.pop(context);
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      if (kDebugMode) {
        print('Error: $e');
      }

      // Show error message
      _showErrorSnackBar(_getErrorMessage(e));
    }
  }

  /// Creates a user profile in Firestore
  Future<void> _createUserProfile(String userId) async {
    UserModel userModel = UserModel(
      firstName: _firstName,
      lastName: _lastName,
      email: _email,
      profileImageUrl: null,
    );

    await userModel.saveToFirestore(userId);
  }

  // MARK: - Helper Methods

  /// Shows a loading dialog during async operations
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  /// Shows a success message after account creation
  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Account created successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  /// Shows an error message when something goes wrong
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  /// Converts Firebase error codes to user-friendly messages
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email is already registered';
        case 'weak-password':
          return 'Password is too weak';
        case 'invalid-email':
          return 'Email address is invalid';
        default:
          return 'Failed to sign up: ${error.message}';
      }
    }
    return 'Failed to sign up: $error';
  }
}
