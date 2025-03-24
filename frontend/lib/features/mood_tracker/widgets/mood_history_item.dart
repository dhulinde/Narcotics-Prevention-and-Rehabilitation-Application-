// features/mood_tracker/widgets/mood_history_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/mood_model.dart';
import '../../../config/constants.dart';

class MoodHistoryItem extends StatelessWidget {
  final MoodEntry entry;
  final VoidCallback onTap;

  const MoodHistoryItem({
    Key? key,
    required this.entry,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        // Increase the height slightly to accommodate all content
        height: 85, // Increased from previous value
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: entry.mood.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: entry.mood.color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Changed to min
          children: [
            Text(
              entry.mood.emoji,
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 2), // Reduced spacing
            Text(
              DateFormat('MMM d').format(entry.date),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              entry.mood.label,
              style: TextStyle(
                fontSize: 10,
                color: entry.mood.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}