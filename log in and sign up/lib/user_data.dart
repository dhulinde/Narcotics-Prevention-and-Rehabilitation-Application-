// This file will store user data temporarily to simulate backend storage
// In a real app, this would be replaced with API calls to your Django backend

class UserData {
  // Singleton pattern to access data across the app
  static final UserData _instance = UserData._internal();

  factory UserData() {
    return _instance;
  }

  UserData._internal();

  // User registration data
  String? username;
  String? email;
  String? password;
  String? securityQuestion;
  String? securityAnswer;

  // Method to store registration data
  void saveRegistrationData({
    required String username,
    required String email,
    required String password,
    required String securityQuestion,
    required String securityAnswer,
  }) {
    this.username = username;
    this.email = email;
    this.password = password;
    this.securityQuestion = securityQuestion;
    this.securityAnswer = securityAnswer;
  }

  // Method to validate security answer
  bool validateSecurityAnswer(String answer) {
    if (securityAnswer == null) return false;
    return securityAnswer!.toLowerCase().trim() == answer.toLowerCase().trim();
  }

  // Method to update password
  void updatePassword(String newPassword) {
    password = newPassword;
  }

  // Method to clear all data (for logout)
  void clearData() {
    username = null;
    email = null;
    password = null;
    securityQuestion = null;
    securityAnswer = null;
  }
}