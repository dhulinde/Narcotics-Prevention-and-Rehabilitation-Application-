// features/mood_tracker/screens/mood_tracker_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../core/models/mood_model.dart';
import '../../../config/constants.dart';
import '../../../config/api_config.dart';
import '../../../core/services/api_data_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/mood_selector.dart';
import '../widgets/mood_history_item.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({Key? key}) : super(key: key);

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  // Mood tracking
  List<MoodEntry> _moodHistory = [];
  MoodType _selectedMood = MoodType.neutral;
  final TextEditingController _noteController = TextEditingController();

  // Journal entries
  List<JournalEntry> _journalEntries = [];
  final TextEditingController _journalController = TextEditingController();

  bool _isLoading = false;
  final ApiDataService _apiService = ApiDataService();

  @override
  void initState() {
    super.initState();
    // Load mood data
    _loadMoodData();
  }

  // Helper function to filter entries from the last 7 days
  List<T> _filterLast7Days<T>(List<T> entries, DateTime Function(T) getDate) {
    final DateTime now = DateTime.now();
    final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));

    return entries.where((entry) {
      DateTime entryDate = getDate(entry);
      return entryDate.isAfter(sevenDaysAgo);
    }).toList();
  }

  Future<void> _loadMoodData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load mood history
      final moodEntries = await _apiService.loadMoodHistory();

      // Filter for last 7 days only
      final filteredMoodEntries = _filterLast7Days<MoodEntry>(
          moodEntries,
              (entry) => entry.date
      );

      setState(() {
        _moodHistory = filteredMoodEntries;
        _isLoading = false;
      });

      // Load journal entries separately
      await _loadJournalData();
    } catch (e) {
      print('Error loading mood data: $e');
      setState(() {
        _isLoading = false;
      });

      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load mood data. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadJournalData() async {
    try {
      final token = AuthService.getToken();
      if (token == null) {
        throw Exception("User not logged in");
      }

      // Use the correct endpoint for journal entries
      final response = await http.get(
        Uri.parse("${ApiConfig.moodEndpoint}/journal/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 400) {
        print('Journal history error: ${response.statusCode} ${response.body}');
        throw Exception("Failed to load journal entries: ${response.statusCode}");
      }

      // Parse the response as a Map first
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Extract the "results" list from the paginated response
      final List<dynamic> data = responseData['results'] ?? [];
      print('Journal data loaded: ${data.length} entries');

      final journalEntries = data.map((item) {
        return JournalEntry(
          id: item['id'] ?? '',
          date: DateTime.parse(item['date']),
          text: item['text'] ?? '',
        );
      }).toList();

      // Filter for last 7 days only
      final filteredJournalEntries = _filterLast7Days<JournalEntry>(
          journalEntries,
              (entry) => entry.date
      );

      setState(() {
        _journalEntries = filteredJournalEntries;
        print('Updated _journalEntries: ${_journalEntries.length} entries');
      });
    } catch (e) {
      print('Error loading journal entries: $e');
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _journalController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    if (_noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a note about your mood')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save mood entry using API service - fixed version that sends string mood value
      final token = AuthService.getToken();
      if (token == null) {
        throw Exception("User not logged in");
      }

      // Convert MoodType enum to string value
      final String moodString = _getMoodTypeString(_selectedMood);

      final response = await http.post(
        Uri.parse(ApiConfig.moodSaveEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'mood': moodString,
          'note': _noteController.text,
        }),
      );

      if (response.statusCode >= 400) {
        print('Mood save error: ${response.statusCode} ${response.body}');
        throw Exception("Failed to save mood entry: ${response.statusCode}");
      }

      // Reset inputs
      _noteController.clear();
      setState(() {
        _selectedMood = MoodType.neutral;
        _isLoading = false;
      });

      // Reload mood history
      await _loadMoodData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood saved successfully!')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving mood: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveJournalEntry() async {
    if (_journalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something in your journal entry')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save journal entry using direct API call - fixed endpoint
      final token = AuthService.getToken();
      if (token == null) {
        throw Exception("User not logged in");
      }

      // Use the correct endpoint for journal entries
      final response = await http.post(
        // Modified URL from journal/save/ to journal/
        Uri.parse("${ApiConfig.moodEndpoint}/journal/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'text': _journalController.text,
        }),
      );

      if (response.statusCode >= 400) {
        print('Journal save error: ${response.statusCode} ${response.body}');
        throw Exception("Failed to save journal entry: ${response.statusCode}");
      }

      // Reset input
      _journalController.clear();
      setState(() {
        _isLoading = false;
      });

      // Reload journal entries
      await _loadJournalData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal entry saved!')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving journal entry: ${e.toString()}')),
      );
    }
  }

  // Helper function to map mood enum to string value expected by backend
  String _getMoodTypeString(MoodType mood) {
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
    }
  }

  void _showMoodDetails(MoodEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(entry.mood.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(DateFormat('MMM d, yyyy').format(entry.date)),
          ],
        ),
        content: Text(entry.note),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          AppStrings.moodTrackerTitle,
          style: TextStyle(
            color: AppColors.moodAccent,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.moodAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.moodAccent,
        ),
      )
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.moodAccent.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's Mood Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.moodAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.mood,
                                color: AppColors.moodAccent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "How are you feeling today?",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        MoodSelector(
                          selectedMood: _selectedMood,
                          onMoodSelected: (mood) {
                            setState(() {
                              _selectedMood = mood;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            hintText: "Add a note about your mood...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.lightGrey,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: "Save Mood",
                          onPressed: _saveMood,
                          variant: ButtonVariant.gradient,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mood History Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.moodAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.history,
                              color: AppColors.moodAccent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Mood History",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Last 7 days",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _moodHistory.isEmpty
                        ? const Center(
                      child: Text(
                        "No mood entries yet",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    )
                        : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _moodHistory.length,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemBuilder: (context, index) {
                        final entry = _moodHistory[_moodHistory.length - 1 - index]; // Reverse order
                        return MoodHistoryItem(
                          entry: entry,
                          onTap: () => _showMoodDetails(entry),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Journal Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.moodAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.book,
                                color: AppColors.moodAccent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Recovery Journal",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _journalController,
                          decoration: InputDecoration(
                            hintText: "Write about your journey today...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.lightGrey,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: "Save Entry",
                          onPressed: _saveJournalEntry,
                          variant: ButtonVariant.gradient,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Journal Entries Section
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.moodAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.history,
                                    color: AppColors.moodAccent,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Journal History",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "Last 7 days",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Journal entries list
                        _journalEntries.isEmpty
                            ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "No journal entries yet",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                            : Column(
                          children: _journalEntries
                              .map((entry) => _buildJournalEntry(entry))
                              .toList()
                              .reversed
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJournalEntry(JournalEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.moodAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: AppColors.moodAccent,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DateFormat('EEEE, MMM d, yyyy').format(entry.date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}