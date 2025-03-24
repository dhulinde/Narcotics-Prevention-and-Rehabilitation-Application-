// core/utils/validators.dart

/// Utility class for form validation
class Validators {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Simple email validation regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate username
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }

    // Check for valid characters (letters, numbers, underscore)
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Validate that passwords match
  static String? validatePasswordsMatch(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate security question
  static String? validateSecurityQuestion(String? question) {
    if (question == null || question.isEmpty || question == 'Select a question') {
      return 'Please select a security question';
    }

    return null;
  }

  /// Validate security answer
  static String? validateSecurityAnswer(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please provide an answer to your security question';
    }

    return null;
  }

  /// Validate custom security question
  static String? validateCustomSecurityQuestion(String? value, bool isCustomQuestion) {
    if (isCustomQuestion && (value == null || value.isEmpty)) {
      return 'Please enter a custom security question';
    }

    return null;
  }

  /// Validate non-empty field
  static String? validateRequired(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone can be optional
    }

    // Remove any non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    // Check length (most countries have between 8 and 15 digits)
    if (digitsOnly.length < 8 || digitsOnly.length > 15) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate numeric value
  static String? validateNumeric(String? value, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return null; // Can be optional
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return '$fieldName must contain only numbers';
    }

    return null;
  }

  /// Validate date format (MM/DD/YYYY)
  static String? validateDateFormat(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Can be optional
    }

    // Check format with regex
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
      return 'Please use MM/DD/YYYY format';
    }

    try {
      // Split string and convert to date
      final parts = value.split('/');
      final month = int.parse(parts[0]);
      final day = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      // Basic range checking
      if (month < 1 || month > 12) {
        return 'Month must be between 1 and 12';
      }

      if (day < 1 || day > 31) {
        return 'Day must be between 1 and 31';
      }

      if (year < 1900 || year > 2100) {
        return 'Year must be between 1900 and 2100';
      }

      // Create date to validate day for month (e.g., Feb 30 is invalid)
      final date = DateTime(year, month, day);
      if (date.month != month) {
        return 'Invalid day for this month';
      }
    } catch (e) {
      return 'Invalid date format';
    }

    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty if field is optional
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty if field is optional
    }

    if (value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }

    return null;
  }
}