// features/mood_tracker/widgets/mood_selector.dart
import 'package:flutter/material.dart';
import '../../../core/models/mood_model.dart';
import '../../../config/constants.dart';

class MoodSelector extends StatelessWidget {
  final MoodType selectedMood;
  final Function(MoodType) onMoodSelected;

  const MoodSelector({
    Key? key,
    required this.selectedMood,
    required this.onMoodSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMoodOption(context, MoodType.very_sad),
          _buildMoodOption(context, MoodType.sad),
          _buildMoodOption(context, MoodType.neutral),
          _buildMoodOption(context, MoodType.happy),
          _buildMoodOption(context, MoodType.very_happy),
        ],
      ),
    );
  }

  Widget _buildMoodOption(BuildContext context, MoodType mood) {
    final bool isSelected = selectedMood == mood;

    return GestureDetector(
      onTap: () {
        onMoodSelected(mood);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 55,
        // Increase height slightly to accommodate content
        height: 82,
        decoration: BoxDecoration(
          color: isSelected ? mood.color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: mood.color, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Use minimum space needed
          children: [
            Text(
              mood.emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 2), // Reduced spacing
            Text(
              mood.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? mood.color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}