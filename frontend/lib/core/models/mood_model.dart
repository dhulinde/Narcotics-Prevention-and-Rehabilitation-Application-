// core/models/mood_model.dart
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/api_data_service.dart';

// Update MoodType to match backend's enum values
enum MoodType {
  very_sad,  // Changed from verySad to match backend
  sad,
  neutral,
  happy,
  very_happy  // Changed from veryHappy to match backend
}

extension MoodTypeExtension on MoodType {
  String get stringValue {
    switch (this) {
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
    }
  }

// extension MoodTypeExtension on MoodType {
  String get emoji {
    switch (this) {
      case MoodType.very_sad: return '😢';
      case MoodType.sad: return '😔';
      case MoodType.neutral: return '😐';
      case MoodType.happy: return '😊';
      case MoodType.very_happy: return '😁';
    }
  }

  String get label {
    switch (this) {
      case MoodType.very_sad: return 'Woeful';
      case MoodType.sad: return 'Sad';
      case MoodType.neutral: return 'Neutral';
      case MoodType.happy: return 'Happy';
      case MoodType.very_happy: return 'Joyful';
    }
  }

  Color get color {
    switch (this) {
      case MoodType.very_sad: return const Color(0xFFEF4444); // Red
      case MoodType.sad: return const Color(0xFFF59E0B); // Amber
      case MoodType.neutral: return const Color(0xFF9CA3AF); // Gray
      case MoodType.happy: return const Color(0xFF22C55E); // Green
      case MoodType.very_happy: return const Color(0xFF10B981); // Emerald
    }
  }
}

/// Model class for Mood Entry
class MoodEntry {
  final String id; // Added id field
  final DateTime date;
  final MoodType mood;
  final String note;

  MoodEntry({
    this.id = '',
    required this.date,
    required this.mood,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'mood': mood.name,  // Using name to match backend enum
      'note': note,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    // Parse mood from string to enum
    MoodType parsedMood = MoodType.neutral;
    if (json['mood'] != null) {
      final moodString = json['mood'].toString().toLowerCase();
      for (var mood in MoodType.values) {
        if (mood.name == moodString) {
          parsedMood = mood;
          break;
        }
      }
    }

    return MoodEntry(
      id: json['id'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      mood: parsedMood,
      note: json['note'] ?? '',
    );
  }
}

class JournalEntry {
  final String id; // Added id field
  final DateTime date;
  final String text;

  JournalEntry({
    this.id = '',
    required this.date,
    required this.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'text': text,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      text: json['text'] ?? '',
    );
  }
}

/// Service for mood tracking
class MoodTrackingService {
  static List<MoodEntry> _moodHistory = [];
  static List<JournalEntry> _journalEntries = [];

  /// Initialize with data from database
  static Future<void> initialize() async {
  try {
  final username = AuthService.getCurrentUsername();
  if (username == null) {
  _moodHistory = [];
  _journalEntries = [];
  return;
  }

// Load mood entries from backend
  await getMoodHistory();
  await getJournalEntries();
  } catch (e) {
  print('Error initializing mood tracking: $e');
  _moodHistory = [];
  _journalEntries = [];
  }
  }

  /// Get mood history from backend
  static Future<List<MoodEntry>> getMoodHistory() async {
  final username = AuthService.getCurrentUsername();
  if (username != null) {
  try {
  final dbService = DatabaseService();
  final entries = await dbService.getMoodEntries(username);
  if (entries.isNotEmpty) {
  _moodHistory = entries;
  print('Loaded ${entries.length} mood entries');
  } else {
  print('No mood entries found');
  }
  } catch (e) {
  print('Error loading mood history: $e');
  }
  }
  return _moodHistory;
  }

  /// Add mood entry to backend
  static Future<void> addMoodEntry(MoodEntry entry) async {
  final username = AuthService.getCurrentUsername();
  if (username != null) {
  try {
  final dbService = DatabaseService();
  await dbService.saveMoodEntry(username, entry);
  print('Mood entry saved successfully');

// Update the local cache
  _moodHistory.add(entry);
  } catch (e) {
  print('Error saving mood entry: $e');
  throw e;
  }
  } else {
  print('Cannot save mood entry - user not logged in');
  throw Exception('User not logged in');
  }
  }

  /// Get journal entries from backend
  static Future<List<JournalEntry>> getJournalEntries() async {
  final username = AuthService.getCurrentUsername();
  if (username != null) {
  try {
  final dbService = DatabaseService();
  final entries = await dbService.getJournalEntries(username);
  if (entries.isNotEmpty) {
  _journalEntries = entries;
  print('Loaded ${entries.length} journal entries');
  } else {
  print('No journal entries found');
  }
  } catch (e) {
  print('Error loading journal entries: $e');
  }
  }
  return _journalEntries;
  }

  /// Add journal entry to backend
  static Future<void> addJournalEntry(JournalEntry entry) async {
  final username = AuthService.getCurrentUsername();
  if (username != null) {
  try {
  final dbService = DatabaseService();
  await dbService.saveJournalEntry(username, entry);
  print('Journal entry saved successfully');

// Update the local cache
  _journalEntries.add(entry);
  } catch (e) {
  print('Error saving journal entry: $e');
  throw e;
  }
  } else {
  print('Cannot save journal entry - user not logged in');
  throw Exception('User not logged in');
  }
  }

  /// Get mood statistics over the past week from backend data
  static Future<Map<String, dynamic>> getMoodStats() async {
  final moodHistory = await getMoodHistory();
  if (moodHistory.isEmpty) {
  return {
  'averageMood': MoodType.neutral,
  'bestDay': null,
  'worstDay': null,
  'moodDistribution': {},
  };
  }

// Calculate average mood
  int totalMoodValue = 0;
  Map<MoodType, int> distribution = {};

// Initialize distribution map
  for (var mood in MoodType.values) {
  distribution[mood] = 0;
  }

// Get entries from the last 7 days
  final DateTime now = DateTime.now();
  final DateTime weekAgo = now.subtract(const Duration(days: 7));

  final recentEntries = moodHistory.where(
  (entry) => entry.date.isAfter(weekAgo) && entry.date.isBefore(now)
  ).toList();

  if (recentEntries.isEmpty) {
  return {
  'averageMood': MoodType.neutral,
  'bestDay': null,
  'worstDay': null,
  'moodDistribution': distribution,
  };
  }

// Find best and worst days
  MoodEntry bestDay = recentEntries[0];
  MoodEntry worstDay = recentEntries[0];

  for (var entry in recentEntries) {
  totalMoodValue += entry.mood.index;
  distribution[entry.mood] = (distribution[entry.mood] ?? 0) + 1;

  if (entry.mood.index > bestDay.mood.index) {
  bestDay = entry;
  }

  if (entry.mood.index < worstDay.mood.index) {
  worstDay = entry;
  }
  }

// Calculate average mood
  double avgMoodValue = totalMoodValue / recentEntries.length;
  MoodType averageMood = MoodType.values[avgMoodValue.round()];

  return {
  'averageMood': averageMood,
  'bestDay': bestDay,
  'worstDay': worstDay,
  'moodDistribution': distribution,
  };
  }
  }