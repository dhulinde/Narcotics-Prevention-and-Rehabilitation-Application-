// config/constants.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF6366F1);         // Indigo
  static const Color primaryLight = Color(0xFFAFB4FF);    // Light indigo
  static const Color primaryDark = Color(0xFF4338CA);     // Dark indigo

  // Secondary colors
  static const Color secondary = Color(0xFFF59E0B);       // Amber
  static const Color secondaryLight = Color(0xFFFCD34D);  // Light amber
  static const Color secondaryDark = Color(0xFFD97706);   // Dark amber

  // Feature-specific accent colors
  static const Color moodAccent = Color(0xFF10B981);      // Emerald green for mood tracker
  static const Color chatAccent = Color(0xFF3B82F6);      // Blue for chatbot
  static const Color assessmentAccent = Color(0xFFEC4899); // Pink for assessment
  static const Color resourcesAccent = Color(0xFF8B5CF6);  // Purple for resources

  // Neutral colors
  static const Color background = Color(0xFFF9FAFB);      // Off-white background
  static const Color cardBackground = Colors.white;       // Pure white for cards
  static const Color lightGrey = Color(0xFFF3F4F6);       // Very light grey
  static const Color mediumGrey = Color(0xFF9CA3AF);      // Medium grey
  static const Color darkGrey = Color(0xFF4B5563);        // Dark grey
  static const Color textPrimary = Color(0xFF1F2937);     // Nearly black for primary text
  static const Color textSecondary = Color(0xFF6B7280);   // Grey for secondary text

  // Feedback colors
  static const Color success = Color(0xFF22C55E);         // Green
  static const Color warning = Color(0xFFF59E0B);         // Amber
  static const Color error = Color(0xFFEF4444);           // Red
  static const Color info = Color(0xFF3B82F6);            // Blue

  // Gradient stops
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1),
    Color(0xFF4F46E5),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFFF59E0B),
    Color(0xFFD97706),
  ];
}

class AppStrings {
  static const String appName = 'NARA';
  static const String appTagline = 'Join the path of self-restoration!';

  // Onboarding screen texts
  static const String onboarding1Title = 'Embark on the journey of self-healing!';
  static const String onboarding2Title = 'Support That Extends Beyond Individuals';
  static const String onboarding3Title = 'Personalized AI Assistance Redefined';

  // Authentication texts
  static const String welcomeText = 'Welcome';
  static const String createAccountText = 'Create an Account';
  static const String securityQuestionText = 'Security Questions';
  static const String resetPasswordText = 'Reset Password';

  // ASSIST questionnaire texts
  static const String assistTitle = 'ASSIST Questionnaire';
  static const String assistWelcome = 'Welcome to the ASSIST Questionnaire';
  static const String assistDescription = 'This questionnaire will help assess your substance use patterns and provide personalized feedback.';

  // Treatment plan texts
  static const String choosePlanText = 'Choose Your Plan';
  static const String selectPlanInstruction = 'Select the plan you think is most suitable for you';

  // Dashboard texts
  static const String welcomeHome = 'Welcome Home';
  static const String sobrietyLabel = 'Sobriety: ';

  // Feature labels
  static const String moodTrackerTitle = 'Mood Tracker';
  static const String recoveryAssistantTitle = 'Recovery Assistant';
  static const String resourcesTitle = 'Resources';
  static const String menuTitle = 'Menu';
}

// class AppAssets {
//   // Image paths
//   static const String logoPath = 'assets/images/logo.png';
//   static const String placeholderImagePath = 'assets/images/placeholder.jpg';
//
//   // Illustration paths
//   static const String onboarding1 = 'assets/images/onboarding1.png';
//   static const String onboarding2 = 'assets/images/onboarding2.png';
//   static const String onboarding3 = 'assets/images/onboarding3.png';
//
//   // Icon paths
//   static const String moodIcon = 'assets/icons/mood.svg';
//   static const String chatIcon = 'assets/icons/chat.svg';
//   static const String resourcesIcon = 'assets/icons/resources.svg';
//   static const String dashboardIcon = 'assets/icons/dashboard.svg';
//   static const String menuIcon = 'assets/icons/menu.svg';
// }

class AppPreferences {
  // SharedPreferences keys
  static const String hasCompletedOnboarding = 'hasCompletedOnboarding';
  static const String isLoggedIn = 'isLoggedIn';
  static const String hasCompletedScreeningEver = 'hasCompletedScreeningEver';
  static const String selectedPlanName = 'selectedPlanName';
  static const String startDate = 'startDate';
  static const String favoriteResources = 'favorite_resources';
}

class AppDimensions {
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircular = 100.0;

  // Font sizes
  static const double fontXS = 12.0;
  static const double fontS = 14.0;
  static const double fontM = 16.0;
  static const double fontL = 18.0;
  static const double fontXL = 20.0;
  static const double fontXXL = 24.0;
  static const double fontXXXL = 32.0;

  // Icon sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;

  // Button heights
  static const double buttonHeight = 56.0;
  static const double buttonHeightSmall = 40.0;

  // Card elevations
  static const double elevationS = 1.0;
  static const double elevationM = 2.0;
  static const double elevationL = 4.0;
  static const double elevationXL = 8.0;
}