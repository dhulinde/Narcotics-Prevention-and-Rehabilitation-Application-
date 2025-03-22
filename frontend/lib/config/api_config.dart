// lib/config/api_config.dart
// Configuration for API endpoints

// Update API endpoints
class ApiConfig {
  // Base URL for the backend API
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // API endpoints with trailing slashes for consistency
  static const String authEndpoint = '$baseUrl/users';
  static const String assessmentEndpoint = '$baseUrl/assessment';
  static const String treatmentPlansEndpoint = '$baseUrl/treatment-plans';
  static const String tasksEndpoint = '$baseUrl/tasks';
  static const String moodEndpoint = '$baseUrl/mood';
  static const String journalEndpoint = '$baseUrl/mood/journal';
  static const String chatEndpoint = '$baseUrl/chat';
  static const String resourcesEndpoint = '$baseUrl/resources';
  static const String openaiEndpoint = '$baseUrl/chat';

  // Auth specific endpoints
  static const String loginEndpoint = '$authEndpoint/login/';
  static const String logoutEndpoint = '$authEndpoint/logout/';
  static const String profileEndpoint = '$authEndpoint/profile/';
  static const String checkUsernameEndpoint = '$authEndpoint/check_username/';
  static const String resetPasswordEndpoint = '$authEndpoint/reset_password/';
  static const String resetPasswordRequestEndpoint = '$authEndpoint/reset_password_request/';
  static const String verifySecurityAnswerEndpoint = '$authEndpoint/verify_security_answer/';
  static const String tokenRefreshEndpoint = '$authEndpoint/token/refresh/';

  // Resources specific endpoints
  static const String resourcesSearchEndpoint = '$resourcesEndpoint/search/';
  static const String resourcesFavoritesEndpoint = '$resourcesEndpoint/favorites/';
  static const String resourcesAllEndpoint = '$resourcesEndpoint/all/';

  // Task specific endpoints
  static const String taskDailyEndpoint = '$tasksEndpoint/daily/';
  static const String taskExerciseEndpoint = '$tasksEndpoint/exercise/';
  static const String taskWellnessEndpoint = '$tasksEndpoint/wellness/';
  static const String taskMedicationEndpoint = '$tasksEndpoint/medication/';
  static const String taskSocialEndpoint = '$tasksEndpoint/social/';
  static const String taskUpdateEndpoint = '$tasksEndpoint/update/';
  // For task completion, use: ${ApiConfig.buildUrl(ApiConfig.tasksEndpoint, '{taskId}/complete')}

  // Assessment specific endpoints
  static const String assessmentQuestionnaireEndpoint = '$assessmentEndpoint/questionnaires/';
  static const String assessmentSubstancesEndpoint = '$assessmentEndpoint/substances/';

  // Mood tracking specific endpoints
  static const String moodHistoryEndpoint = '$moodEndpoint/history/';
  static const String moodSaveEndpoint = '$moodEndpoint/save/';

  // Journal specific endpoints
  static const String journalHistoryEndpoint = '$journalEndpoint/history/';
  static const String journalSaveEndpoint = '$journalEndpoint/save/';

  // Chat specific endpoints
  static const String chatHistoryEndpoint = '$chatEndpoint/history/';
  static const String chatSendEndpoint = '$chatEndpoint/send/';
  static const String chatAnalyzeEndpoint = '$chatEndpoint/analyze/';

  // Treatment plan specific endpoints
  static const String treatmentPlanCurrentEndpoint = '$treatmentPlansEndpoint/current/';
  static const String treatmentPlanSelectEndpoint = '$treatmentPlansEndpoint/select/';
  static const String treatmentPlanStatusEndpoint = '$treatmentPlansEndpoint/status/';

  // Helper method to build endpoint URLs correctly
  static String buildUrl(String endpoint, String path) {
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    if (!endpoint.endsWith('/')) {
      endpoint = '$endpoint/';
    }
    return '$endpoint$path';
  }
}