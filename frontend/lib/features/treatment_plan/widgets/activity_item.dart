// features/treatment_plan/widgets/activity_item.dart

import 'package:flutter/material.dart';
import '../../../core/models/treatment_plan_model.dart';

class ActivityItem extends StatelessWidget {
  final PlanActivity activity;
  final Color color;

  const ActivityItem({
    Key? key,
    required this.activity,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.05),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Activity icon or default icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIconForActivity(activity.icon),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Activity details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Changed to min
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 2, // Limit to two lines
                  overflow: TextOverflow.ellipsis, // Add ellipsis if too long
                ),
                if (activity.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    activity.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    maxLines: 3, // Limit to three lines
                    overflow: TextOverflow.ellipsis, // Add ellipsis if too long
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Map activity icons to their corresponding IconData
  IconData _getIconForActivity(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'journal':
        return Icons.book_outlined;
      case 'nutrition':
        return Icons.food_bank_outlined;
      case 'exercise':
        return Icons.fitness_center_outlined;
      case 'support':
        return Icons.people_outline;
      case 'fitness':
        return Icons.directions_run_outlined;
      case 'mindfulness':
        return Icons.self_improvement_outlined;
      case 'strategy':
        return Icons.lightbulb_outline;
      case 'transform':
        return Icons.psychology_alt_outlined;
      case 'relax':
        return Icons.spa_outlined;
      case 'meditation':
        return Icons.mediation_outlined;
      case 'activity':
        return Icons.accessibility_new_outlined;
      case 'connection':
        return Icons.link_outlined;
      case 'strength':
        return Icons.fitness_center_rounded;
      default:
        return Icons.check_circle_outline;
    }
  }
}