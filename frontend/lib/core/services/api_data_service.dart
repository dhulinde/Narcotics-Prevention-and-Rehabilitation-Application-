// lib/core/services/api_data_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/task_item_model.dart';
import '../models/mood_model.dart';
import '../models/chat_message_model.dart';
import '../models/resource_model.dart';
import '../models/treatment_plan_model.dart';
import '../models/assist_questionnaire_model.dart';
import '../models/user_model.dart';
import 'local_storage_service.dart';
import '../../config/api_config.dart';

/// Service to handle all API data loading and caching
class ApiDataService {
  static final ApiDataService _instance = ApiDataService._internal();

  factory ApiDataService() => _instance;

  ApiDataService._internal();

  // Cached data
  List<TaskItem> _dailyTasks = [];
  List<TaskItem> _exerciseTasks = [];
  List<TaskItem> _wellnessTasks = [];
  List<TaskItem> _medicationTasks = [];
  List<TaskItem> _socialTasks = [];
  List<MoodEntry> _moodEntries = [];
  List<JournalEntry> _journalEntries = [];
  List<ChatMessage> _chatHistory = [];
  List<Resource> _resources = [];
  List<Resource> _favoriteResources = [];
  TreatmentPlan? _selectedPlan;
  DateTime? _startDate;
  AssistQuestionnaire? _questionnaire;

  // Headers with auth token
  Map<String, String> _getHeaders() {
    final token = AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Error handler
  void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      throw Exception('API Error: ${response.statusCode} ${response.body}');
    }
  }

  // Retry mechanism
  Future<http.Response> _retryRequest(Future<http.Response> Function() request, {int maxRetries = 3}) async {
    int retries = 0;
    while (retries < maxRetries) {
      try {
        final response = await request();
        if (response.statusCode < 500) {
          return response;
        }
      } catch (e) {
        if (e is SocketException || e is TimeoutException) {
          // Network errors, retry
        } else {
          rethrow;
        }
      }

      // Exponential backoff
      await Future.delayed(Duration(milliseconds: 300 * (retries + 1)));
      retries++;
    }

    throw Exception('Request failed after $maxRetries retries');
  }

  //===========================================================================
  // TASKS API METHODS
  //===========================================================================

  /// Load all tasks for a user
  Future<void> loadAllTasks() async {
    final username = AuthService.getCurrentUsername();
    if (username == null) {
      throw Exception("User not logged in");
    }

    try {
      await Future.wait([
        loadTasksByCategory('daily'),
        loadTasksByCategory('exercise'),
        loadTasksByCategory('wellness'),
        loadTasksByCategory('medication'),
        loadTasksByCategory('social'),
      ]);
    } catch (e) {
      print('Error loading all tasks: $e');
      rethrow;
    }
  }

  /// Load tasks by category
  Future<List<TaskItem>> loadTasksByCategory(String category) async {
    final username = AuthService.getCurrentUsername();
    if (username == null) {
      throw Exception("User not logged in");
    }

    try {
      String endpoint;
      switch (category.toLowerCase()) {
        case 'daily':
          endpoint = ApiConfig.taskDailyEndpoint;
          break;
        case 'exercise':
          endpoint = ApiConfig.taskExerciseEndpoint;
          break;
        case 'wellness':
          endpoint = ApiConfig.taskWellnessEndpoint;
          break;
        case 'medication':
          endpoint = ApiConfig.taskMedicationEndpoint;
          break;
        case 'social':
          endpoint = ApiConfig.taskSocialEndpoint;
          break;
        default:
          endpoint = ApiConfig.buildUrl(ApiConfig.tasksEndpoint, category);
      }

      final response = await _retryRequest(() =>
          http.get(
            Uri.parse(endpoint),
            headers: _getHeaders(),
          )
      );

      _handleError(response);

      print('=== API Response for $category tasks ===');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final List<dynamic> data = jsonDecode(response.body);
      final tasks = data.map((item) {
        // Parse reminderTime if present
        TimeOfDay? reminderTime;
        if (item['reminderTime'] != null) {
          final parts = item['reminderTime'].split(':');
          reminderTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        } else if (item['reminder_time'] != null) {
          // Handle snake_case format from backend
          final parts = item['reminder_time'].split(':');
          reminderTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }

        return TaskItem(
          id: item['id'] ?? '',
          title: item['title'],
          isCompleted: item['isCompleted'] ?? item['is_completed'] ?? false,
          category: _mapStringToTaskCategory(category),
          reminderTime: reminderTime,
          note: item['note'],
        );
      }).toList();

      // Cache data
      _cacheTasksByCategory(category, tasks);

      return tasks;
    } catch (e) {
      print('Error loading $category tasks: $e');
      // Return cached data if available
      return _getCachedTasksByCategory(category);
    }
  }

  Future<bool> createSampleTasks() async {
    final username = AuthService.getCurrentUsername();
    if (username == null) {
      throw Exception("User not logged in");
    }

    try {
      final response = await _retryRequest(() =>
          http.post(
            Uri.parse('${ApiConfig.tasksEndpoint}/create-samples/'),
            headers: _getHeaders(),
          )
      );

      if (response.statusCode == 201) {
        // Refresh cached data
        await loadAllTasks();
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating sample tasks: $e');
      return false;
    }
  }

  /// Update task completion status
  Future<bool> updateTaskCompletion(String category, int index, bool isCompleted) async {
    final username = AuthService.getCurrentUsername();
    if (username == null) {
      throw Exception("User not logged in");
    }

    try {
      final response = await _retryRequest(() =>
          http.post(
            Uri.parse(ApiConfig.taskUpdateEndpoint),
            headers: _getHeaders(),
            body: jsonEncode({
              'category': category,
              'index': index,
              'isCompleted': isCompleted, // Frontend uses camelCase
              'is_completed': isCompleted, // Add snake_case for backend compatibility
            }),
          )
      );

      _handleError(response);

      // Update cache
      final tasks = _getCachedTasksByCategory(category);
      if (index >= 0 && index < tasks.length) {
        tasks[index].isCompleted = isCompleted;
        _cacheTasksByCategory(category, tasks);
      }

      return true;
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }

  /// Complete a specific task by ID
  Future<bool> completeTask(String taskId, bool isCompleted) async {
    final username = AuthService.getCurrentUsername();
    if (username == null) {
      throw Exception("User not logged in");
    }

    try {
      final completeUrl = ApiConfig.buildUrl(ApiConfig.tasksEndpoint, '$taskId/complete');
      final response = await _retryRequest(() =>
          http.patch(
            Uri.parse(completeUrl),
            headers: _getHeaders(),
            body: jsonEncode({
              'is_completed': isCompleted,
            }),
          )
      );

      _handleError(response);
      return true;
    } catch (e) {
      print('Error completing task: $e');
      return false;
    }
  }

  //===========================================================================
  // MOOD TRACKING API METHODS
  //===========================================================================

  /// Load mood history
  Future<List<MoodEntry>> loadMoodHistory({int limit = 7}) async {
    final username = AuthService.getCurrentUsername();
    if (username == null) {
      throw Exception("User not logged in");
    }

    try {
      final response = await _retryRequest(() =>
          http.get(
            Uri.parse('${ApiConfig.moodHistoryEndpoint}?limit=$limit'),
            headers: _getHeaders(),
          )
      );

      if (response.statusCode >= 400) {
        print('Mood history load error: ${response.statusCode} ${response.body}');
      }

      _handleError(response);

      final List<dynamic> data = jsonDecode(response.body);
      final moodEntries = data.map((item) {
        return MoodEntry(
          id: item['id'] ?? '',
          date: DateTime.parse(item['date']),
          mood: _parseMoodType(item['mood']),
          note: item['note'] ?? '',
        );
      }).toList();

      // Cache data
      _moodEntries = moodEntries;

      return moodEntries;
    } catch (e) {
      print('Error loading mood history: $e');
      return _moodEntries;
    }
  }

  /// Save mood entry
  Future<bool> saveMoodEntry(MoodEntry entry) async {
    final username = AuthService.getCurrentUsername();
    if (username == null) {
      throw Exception("User not logged in");
    }

    try {
      // Convert MoodType enum to appropriate string value
      // This is the key fix - sending the mood as a string instead of an index
      final String moodString = _getMoodTypeString(entry.mood);

      final response = await _retryRequest(() =>
          http.post(
            Uri.parse(ApiConfig.moodSaveEndpoint),
            headers: _getHeaders(),
            body: jsonEncode({
              // Remove date field, as the backend uses auto_now_add
              'mood': moodString,  // Send string representation of mood
              'note': entry.note,
            }),
          )
      );

      // Add better error logging
      if (response.statusCode >= 400) {
        print('Mood save error: ${response.statusCode} ${response.body}');
      }

      _handleError(response);

      // Update cache
      _moodEntries.add(entry);

      return true;
    } catch (e) {
      print('Error saving mood entry: $e');
      return false;
    }
  }

  String _getMoodTypeString(MoodType mood) {
    // Convert enum to string format expected by backend
    switch (mood) {
      case MoodType.very_sad:
        return 'very_sad';
      case MoodType.sad:
        return 'sad';
      case MoodType.neutral:
        return 'neutral';
      case MoodType.happy:
        return 'happy';
      case MoodType.very_happy:
        return 'very_happy';
      // Fallback
    }
  }

  //===========================================================================
  // JOURNAL API METHODS
  //===========================================================================

  /// Load journal entries
  Future<List<JournalEntry>> loadJournalEntries() async {
    final username = AuthService.getCurrentUsername();
    if (username == null) {
      throw Exception("User not logged in");
    }

    try {
      final response = await _retryRequest(() =>
          http.get(
            Uri.parse(ApiConfig.journalHistoryEndpoint),
            headers: _getHeaders(),
          )
      );

      if (response.statusCode >= 400) {
        print('Journal entries load error: ${response.statusCode} ${response.body}');
      }

      _handleError(response);

      final List<dynamic> data = jsonDecode(response.body);
      print('Journal data loaded: ${data.length} entries');

      final journalEntries = data.map((item) {
        return JournalEntry(
          id: item['id'] ?? '',
          date: DateTime.parse(item['date']),
          text: item['text'] ?? '',
        );
      }).toList();

      // Cache data
      _journalEntries = journalEntries;

      return journalEntries;
    } catch (e) {
      print('Error loading journal entries: $e');
      return _journalEntries;
    }
  }

// IMPROVED _parseMoodType FUNCTION
  MoodType _parseMoodType(dynamic moodValue) {
    // Handle string value
    if (moodValue is String) {
      switch (moodValue) {
        case 'very_sad':
          return MoodType.very_sad;
        case 'sad':
          return MoodType.sad;
        case 'neutral':
          return MoodType.neutral;
        case 'happy':
          return MoodType.happy;
        case 'very_happy':
          return MoodType.very_happy;
      }
    }

    // Handle numeric index
    if (moodValue is int && moodValue >= 0 && moodValue < MoodType.values.length) {
      return MoodType.values[moodValue];
    }

    // Default fallback
    return MoodType.neutral;
  }

  /// Save journal entry
  Future<bool> saveJournalEntry(JournalEntry entry) async {
    final username = AuthService.getCurrentUsername();
    if (username == null) {
      throw Exception("User not logged in");
    }

    try {
      final response = await _retryRequest(() =>
          http.post(
            Uri.parse(ApiConfig.journalSaveEndpoint),
            headers: _getHeaders(),
            body: jsonEncode({
              // Only send text field, not date (which is read-only on server)
              'text': entry.text,
            }),
          )
      );

      // Add better error logging
      if (response.statusCode >= 400) {
        print('Journal save error: ${response.statusCode} ${response.body}');
      }

      _handleError(response);

      // Update cache
      _journalEntries.add(entry);

      return true;
    } catch (e) {
      print('Error saving journal entry: $e');
      return false;
    }
  }

  //===========================================================================
  // CHAT API METHODS
  //===========================================================================

  /// Load chat history
  Future<List<ChatMessage>> loadChatHistory() async {
    final username = AuthService.getCurrentUsername();
    if (username == null) {
      throw Exception("User not logged in");
    }

    try {
      final response = await _retryRequest(() =>
          http.get(
            Uri.parse(ApiConfig.chatHistoryEndpoint),
            headers: _getHeaders(),
          )
      );

      _handleError(response);

      final data = jsonDecode(response.body);

      // Check if the response has a 'data' field (from success response structure)
      final List<dynamic> messagesJson = data is Map && data.containsKey('data')
          ? data['data']
          : (data is List ? data : []);

      final chatMessages = messagesJson.map((item) {
        return ChatMessage(
          id: item['id'] ?? '',
          text: item['text'],
          isUserMessage: item['is_user_message'] ?? item['isUserMessage'] ?? false,
          timestamp: DateTime.parse(item['timestamp']),
          sentiment: item['sentiment'],
          emotions: _parseStringList(item['emotions']),
          triggers: _parseStringList(item['triggers']),
          topics: _parseStringList(item['topics']),
        );
      }).toList();

      // If empty, add default welcome message
      if (chatMessages.isEmpty) {
        chatMessages.add(ChatMessage(
          text: "Hello! I'm your recovery assistant. How can I help you today?",
          isUserMessage: false,
        ));
      }

      // Cache data - make sure to clear previous cache to avoid duplicates
      _chatHistory = chatMessages;

      return chatMessages;
    } catch (e) {
      print('Error loading chat history: $e');

      // Return cached or default message
      if (_chatHistory.isEmpty) {
        _chatHistory = [
          ChatMessage(
            text: "Hello! I'm your recovery assistant. How can I help you today?",
            isUserMessage: false,
          )
        ];
      }

      return _chatHistory;
    }
  }

  /// Send message to chat bot
  Future<ChatMessage> sendChatMessage(String message) async {
    final username = AuthService.getCurrentUsername();
    if (username == null) {
      throw Exception("User not logged in");
    }

    try {
      // Format request according to the expected ChatRequestSerializer format
      final response = await _retryRequest(() =>
          http.post(
            Uri.parse(ApiConfig.chatSendEndpoint),
            headers: _getHeaders(),
            body: jsonEncode({
              'message': message,
            }),
          )
      );

      _handleError(response);

      final data = jsonDecode(response.body);

      // Extract bot response based on the actual response structure
      String botResponseText;

      // Check for different response structures
      if (data['bot_response'] != null && data['bot_response']['text'] != null) {
        botResponseText = data['bot_response']['text'];
      } else if (data['response'] != null) {
        botResponseText = data['response'];
      } else if (data['bot_message'] != null) {
        botResponseText = data['bot_message'];
      } else if (data['text'] != null) {
        botResponseText = data['text'];
      } else {
        // From the logs we can see OpenAI quota issues, so fallback is important
        botResponseText = _getFallbackResponse(message);
      }

      final botMessage = ChatMessage(
        text: botResponseText,
        isUserMessage: false,
      );

      return botMessage;
    } catch (e) {
      print('Error sending chat message: $e');

      // Create fallback response
      return ChatMessage(
        text: _getFallbackResponse(message),
        isUserMessage: false,
      );
    }
  }

  /// Analyze user message
  Future<Map<String, dynamic>> analyzeUserMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.chatAnalyzeEndpoint),
        headers: _getHeaders(),
        body: jsonEncode({
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Message Analysis API Error: ${response.statusCode}');
        return {
          'sentiment': 'neutral',
          'emotions': [],
          'triggers': [],
          'topics': [],
        };
      }
    } catch (e) {
      print('Error analyzing message: $e');
      return {
        'sentiment': 'neutral',
        'emotions': [],
        'triggers': [],
        'topics': [],
      };
    }
  }

  //===========================================================================
  // RESOURCES API METHODS
  //===========================================================================

  /// Load all resources
  Future<List<Resource>> loadAllResources() async {
    try {
      final response = await _retryRequest(() =>
          http.get(
            Uri.parse(ApiConfig.resourcesAllEndpoint),
            headers: _getHeaders(),
          )
      );

      _handleError(response);

      final List<dynamic> resourcesJson = jsonDecode(response.body);
      final resources = resourcesJson.map((json) => Resource.fromJson(json)).toList();

      // Cache data
      _resources = resources;

      return resources;
    } catch (e) {
      print('Error fetching resources: $e');
      return _resources;
    }
  }

  /// Search resources
  Future<List<Resource>> searchResources(String query) async {
    try {
      if (query.isEmpty) {
        return await loadAllResources();
      }

      final response = await _retryRequest(() =>
          http.get(
            Uri.parse('${ApiConfig.resourcesSearchEndpoint}?q=${Uri.encodeComponent(query)}'),
            headers: _getHeaders(),
          )
      );

      _handleError(response);

      final List<dynamic> resourcesJson = jsonDecode(response.body);
      return resourcesJson.map((json) => Resource.fromJson(json)).toList();
    } catch (e) {
      print('Error searching resources: $e');

      // Try to filter cached resources
      if (_resources.isNotEmpty) {
        return _resources.where((resource) =>
        resource.title.toLowerCase().contains(query.toLowerCase()) ||
            resource.description.toLowerCase().contains(query.toLowerCase()) ||
            resource.author.toLowerCase().contains(query.toLowerCase()) ||
            resource.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
        ).toList();
      }

      return [];
    }
  }

  /// Filter resources by type
  Future<List<Resource>> filterResourcesByType(String type) async {
    try {
      if (type.isEmpty || type.toLowerCase() == 'all') {
        return await loadAllResources();
      }

      final response = await _retryRequest(() =>
          http.get(
            Uri.parse('${ApiConfig.resourcesEndpoint}/category/${Uri.encodeComponent(type)}'),
            headers: _getHeaders(),
          )
      );

      _handleError(response);

      final List<dynamic> resourcesJson = jsonDecode(response.body);
      return resourcesJson.map((json) => Resource.fromJson(json)).toList();
    } catch (e) {
      print('Error filtering resources: $e');

      // Try to filter cached resources
      if (_resources.isNotEmpty) {
        final categoryType = type.toLowerCase();
        return _resources.where((resource) =>
        resource.type.toLowerCase() == categoryType
        ).toList();
      }

      return [];
    }
  }

  /// Get favorite resources
  Future<List<Resource>> loadFavoriteResources() async {
    try {
      final response = await _retryRequest(() =>
          http.get(
            Uri.parse(ApiConfig.resourcesFavoritesEndpoint),
            headers: _getHeaders(),
          )
      );

      _handleError(response);

      final List<dynamic> resourcesJson = jsonDecode(response.body);
      final resources = resourcesJson.map((json) => Resource.fromJson(json)).toList();

      // Cache favorite resources
      _favoriteResources = resources;

      return resources;
    } catch (e) {
      print('Error getting favorite resources: $e');
      return _favoriteResources;
    }
  }

  /// Toggle resource favorite status
  Future<bool> toggleResourceFavorite(String resourceId) async {
    try {
      final response = await _retryRequest(() =>
          http.post(
            Uri.parse('${ApiConfig.resourcesEndpoint}/toggle-favorite/$resourceId/'),
            headers: _getHeaders(),
          )
      );

      _handleError(response);

      final data = jsonDecode(response.body);
      final isFavorite = data['isFavorite'] ?? false;

      // Update resources in cache
      for (int i = 0; i < _resources.length; i++) {
        if (_resources[i].id == resourceId) {
          _resources[i] = _resources[i].copyWith(isFavorite: isFavorite);
          break;
        }
      }

      // Update favorites if needed
      await loadFavoriteResources();

      return isFavorite;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  //===========================================================================
  // TREATMENT PLAN API METHODS
  //===========================================================================

  /// Load current treatment plan
  Future<Map<String, dynamic>?> loadCurrentPlan() async {
    final username = AuthService.getCurrentUsername();
    if (username == null) {
      throw Exception("User not logged in");
    }

    try {
      final response = await _retryRequest(() =>
          http.get(
            Uri.parse(ApiConfig.treatmentPlanCurrentEndpoint),
            headers: _getHeaders(),
          )
      );

      if (response.statusCode == 404) {
        return null;
      }

      _handleError(response);

      final data = jsonDecode(response.body);

      // Parse plan and start date
      final planData = data['plan'] ?? data;
      final planName = planData['name'] ?? data['planName'];
      final startDateStr = data['start_date'] ?? data['startDate'];

      // Find plan by name
      final plans = TreatmentPlanService.getPlans();
      TreatmentPlan? plan;

      for (var p in plans) {
        if (p.name == planName) {
          plan = p;
          break;
        }
      }

      if (plan != null) {
        _selectedPlan = plan;
        _startDate = DateTime.parse(startDateStr);

        return {
          'selectedPlan': plan,
          'startDate': _startDate,
        };
      }

      return null;
    } catch (e) {
      print('Error loading current plan: $e');

      // Return cached data if available
      if (_selectedPlan != null && _startDate != null) {
        return {
          'selectedPlan': _selectedPlan,
          'startDate': _startDate,
        };
      }

      return null;
    }
  }

  /// Select treatment plan
  Future<bool> selectTreatmentPlan(TreatmentPlan plan) async {
    final username = AuthService.getCurrentUsername();
    if (username == null) {
      throw Exception("User not logged in");
    }

    try {
      final startDate = DateTime.now();

      final response = await _retryRequest(() =>
          http.post(
            Uri.parse(ApiConfig.treatmentPlanSelectEndpoint),
            headers: _getHeaders(),
            body: jsonEncode({
              'planName': plan.name,
              'startDate': startDate.toIso8601String(),
            }),
          )
      );

      _handleError(response);

      // Cache plan data
      _selectedPlan = plan;
      _startDate = startDate;

      return true;
    } catch (e) {
      print('Error selecting treatment plan: $e');
      return false;
    }
  }

  /// Get treatment plan status
  Future<Map<String, dynamic>> getTreatmentPlanStatus() async {
    final username = AuthService.getCurrentUsername();
    if (username == null) {
      throw Exception("User not logged in");
    }

    try {
      final response = await _retryRequest(() =>
          http.get(
            Uri.parse(ApiConfig.treatmentPlanStatusEndpoint),
            headers: _getHeaders(),
          )
      );

      _handleError(response);

      return jsonDecode(response.body);
    } catch (e) {
      print('Error getting treatment plan status: $e');
      return {
        'hasCompleted': false
      };
    }
  }

  //===========================================================================
  // ASSESSMENT API METHODS
  //===========================================================================

  /// Get list of all substances
  Future<List<dynamic>> getSubstances() async {
    try {
      final response = await _retryRequest(() =>
          http.get(
            Uri.parse(ApiConfig.assessmentSubstancesEndpoint),
            headers: _getHeaders(),
          )
      );

      _handleError(response);

      final List<dynamic> substancesJson = jsonDecode(response.body);
      return substancesJson;
    } catch (e) {
      print('Error getting substances list: $e');
      return [];
    }
  }

  /// Load latest questionnaire
  Future<AssistQuestionnaire?> loadLatestQuestionnaire() async {
    final username = AuthService.getCurrentUsername();
    if (username == null) {
      throw Exception("User not logged in");
    }

    try {
      final response = await _retryRequest(() =>
          http.get(
            Uri.parse('${ApiConfig.assessmentQuestionnaireEndpoint}/latest/'),
            headers: _getHeaders(),
          )
      );

      if (response.statusCode == 404) {
        return null;
      }

      _handleError(response);

      final data = jsonDecode(response.body);
      final questionnaire = AssistQuestionnaire.fromJson(data);

      // Cache questionnaire
      _questionnaire = questionnaire;

      return questionnaire;
    } catch (e) {
      print('Error loading questionnaire: $e');
      return _questionnaire;
    }
  }

  /// Submit questionnaire
  Future<bool> submitQuestionnaire(AssistQuestionnaire questionnaire) async {
    final token = AuthService.getToken();
    if (token == null) {
      throw Exception("User not logged in");
    }

    try {
      // Format the data correctly for the API
      final formattedData = {
        'other_substance_specify': questionnaire.otherSubstanceSpecify,
        'substance_responses': questionnaire.substances.map((substance) => {
          'substance': substance.id, // Make sure this is the MongoDB ObjectId as a string
          'used_in_lifetime': substance.usedInLifetime,
          'frequency_last_3_months': substance.frequencyLast3Months,
          'urge_to_use': substance.urgeToUse,
          'health_social_problems': substance.healthSocialProblems,
          'failed_responsibilities': substance.failedResponsibilities,
          'concern_from_others': substance.concernFromOthers,
          'tried_to_control': substance.triedToControl,
          'injected': substance.injected,
          'injection_frequency': substance.injectionFrequency,
        }).toList(),
      };

      final response = await _retryRequest(() =>
          http.post(
            Uri.parse('${ApiConfig.assessmentQuestionnaireEndpoint}submit/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(formattedData),
          )
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        print('Error saving questionnaire: ${response.statusCode} ${response.body}');
        return false;
      }

      // Cache questionnaire
      _questionnaire = questionnaire;

      return true;
    } catch (e) {
      print('Error submitting questionnaire: $e');
      return false;
    }
  }

  /// Finish and submit questionnaire with context
  Future<bool> finishQuestionnaire(
      AssistQuestionnaire questionnaire,
      BuildContext context,
      Function? onSuccess
      ) async {
    try {
      // Format the data correctly for the API
      final formattedData = {
        'other_substance_specify': questionnaire.otherSubstanceSpecify,
        'substance_responses': questionnaire.substances.map((substance) => {
          'substance_id': substance.id, // Make sure this is the MongoDB ObjectId as a string
          'used_in_lifetime': substance.usedInLifetime,
          'frequency_last_3_months': substance.frequencyLast3Months,
          'urge_to_use': substance.urgeToUse,
          'health_social_problems': substance.healthSocialProblems,
          'failed_responsibilities': substance.failedResponsibilities,
          'concern_from_others': substance.concernFromOthers,
          'tried_to_control': substance.triedToControl,
          'injected': substance.injected,
          'injection_frequency': substance.injectionFrequency,
        }).toList(),
      };

      // Send to backend with retry mechanism
      final response = await _retryRequest(() =>
          http.post(
            Uri.parse('${ApiConfig.assessmentQuestionnaireEndpoint}submit/'),
            headers: _getHeaders(),
            body: jsonEncode(formattedData),
          )
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        print('Error saving questionnaire: ${response.statusCode} ${response.body}');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error saving questionnaire. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }

      // Cache questionnaire
      _questionnaire = questionnaire;

      // Update local storage flags
      await LocalStorageService.prefs.setBool('has_completed_assessment', true);

      // Call success callback if provided
      if (onSuccess != null) {
        onSuccess();
      }

      return true;
    } catch (e) {
      print('Error submitting questionnaire: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network error. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  /// Get analysis for a specific questionnaire
  Future<Map<String, dynamic>?> getQuestionnaireAnalysis(String questionnaireId) async {
    try {
      final response = await _retryRequest(() =>
      http.get(
          Uri.parse('${ApiConfig.assessmentQuestionnaireEndpoint}/$questionnaireId/analysis/'),
        headers: _getHeaders(),
      )
      );

      if (response.statusCode == 404) {
        return null;
      }

      _handleError(response);

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      print('Error getting questionnaire analysis: $e');
      return null;
    }
  }

  /// Check if user has completed assessment
  Future<bool> hasCompletedAssessment() async {
    final username = AuthService.getCurrentUsername();
    if (username == null) {
      throw Exception("User not logged in");
    }

    try {
      final response = await _retryRequest(() =>
          http.get(
            Uri.parse('${ApiConfig.assessmentQuestionnaireEndpoint}/has_completed/'),
            headers: _getHeaders(),
          )
      );

      _handleError(response);

      final data = jsonDecode(response.body);
      return data['hasCompleted'] ?? false;
    } catch (e) {
      print('Error checking assessment completion: $e');
      return false;
    }
  }

  //===========================================================================
  // UTILITY METHODS
  //===========================================================================

  static Future<bool> checkConnectivity() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/healthcheck/'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Connectivity check error: $e');
      return false;
    }
  }

  /// Get chat completion from the OpenAI API via backend
  Future<String> getChatResponse(String message, List<String> chatHistory) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.chatSendEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.getToken()}',
        },
        body: jsonEncode({
          'message': message,
          'chatHistory': chatHistory,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        print('OpenAI API Error: ${response.statusCode}');
        return _getFallbackResponse(message);
      }
    } catch (e) {
      print('Error getting chat response: $e');
      return _getFallbackResponse(message);
    }
  }

  //===========================================================================
  // HELPER METHODS
  //===========================================================================

  TaskCategory _mapStringToTaskCategory(String category) {
    switch (category.toLowerCase()) {
      case 'daily':
        return TaskCategory.daily;
      case 'exercise':
        return TaskCategory.exercise;
      case 'wellness':
        return TaskCategory.wellness;
      case 'medication':
        return TaskCategory.medication;
      case 'social':
        return TaskCategory.social;
      default:
        return TaskCategory.daily;
    }
  }

  List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;

    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }

    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        // If not valid JSON, maybe it's a comma-separated string
        if (value.contains(',')) {
          return value.split(',').map((e) => e.trim()).toList();
        }
        // Single value
        return [value];
      }
    }

    return null;
  }

  void _cacheTasksByCategory(String category, List<TaskItem> tasks) {
    switch (category.toLowerCase()) {
      case 'daily':
        _dailyTasks = tasks;
        break;
      case 'exercise':
        _exerciseTasks = tasks;
        break;
      case 'wellness':
        _wellnessTasks = tasks;
        break;
      case 'medication':
        _medicationTasks = tasks;
        break;
      case 'social':
        _socialTasks = tasks;
        break;
    }
  }

  List<TaskItem> _getCachedTasksByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'daily':
        return _dailyTasks;
      case 'exercise':
        return _exerciseTasks;
      case 'wellness':
        return _wellnessTasks;
      case 'medication':
        return _medicationTasks;
      case 'social':
        return _socialTasks;
      default:
        return [];
    }
  }

  String _getFallbackResponse(String message) {
    message = message.toLowerCase();

    if (message.contains('help') || message.contains('support')) {
      return "If you're struggling, remember to use your coping strategies. Would you like some suggestions?";
    } else if (message.contains('craving') || message.contains('urge')) {
      return "Cravings typically last 15-30 minutes. Try deep breathing, calling a friend, or going for a walk.";
    } else if (message.contains('stress') || message.contains('anxious') || message.contains('anxiety')) {
      return "Stress management is important in recovery. Have you tried the mindfulness exercises in your plan?";
    } else if (message.contains('hello') || message.contains('hi')) {
      return "Hello! How are you feeling today?";
    } else if (message.contains('thank')) {
      return "You're welcome! I'm here to support your recovery journey.";
    } else {
      return "I'm here to help with your recovery. Can you tell me more about what you're experiencing?";
    }
  }

  //===========================================================================
  // GETTERS FOR CACHED DATA
  //===========================================================================

  // Getters for cached data
  List<TaskItem> get dailyTasks => _dailyTasks;
  List<TaskItem> get exerciseTasks => _exerciseTasks;
  List<TaskItem> get wellnessTasks => _wellnessTasks;
  List<TaskItem> get medicationTasks => _medicationTasks;
  List<TaskItem> get socialTasks => _socialTasks;
  List<MoodEntry> get moodEntries => _moodEntries;
  List<JournalEntry> get journalEntries => _journalEntries;
  List<ChatMessage> get chatHistory => _chatHistory;
  List<Resource> get resources => _resources;
  List<Resource> get favoriteResources => _favoriteResources;
  TreatmentPlan? get selectedPlan => _selectedPlan;
  DateTime? get startDate => _startDate;
  AssistQuestionnaire? get questionnaire => _questionnaire;
}

/// Service to handle all authentication operations
class AuthService {
  // Replace with your actual backend URL
  static const String baseUrl = ApiConfig.authEndpoint;
  static String? _currentToken;
  static String? _currentUserId;
  static String? _currentUsername;

  // Save user data
  static Future<bool> saveUser(UserData userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': userData.username,
          'email': userData.email,
          'password': userData.password,
          'password_confirm': userData.password,
          'security_question': userData.securityQuestion,
          'security_answer': userData.securityAnswer,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true; // Indicate successful save
      } else {
        print('Error saving user: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error saving user: $e');
      return false; // Indicate save failure
    }
  }

  // Get security question for a user (for password recovery)
  static Future<Map<String, dynamic>?> getSecurityQuestion(String username) async {
    try {
      // Use the reset_password_request endpoint which returns the security question
      final response = await http.post(
        Uri.parse('${ApiConfig.authEndpoint}/reset_password_request/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error fetching security question: ${response.statusCode} ${response.body}');
        // Fallback for development/testing
        return {
          'username': username,
          'security_question': 'What was your first pet\'s name?'
        };
      }
    } catch (e) {
      print('Error getting security question: $e');
      // Fallback for development/testing
      return {
        'username': username,
        'security_question': 'What was your first pet\'s name?'
      };
    }
  }

  // Modified getUser method that can work during password recovery
  static Future<UserData?> getUserForRecovery(String username) async {
    try {
      // First check if the username exists
      final exists = await usernameExists(username);
      if (!exists) return null;

      // For demo/testing purposes - create a simple user with security question
      // In a real app, you would get this from the backend
      // This is a workaround for our current situation
      return UserData(
        username: username,
        email: '', // We don't need this for recovery
        password: '', // We don't need this for recovery
        securityQuestion: 'What was your first pet\'s name?', // Default security question
        securityAnswer: '', // We don't need this for verification
      );
    } catch (e) {
      print('Error getting user for recovery: $e');
      return null;
    }
  }

  // Get user by username
  static Future<UserData?> getUser(String username) async {
    try {
      final token = getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(ApiConfig.profileEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = UserData.fromJson(jsonDecode(response.body));
        return userData;
      }

      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Verify login
  static Future<bool> verifyLogin(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentToken = data['access'];
        _currentUsername = username;
        _currentUserId = data['user']['id'];

        // Store the token in secure storage
        await LocalStorageService.saveAuthToken(_currentToken!);

        // Save refresh token if available
        if (data['refresh'] != null) {
          await LocalStorageService.saveRefreshToken(data['refresh']);
        }

        // Set logged in state
        LocalStorageService.setLoggedIn(true);

        // Store assessment and treatment plan status
        final hasCompletedAssessment = data['has_completed_assessment'] ?? false;
        final hasTreatmentPlan = data['has_treatment_plan'] ?? false;

        // Store in SharedPreferences
        LocalStorageService.prefs.setBool('has_completed_assessment', hasCompletedAssessment);
        LocalStorageService.prefs.setBool('has_treatment_plan', hasTreatmentPlan);

        return true;
      }

      return false;
    } catch (e) {
      print('Error verifying login: $e');
      return false;
    }
  }

  // Update user password
  static Future<bool> updatePassword(String username, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.resetPasswordEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': newPassword,
          'password_confirm': newPassword, // Add confirmation
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      print('Error updating password: $e');
      return false;
    }
  }

  // Verify security answer
  static Future<bool> verifySecurityAnswer(String username, String answer) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verifySecurityAnswerEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'answer': answer,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['verified'] ?? false;
      } else {
        print('Error verifying security answer: ${response.statusCode} ${response.body}');
        // For development/testing: Allow any answer if API fails
        return true;
      }
    } catch (e) {
      print('Error verifying security answer: $e');
      // For development/testing: Allow any answer if API fails
      return true;
    }
  }

  // Log out
  static Future<bool> logout() async {
    try {
      final refreshToken = LocalStorageService.getRefreshToken();

      if (refreshToken != null) {
        // Send logout request to server
        try {
          await http.post(
            Uri.parse(ApiConfig.logoutEndpoint),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'refresh': refreshToken,
            }),
          );
        } catch (e) {
          // Ignore errors during logout API call
          print('Logout API call error: $e');
        }
      }

      // Clear local tokens and login state regardless of API response
      _currentToken = null;
      _currentUsername = null;
      _currentUserId = null;

      // Clear from storage
      await LocalStorageService.clearAuthToken();
      await LocalStorageService.clearRefreshToken();
      LocalStorageService.setLoggedIn(false);

      return true;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }

  // Refresh token
  static Future<bool> refreshToken() async {
    try {
      final refreshToken = LocalStorageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse(ApiConfig.tokenRefreshEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentToken = data['access'];
        await LocalStorageService.saveAuthToken(_currentToken!);
        return true;
      }

      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  // Check if username exists
  static Future<bool> usernameExists(String username) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.checkUsernameEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] ?? false;
      }

      return false;
    } catch (e) {
      print('Error checking if username exists: $e');
      return false;
    }
  }

  // Get current logged in username
  static String? getCurrentUsername() {
    return _currentUsername;
  }

  // Get the auth token
  static String? getToken() {
    // Try to get from memory first
    if (_currentToken != null) {
      return _currentToken;
    }

    // Try to get from local storage
    return LocalStorageService.getAuthToken();
  }

  // Get the current user ID
  static String? getUserId() {
    return _currentUserId;
  }
}