String? getPasswordStrengthError(String password) {

  if (password.length < 8) {
    return 'Password must be at least 8 characters long.';
  }

  if (!password.contains(RegExp(r'[A-Z]'))) {
    return 'Password must contain an uppercase letter.';
  }

  if (!password.contains(RegExp(r'[a-z]'))) {
    return 'Password must contain a lowercase letter.';
  }

  if (!password.contains(RegExp(r'[0-9]'))) {
    return 'Password must contain a number.';
  }

  if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    return 'Password must contain a special character (!@#^&*(),.?":{}|<>).';
  }

  return null; // No error

}
