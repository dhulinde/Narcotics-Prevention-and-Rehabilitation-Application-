// shared/styles/app_styles.dart
import 'package:flutter/material.dart';
import '../../config/constants.dart';

/// App text styles
class AppTextStyles {
  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: AppDimensions.fontXXXL,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: AppDimensions.fontXXL,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: AppDimensions.fontXL,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Body text
  static const TextStyle body1 = TextStyle(
    fontSize: AppDimensions.fontM,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: AppDimensions.fontS,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // Button text
  static const TextStyle buttonText = TextStyle(
    fontSize: AppDimensions.fontM,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle buttonTextOutlined = TextStyle(
    fontSize: AppDimensions.fontM,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // Caption text
  static const TextStyle caption = TextStyle(
    fontSize: AppDimensions.fontXS,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // Title text with primary color
  static const TextStyle titlePrimary = TextStyle(
    fontSize: AppDimensions.fontXL,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: -0.5,
  );

  // Subtitle
  static const TextStyle subtitle = TextStyle(
    fontSize: AppDimensions.fontL,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Error text
  static const TextStyle errorText = TextStyle(
    fontSize: AppDimensions.fontXS,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
    height: 1.3,
  );

  // Feature-specific title styles
  static const TextStyle moodTrackerTitle = TextStyle(
    fontSize: AppDimensions.fontXL,
    fontWeight: FontWeight.w600,
    color: AppColors.moodAccent,
    letterSpacing: -0.5,
  );

  static const TextStyle chatTitle = TextStyle(
    fontSize: AppDimensions.fontXL,
    fontWeight: FontWeight.w600,
    color: AppColors.chatAccent,
    letterSpacing: -0.5,
  );

  static const TextStyle assessmentTitle = TextStyle(
    fontSize: AppDimensions.fontXL,
    fontWeight: FontWeight.w600,
    color: AppColors.assessmentAccent,
    letterSpacing: -0.5,
  );

  static const TextStyle resourcesTitle = TextStyle(
    fontSize: AppDimensions.fontXL,
    fontWeight: FontWeight.w600,
    color: AppColors.resourcesAccent,
    letterSpacing: -0.5,
  );
}

/// App decoration styles
class AppDecorations {
  // Card decoration
  static BoxDecoration card = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        spreadRadius: 0,
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );

  // Container decoration with subtle background
  static BoxDecoration container = BoxDecoration(
    color: AppColors.lightGrey,
    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
  );

  // Outlined container decoration
  static BoxDecoration outlined = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
    border: Border.all(
      color: AppColors.lightGrey,
      width: 1.5,
    ),
  );

  // Primary color container
  static BoxDecoration primaryContainer = BoxDecoration(
    color: AppColors.primary.withOpacity(0.1),
    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
  );

  // Success color container
  static BoxDecoration successContainer = BoxDecoration(
    color: AppColors.success.withOpacity(0.1),
    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
  );

  // Warning color container
  static BoxDecoration warningContainer = BoxDecoration(
    color: AppColors.warning.withOpacity(0.1),
    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
  );

  // Error color container
  static BoxDecoration errorContainer = BoxDecoration(
    color: AppColors.error.withOpacity(0.1),
    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
  );

  // Feature-specific decorations
  static BoxDecoration moodContainer = BoxDecoration(
    color: AppColors.moodAccent.withOpacity(0.1),
    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
  );

  static BoxDecoration chatContainer = BoxDecoration(
    color: AppColors.chatAccent.withOpacity(0.1),
    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
  );

  static BoxDecoration assessmentContainer = BoxDecoration(
    color: AppColors.assessmentAccent.withOpacity(0.1),
    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
  );

  static BoxDecoration resourcesContainer = BoxDecoration(
    color: AppColors.resourcesAccent.withOpacity(0.1),
    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
  );

  // Gradient background
  static BoxDecoration gradientBackground = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: AppColors.primaryGradient,
    ),
  );

  // Gradient button
  static BoxDecoration gradientButton = BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: AppColors.primaryGradient,
    ),
    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.3),
        spreadRadius: 0,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

/// App padding values
class AppPadding {
  static const double small = AppDimensions.paddingS;
  static const double medium = AppDimensions.paddingM;
  static const double large = AppDimensions.paddingL;
  static const double extraLarge = AppDimensions.paddingXL;

  // Paddings as EdgeInsets
  static const EdgeInsets smallAll = EdgeInsets.all(small);
  static const EdgeInsets mediumAll = EdgeInsets.all(medium);
  static const EdgeInsets largeAll = EdgeInsets.all(large);
  static const EdgeInsets extraLargeAll = EdgeInsets.all(extraLarge);

  // Horizontal paddings
  static const EdgeInsets smallHorizontal = EdgeInsets.symmetric(horizontal: small);
  static const EdgeInsets mediumHorizontal = EdgeInsets.symmetric(horizontal: medium);
  static const EdgeInsets largeHorizontal = EdgeInsets.symmetric(horizontal: large);

  // Vertical paddings
  static const EdgeInsets smallVertical = EdgeInsets.symmetric(vertical: small);
  static const EdgeInsets mediumVertical = EdgeInsets.symmetric(vertical: medium);
  static const EdgeInsets largeVertical = EdgeInsets.symmetric(vertical: large);

  // Combined paddings
  static const EdgeInsets screenDefault = EdgeInsets.symmetric(
    horizontal: AppDimensions.paddingL,
    vertical: AppDimensions.paddingM,
  );
}

/// App border radius values
class AppBorderRadius {
  static final BorderRadius small = BorderRadius.circular(AppDimensions.radiusS);
  static final BorderRadius medium = BorderRadius.circular(AppDimensions.radiusM);
  static final BorderRadius large = BorderRadius.circular(AppDimensions.radiusL);
  static final BorderRadius extraLarge = BorderRadius.circular(AppDimensions.radiusXL);
  static final BorderRadius circular = BorderRadius.circular(AppDimensions.radiusCircular);
}