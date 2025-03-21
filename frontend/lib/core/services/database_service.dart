// core/services/database_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/assist_questionnaire_model.dart';
import '../models/mood_model.dart';
import '../models/task_item_model.dart';
import '../models/chat_message_model.dart';
import 'api_data_service.dart';
import '../../config/api_config.dart';

class DatabaseService {
  // Use the API config for endpoints
  final String baseUrl = ApiConfig.baseUrl;

  // API headers with auth token
  Map<String, String> _headers() {
    final token = AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Error handler
  void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      print('API Error: ${response.statusCode} ${response.body}');
      throw Exception('API Error: ${response.statusCode} ${response.body}');
    }
  }

  // ASSIST questionnaire methods
  Future<void> saveQuestionnaire(String username, AssistQuestionnaire questionnaire) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.assessmentEndpoint}/questionnaires/submit/'),
        headers: _headers(),
        body: jsonEncode(questionnaire.toJson()),
      );

      _handleError(response);
    } catch (e) {
      print('Error saving questionnaire to database: $e');
      throw e;
    }
  }

  Future<AssistQuestionnaire?> getLatestQuestionnaire(String username) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.assessmentEndpoint}/questionnaires/latest/'),
        headers: _headers(),
      );

      if (response.statusCode == 404) {
        return null;
      }

      _handleError(response);

      final data = jsonDecode(response.body);
      return AssistQuestionnaire.fromJson(data['questionnaire']);
    } catch (e) {
      print('Error getting questionnaire from database: $e');
      return null;
    }
  }

  // Treatment plan methods
  Future<void> saveTreatmentPlan(String username, String planName, DateTime startDate) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.treatmentPlansEndpoint}/user-plans/'),
        headers: _headers(),
        body: jsonEncode({
          'plan_id': planName,
          'start_date': startDate.toIso8601String(),
        }),
      );

      _handleError(response);
    } catch (e) {
      print('Error saving treatment plan to database: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>?> getUserPlan(String username) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.treatmentPlansEndpoint}/user-plans/current/'),
        headers: _headers(),
      );

      if (response.statusCode == 404) {
        return null;
      }

      _handleError(response);

      return jsonDecode(response.body);
    } catch (e) {
      print('Error getting user plan from database: $e');
      return null;
    }
  }

  // Mood tracking methods
  Future<void> saveMoodEntry(String username, MoodEntry entry) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.moodEndpoint}/entries/'),
        headers: _headers(),
        body: jsonEncode({
          'date': entry.date.toIso8601String(),
          'mood': entry.mood.index,
          'note': entry.note,
        }),
      );

      _handleError(response);
    } catch (e) {
      print('Error saving mood entry to database: $e');
      throw e;
    }
  }

  Future<List<MoodEntry>> getMoodEntries(String username, {int limit = 7}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.moodEndpoint}/entries?limit=$limit'),
        headers: _headers(),
      );

      _handleError(response);

      final List<dynamic> data = jsonDecode(response.body);
      print('Mood entries data: $data');
      return data.map((item) {
        return MoodEntry(
          date: DateTime.parse(item['date']),
          mood: MoodType.values[item['mood']],
          note: item['note'],
        );
      }).toList();
    } catch (e) {
      print('Error getting mood entries from database: $e');
      return [];
    }
  }

  // Journal methods
  Future<void> saveJournalEntry(String username, JournalEntry entry) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.moodEndpoint}/journal/'),
        headers: _headers(),
        body: jsonEncode({
          'date': entry.date.toIso8601String(),
          'text': entry.text,
        }),
      );

      _handleError(response);
    } catch (e) {
      print('Error saving journal entry to database: $e');
      throw e;
    }
  }

  Future<List<JournalEntry>> getJournalEntries(String username) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.moodEndpoint}/journal/'),
        headers: _headers(),
      );

      _handleError(response);

      final List<dynamic> data = jsonDecode(response.body);
      print('Journal entries data: $data');
      return data.map((item) {
        return JournalEntry(
          date: DateTime.parse(item['date']),
          text: item['text'],
        );
      }).toList();
    } catch (e) {
      print('Error getting journal entries from database: $e');
      return [];
    }
  }

  // Chat message methods
  Future<void> saveChatMessage(String username, ChatMessage message) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.chatEndpoint}/send/'),
        headers: _headers(),
        body: jsonEncode({
          'message': message.text,
          'is_user_message': message.isUserMessage,
          'timestamp': message.timestamp.toIso8601String(),
        }),
      );

      _handleError(response);
    } catch (e) {
      print('Error saving chat message to database: $e');
      throw e;
    }
  }

  Future<List<ChatMessage>> getChatMessages(String username) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.chatEndpoint}/history/'),
        headers: _headers(),
      );

      _handleError(response);

      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) {
        return ChatMessage(
          text: item['text'],
          isUserMessage: item['is_user_message'] ?? item['isUserMessage'],
          timestamp: DateTime.parse(item['timestamp']),
        );
      }).toList();
    } catch (e) {
      print('Error getting chat messages from database: $e');
      return [];
    }
  }

  // Task methods
  Future<List<TaskItem>> getTasks(String username, String category) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.tasksEndpoint}/?category=$category'),
        headers: _headers(),
      );

      _handleError(response);

      final List<dynamic> data = jsonDecode(response.body);
      print('Tasks data for $category: $data');

      return data.map((item) {
        // Parse reminderTime if present
        TimeOfDay? reminderTime;
        if (item['reminder_time'] != null && item['reminder_time'] != "") {
          final parts = item['reminder_time'].split(':');
          if (parts.length >= 2) {
            reminderTime = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1].split(':')[0]),
            );
          }
        }

        // Map the category string to enum
        TaskCategory taskCategory = TaskCategory.daily;
        switch (item['category'].toString().toLowerCase()) {
          case 'daily':
            taskCategory = TaskCategory.daily;
            break;
          case 'exercise':
            taskCategory = TaskCategory.exercise;
            break;
          case 'wellness':
            taskCategory = TaskCategory.wellness;
            break;
          case 'medication':
            taskCategory = TaskCategory.medication;
            break;
          case 'social':
            taskCategory = TaskCategory.social;
            break;
        }

        return TaskItem(
          title: item['title'],
          isCompleted: item['is_completed'] ?? false,
          category: taskCategory,
          reminderTime: reminderTime,
          note: item['note'],
        );
      }).toList();
    } catch (e) {
      print('Error getting tasks from database: $e');
      return [];
    }
  }

  Future<void> updateTaskCompletion(String username, String category, int index, bool isCompleted) async {
    try {
      // Get the task ID first
      final tasksResponse = await http.get(
        Uri.parse('${ApiConfig.tasksEndpoint}/?category=$category'),
        headers: _headers(),
      );

      _handleError(tasksResponse);

      final List<dynamic> tasks = jsonDecode(tasksResponse.body);

      if (index >= 0 && index < tasks.length) {
        final String taskId = tasks[index]['id'];

        final response = await http.patch(
          Uri.parse('${ApiConfig.tasksEndpoint}/$taskId/complete/'),
          headers: _headers(),
          body: jsonEncode({
            'is_completed': isCompleted,
          }),
        );

        _handleError(response);
      } else {
        throw Exception('Task index out of range');
      }
    } catch (e) {
      print('Error updating task completion in database: $e');
      throw e;
    }
  }

  // Resource methods
  Future<void> toggleFavoriteResource(String username, String resourceId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.resourcesEndpoint}/all/$resourceId/favorite/'),
        headers: _headers(),
      );

      _handleError(response);
    } catch (e) {
      print('Error toggling favorite resource in database: $e');
      throw e;
    }
  }

  Future<List<String>> getFavoriteResourceIds(String username) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.resourcesEndpoint}/favorites/'),
        headers: _headers(),
      );

      _handleError(response);

      final List<dynamic> data = jsonDecode(response.body);
      return data.map<String>((item) => item['resource']['id'].toString()).toList();
    } catch (e) {
      print('Error getting favorite resource IDs from database: $e');
      return [];
    }
  }
}