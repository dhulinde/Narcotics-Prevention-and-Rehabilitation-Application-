// features/treatment_plan/widgets/plan_button.dart

import 'package:flutter/material.dart';
import '../../../core/models/treatment_plan_model.dart';

class PlanButton extends StatelessWidget {
  final TreatmentPlan plan;
  final VoidCallback onTap;

  const PlanButton({
    Key? key,
    required this.plan,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: plan.color ?? Theme.of(context).primaryColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
          color: (plan.color ?? Theme.of(context).primaryColor).withOpacity(0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Changed to min
          children: [
            // Plan name and icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // Added Expanded to prevent overflow
                  child: Text(
                    plan.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: plan.color ?? Theme.of(context).primaryColor,
                    ),
                    maxLines: 1, // Limit to one line
                    overflow: TextOverflow.ellipsis, // Add ellipsis if too long
                  ),
                ),
                if (plan.icon != null)
                  Icon(
                    _getIconForPlan(plan.icon!),
                    color: plan.color ?? Theme.of(context).primaryColor,
                    size: 32,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Plan description
            Text(
              plan.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
              ),
              maxLines: 3, // Limit to three lines
              overflow: TextOverflow.ellipsis, // Add ellipsis if too long
            ),
            const SizedBox(height: 16),

            // Plan details
            Wrap( // Changed from Row to Wrap to handle overflow
              spacing: 8, // Horizontal space between chips
              runSpacing: 8, // Vertical space between chip rows
              children: [
                Chip(
                  label: Text(
                    'Intensity: ${plan.intensity}',
                    style: TextStyle(
                      color: plan.color ?? Theme.of(context).primaryColor,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: (plan.color ?? Theme.of(context).primaryColor).withOpacity(0.1),
                  visualDensity: VisualDensity.compact, // Make chips more compact
                ),
                Chip(
                  label: Text(
                    'Duration: ${plan.duration}',
                    style: TextStyle(
                      color: plan.color ?? Theme.of(context).primaryColor,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: (plan.color ?? Theme.of(context).primaryColor).withOpacity(0.1),
                  visualDensity: VisualDensity.compact, // Make chips more compact
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Map plan icons to their corresponding IconData
  IconData _getIconForPlan(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'sunrise':
        return Icons.wb_sunny_outlined;
      case 'mountain':
        return Icons.landscape_outlined;
      case 'shield':
        return Icons.security_outlined;
      case 'diamond':
        return Icons.diamond_outlined;
      default:
        return Icons.directions_walk_outlined;
    }
  }
}