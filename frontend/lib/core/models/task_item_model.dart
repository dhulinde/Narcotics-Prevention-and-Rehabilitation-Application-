// core/models/task_item_model.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_data_service.dart';
import '../services/database_service.dart';

/// Task Category enum
enum TaskCategory {
  daily,
  exercise,
  wellness,
  medication,
  social
}

/// Extension for task category
extension TaskCategoryExtension on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.daily:
        return 'Daily Tasks';
      case TaskCategory.exercise:
        return 'Exercise';
      case TaskCategory.wellness:
        return 'Wellness';
      case TaskCategory.medication:
        return 'Medication';
      case TaskCategory.social:
        return 'Social';
    }
  }

  String get stringValue {
    switch (this) {
      case TaskCategory.daily:
        return 'daily';
      case TaskCategory.exercise:
        return 'exercise';
      case TaskCategory.wellness:
        return 'wellness';
      case TaskCategory.medication:
        return 'medication';
      case TaskCategory.social:
        return 'social';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskCategory.daily:
        return Icons.check_circle_outline;
      case TaskCategory.exercise:
        return Icons.fitness_center;
      case TaskCategory.wellness:
        return Icons.self_improvement;
      case TaskCategory.medication:
        return Icons.medication;
      case TaskCategory.social:
        return Icons.people;
    }
  }

  Color get color {
    switch (this) {
      case TaskCategory.daily:
        return const Color(0xFF6366F1); // Primary
      case TaskCategory.exercise:
        return const Color(0xFF10B981); // Green
      case TaskCategory.wellness:
        return const Color(0xFF8B5CF6); // Purple
      case TaskCategory.medication:
        return const Color(0xFFF59E0B); // Amber
      case TaskCategory.social:
        return const Color(0xFF3B82F6); // Blue
    }
  }
}

/// Model class for task items
class TaskItem {
  final String id; // To match backend '_id' field
  final String title;
  bool isCompleted;
  final TaskCategory category;
  final TimeOfDay? reminderTime;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskItem({
    this.id = '',
    required this.title,
    required this.isCompleted,
    this.category = TaskCategory.daily,
    this.reminderTime,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'is_completed': isCompleted, // Changed to snake_case to match backend
      'category': category.stringValue,
      'reminder_time': reminderTime != null
          ? '${reminderTime!.hour.toString().padLeft(2, '0')}:${reminderTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'note': note,
    };
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    // Parse reminder time if present
    TimeOfDay? reminder;
    if (json['reminder_time'] != null) {
      try {
        final parts = json['reminder_time'].toString().split(':');
        if (parts.length >= 2) {
          reminder = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      } catch (e) {
        print('Error parsing reminder time: $e');
      }
    }

    // Parse category - converting from string to enum
    TaskCategory taskCategory = TaskCategory.daily; // Default
    if (json['category'] != null) {
      final categoryStr = json['category'].toString().toLowerCase();
      for (var cat in TaskCategory.values) {
        if (cat.stringValue == categoryStr) {
          taskCategory = cat;
          break;
        }
      }
    }

    // Parse dates
    DateTime? created;
    DateTime? updated;
    try {
      if (json['created_at'] != null) {
        created = DateTime.parse(json['created_at'].toString());
      }
      if (json['updated_at'] != null) {
        updated = DateTime.parse(json['updated_at'].toString());
      }
    } catch (e) {
      print('Error parsing dates: $e');
    }

    return TaskItem(
      id: json['id'] ?? json['_id'] ?? '', // Handle both id and _id
      title: json['title'] ?? '',
      isCompleted: json['is_completed'] ?? json['isCompleted'] ?? false, // Handle both formats
      category: taskCategory,
      reminderTime: reminder,
      note: json['note'],
      createdAt: created,
      updatedAt: updated,
    );
  }
}

/// Service for managing tasks
class TaskService {
  static List<TaskItem> _dailyTasks = [];
  static List<TaskItem> _exercises = [];
  static List<TaskItem> _wellnessTasks = [];
  static List<TaskItem> _medicationTasks = [];
  static List<TaskItem> _socialTasks = [];
  static bool _initialized = false;

  // Base URL for the backend API
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  /// Initialize with tasks from backend
  static Future<void> initialize() async {
    if (_initialized) return;

    final username = AuthService.getCurrentUsername();
    if (username == null) {
      _dailyTasks = [];
      _exercises = [];
      _wellnessTasks = [];
      _medicationTasks = [];
      _socialTasks = [];
      _initialized = true;
      return;
    }

    try {
      // Get tasks from backend (these are AI-generated on the backend)
      final dbService = DatabaseService();
      _dailyTasks = await dbService.getTasks(username, 'daily');
      _exercises = await dbService.getTasks(username, 'exercise');
      _wellnessTasks = await dbService.getTasks(username, 'wellness');
      _medicationTasks = await dbService.getTasks(username, 'medication');
      _socialTasks = await dbService.getTasks(username, 'social');

      _initialized = true;
    } catch (e) {
      print('Error initializing tasks: $e');
      // Initialize with empty lists
      _dailyTasks = [];
      _exercises = [];
      _wellnessTasks = [];
      _medicationTasks = [];
      _socialTasks = [];
      _initialized = true;
    }
  }

  /// Get daily tasks
  static Future<List<TaskItem>> getDailyTasks() async {
    if (!_initialized) {
      await initialize();
    }

    final username = AuthService.getCurrentUsername();
    if (username != null) {
      try {
        final dbService = DatabaseService();
        final tasks = await dbService.getTasks(username, 'daily');
        if (tasks.isNotEmpty) {
          _dailyTasks = tasks;
        }
      } catch (e) {
        print('Error getting daily tasks: $e');
      }
    }

    return _dailyTasks;
  }

  /// Update daily task
  static Future<void> updateDailyTask(int index, bool isCompleted) async {
    if (index >= 0 && index < _dailyTasks.length) {
      _dailyTasks[index].isCompleted = isCompleted;

      final username = AuthService.getCurrentUsername();
      if (username != null) {
        final dbService = DatabaseService();
        await dbService.updateTaskCompletion(username, 'daily', index, isCompleted);
      }
    }
  }

  /// Get exercises
  static Future<List<TaskItem>> getExercises() async {
    if (!_initialized) {
      await initialize();
    }

    final username = AuthService.getCurrentUsername();
    if (username != null) {
      try {
        final dbService = DatabaseService();
        final tasks = await dbService.getTasks(username, 'exercise');
        if (tasks.isNotEmpty) {
          _exercises = tasks;
        }
      } catch (e) {
        print('Error getting exercises: $e');
      }
    }

    return _exercises;
  }

  /// Update exercise
  static Future<void> updateExercise(int index, bool isCompleted) async {
    if (index >= 0 && index < _exercises.length) {
      _exercises[index].isCompleted = isCompleted;

      final username = AuthService.getCurrentUsername();
      if (username != null) {
        final dbService = DatabaseService();
        await dbService.updateTaskCompletion(username, 'exercise', index, isCompleted);
      }
    }
  }

  /// Get wellness tasks
  static Future<List<TaskItem>> getWellnessTasks() async {
    if (!_initialized) {
      await initialize();
    }

    final username = AuthService.getCurrentUsername();
    if (username != null) {
      try {
        final dbService = DatabaseService();
        final tasks = await dbService.getTasks(username, 'wellness');
        if (tasks.isNotEmpty) {
          _wellnessTasks = tasks;
        }
      } catch (e) {
        print('Error getting wellness tasks: $e');
      }
    }

    return _wellnessTasks;
  }

  /// Get medication tasks
  static Future<List<TaskItem>> getMedicationTasks() async {
    if (!_initialized) {
      await initialize();
    }

    final username = AuthService.getCurrentUsername();
    if (username != null) {
      try {
        final dbService = DatabaseService();
        final tasks = await dbService.getTasks(username, 'medication');
        if (tasks.isNotEmpty) {
          _medicationTasks = tasks;
        }
      } catch (e) {
        print('Error getting medication tasks: $e');
      }
    }

    return _medicationTasks;
  }

  /// Get social tasks
  static Future<List<TaskItem>> getSocialTasks() async {
    if (!_initialized) {
      await initialize();
    }

    final username = AuthService.getCurrentUsername();
    if (username != null) {
      try {
        final dbService = DatabaseService();
        final tasks = await dbService.getTasks(username, 'social');
        if (tasks.isNotEmpty) {
          _socialTasks = tasks;
        }
      } catch (e) {
        print('Error getting social tasks: $e');
      }
    }

    return _socialTasks;
  }

  /// Get tasks by category
  static Future<List<TaskItem>> getTasksByCategory(TaskCategory category) async {
    switch (category) {
      case TaskCategory.daily:
        return getDailyTasks();
      case TaskCategory.exercise:
        return getExercises();
      case TaskCategory.wellness:
        return getWellnessTasks();
      case TaskCategory.medication:
        return getMedicationTasks();
      case TaskCategory.social:
        return getSocialTasks();
    }
  }

  /// Update task by category
  static Future<void> updateTask(TaskCategory category, int index, bool isCompleted) async {
    final username = AuthService.getCurrentUsername();
    if (username == null) return;

    final dbService = DatabaseService();
    await dbService.updateTaskCompletion(
        username,
        category.stringValue,
        index,
        isCompleted
    );

    switch (category) {
      case TaskCategory.daily:
        return updateDailyTask(index, isCompleted);
      case TaskCategory.exercise:
        return updateExercise(index, isCompleted);
      case TaskCategory.wellness:
        if (index >= 0 && index < _wellnessTasks.length) {
          _wellnessTasks[index].isCompleted = isCompleted;
        }
        break;
      case TaskCategory.medication:
        if (index >= 0 && index < _medicationTasks.length) {
          _medicationTasks[index].isCompleted = isCompleted;
        }
        break;
      case TaskCategory.social:
        if (index >= 0 && index < _socialTasks.length) {
          _socialTasks[index].isCompleted = isCompleted;
        }
        break;
    }
  }

  /// Calculate percentage completion for tasks
  static Future<double> calculateDailyTasksPercentage() async {
    final tasks = await getDailyTasks();
    if (tasks.isEmpty) return 0.0;
    int completedCount = tasks.where((task) => task.isCompleted).length;
    return (completedCount / tasks.length) * 100;
  }

  /// Calculate percentage completion for exercises
  static Future<double> calculateExercisesPercentage() async {
    final exercises = await getExercises();
    if (exercises.isEmpty) return 0.0;
    int completedCount = exercises.where((exercise) => exercise.isCompleted).length;
    return (completedCount / exercises.length) * 100;
  }

  /// Calculate percentage completion for category
  static Future<double> calculateCategoryPercentage(TaskCategory category) async {
    final tasks = await getTasksByCategory(category);
    if (tasks.isEmpty) return 0.0;
    int completedCount = tasks.where((task) => task.isCompleted).length;
    return (completedCount / tasks.length) * 100;
  }

  /// Calculate overall progress
  static Future<double> calculateOverallProgress() async {
    final dailyTasks = await getDailyTasks();
    final exercises = await getExercises();
    final wellnessTasks = await getWellnessTasks();
    final medicationTasks = await getMedicationTasks();
    final socialTasks = await getSocialTasks();

    int totalTasks = dailyTasks.length + exercises.length + wellnessTasks.length +
        medicationTasks.length + socialTasks.length;

    if (totalTasks == 0) return 0.0;

    int completedTasks =
        dailyTasks.where((task) => task.isCompleted).length +
            exercises.where((task) => task.isCompleted).length +
            wellnessTasks.where((task) => task.isCompleted).length +
            medicationTasks.where((task) => task.isCompleted).length +
            socialTasks.where((task) => task.isCompleted).length;

    return (completedTasks / totalTasks) * 100;
  }

  /// Add task to category
  static Future<void> addTask(TaskItem task) async {
    final username = AuthService.getCurrentUsername();
    if (username == null) return;

    switch (task.category) {
      case TaskCategory.daily:
        _dailyTasks.add(task);
        break;
      case TaskCategory.exercise:
        _exercises.add(task);
        break;
      case TaskCategory.wellness:
        _wellnessTasks.add(task);
        break;
      case TaskCategory.medication:
        _medicationTasks.add(task);
        break;
      case TaskCategory.social:
        _socialTasks.add(task);
        break;
    }

    // Update backend
    try {
      // Since there's no addTask method in DatabaseService,
      // we'll make a direct HTTP call to the backend
      final token = AuthService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/tasks/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Error adding task: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  /// Remove task from category
  static Future<void> removeTask(TaskCategory category, int index) async {
    final username = AuthService.getCurrentUsername();
    if (username == null) return;

    String taskId = '';

    switch (category) {
      case TaskCategory.daily:
        if (index >= 0 && index < _dailyTasks.length) {
          taskId = _dailyTasks[index].id;
          _dailyTasks.removeAt(index);
        }
        break;
      case TaskCategory.exercise:
        if (index >= 0 && index < _exercises.length) {
          taskId = _exercises[index].id;
          _exercises.removeAt(index);
        }
        break;
      case TaskCategory.wellness:
        if (index >= 0 && index < _wellnessTasks.length) {
          taskId = _wellnessTasks[index].id;
          _wellnessTasks.removeAt(index);
        }
        break;
      case TaskCategory.medication:
        if (index >= 0 && index < _medicationTasks.length) {
          taskId = _medicationTasks[index].id;
          _medicationTasks.removeAt(index);
        }
        break;
      case TaskCategory.social:
        if (index >= 0 && index < _socialTasks.length) {
          taskId = _socialTasks[index].id;
          _socialTasks.removeAt(index);
        }
        break;
    }

    // Update backend
    if (taskId.isNotEmpty) {
      try {
        // Make direct HTTP call to the backend
        final token = AuthService.getToken();
        final response = await http.delete(
          Uri.parse('$baseUrl/tasks/$taskId/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode != 200 && response.statusCode != 204) {
          print('Error removing task: ${response.statusCode} ${response.body}');
        }
      } catch (e) {
        print('Error removing task: $e');
      }
    }
  }
}