// core/services/local_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle minimal local storage operations
class LocalStorageService {
  // Global variable for easy access to shared preferences
  static late SharedPreferences prefs;

  // Initialize shared preferences
  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  // Token management for session persistence only
  static Future<void> saveAuthToken(String token) async {
    await prefs.setString('auth_token', token);
  }

  static String? getAuthToken() {
    return prefs.getString('auth_token');
  }

  static Future<void> clearAuthToken() async {
    await prefs.remove('auth_token');
  }

  // Only store login state (not user data)
  static bool isLoggedIn() {
    return prefs.getBool('is_logged_in') ?? false;
  }

  static void setLoggedIn(bool value) {
    prefs.setBool('is_logged_in', value);
  }

  // App onboarding status (first time user)
  static bool hasCompletedOnboarding() {
    return prefs.getBool('has_completed_onboarding') ?? false;
  }

  static void setOnboardingCompleted(bool value) {
    prefs.setBool('has_completed_onboarding', value);
  }

  // Screening completion flag
  static bool hasCompletedScreening() {
    return prefs.getBool('has_completed_screening') ?? false;
  }

  static void setScreeningCompleted(bool value) {
    prefs.setBool('has_completed_screening', value);
  }

  // Clear all stored data
  static Future<bool> clear() async {
    return await prefs.clear();
  }

  static Future<void> saveRefreshToken(String token) async {
    await prefs.setString('refresh_token', token);
  }

  static String? getRefreshToken() {
    return prefs.getString('refresh_token');
  }

  static Future<void> clearRefreshToken() async {
    await prefs.remove('refresh_token');
  }
}