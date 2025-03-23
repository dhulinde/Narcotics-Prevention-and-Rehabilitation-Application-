// features/assessment/services/assist_questionnaire_service.dart
import 'package:flutter/material.dart';
import '../../../config/constants.dart';

class AssistQuestionnaireService {
  // Get visual elements based on risk level
  static Map<String, dynamic> getRiskLevelVisuals(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return {
          'color': AppColors.error,
          'background': AppColors.error.withOpacity(0.1),
          'icon': Icons.warning_rounded,
        };
      case 'moderate':
        return {
          'color': AppColors.warning,
          'background': AppColors.warning.withOpacity(0.1),
          'icon': Icons.info_outline,
        };
      case 'low':
        return {
          'color': AppColors.success,
          'background': AppColors.success.withOpacity(0.1),
          'icon': Icons.check_circle_outline,
        };
      case 'none':
      default:
        return {
          'color': AppColors.assessmentAccent,
          'background': AppColors.assessmentAccent.withOpacity(0.1),
          'icon': Icons.check_circle_outline,
        };
    }
  }

  // Get risk level text description
  static String getRiskText(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return 'High Risk Level';
      case 'moderate':
        return 'Moderate Risk Level';
      case 'low':
        return 'Low Risk Level';
      case 'none':
      default:
        return 'Very Low Risk Level';
    }
  }

  // Get primary advice text based on risk level
  static String getAdviceText1(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return 'Your responses indicate a high risk of developing health and other problems from your current pattern of substance use. You may be experiencing these problems right now.';
      case 'moderate':
        return 'Your responses indicate a moderate risk of health and other problems from your current pattern of substance use. Reducing or stopping your substance use can help prevent future problems.';
      case 'low':
        return 'Your responses indicate a low risk of health and other problems from your current pattern of substance use, though some risk may still exist if use continues or increases.';
      case 'none':
      default:
        return 'Your responses indicate a very low risk of health and other problems from your current pattern of substance use. Keep up the good work!';
    }
  }

  // Get secondary advice text based on risk level
  static String getAdviceText2(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return 'People who continue to use at high-risk levels are likely to develop dependence and may experience withdrawal symptoms when trying to stop or cut down.';
      case 'moderate':
        return 'Regular use of substances in this way can lead to health, social, legal, and financial problems, and may lead to dependence if continued.';
      case 'low':
        return 'Even low levels of substance use can sometimes cause problems if used in certain situations like driving, during pregnancy, or with certain medical conditions.';
      case 'none':
      default:
        return 'Maintaining abstinence or very low levels of substance use is an excellent way to avoid developing problems in the future.';
    }
  }

  // Get recommendation text based on risk level
  static String getRecommendation(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return 'We recommend selecting an intensive treatment plan to address your substance use and prevent or reduce harm. Professional support can make a significant difference.';
      case 'moderate':
        return 'We recommend selecting a moderate support plan to help you reduce your substance use and prevent problems from developing or worsening.';
      case 'low':
        return 'We recommend selecting a prevention-focused plan to maintain your current low risk and provide strategies if you ever need additional support.';
      case 'none':
      default:
        return 'We recommend selecting a wellness plan to maintain your healthy choices and provide information about substance use prevention.';
    }
  }
}