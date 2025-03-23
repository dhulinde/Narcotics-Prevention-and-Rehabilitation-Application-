// features/treatment_plan/screens/plan_detail_screen.dart
import 'package:flutter/material.dart';
import '../../../core/models/treatment_plan_model.dart';
import '../widgets/activity_item.dart';

class PlanDetailScreen extends StatelessWidget {
  final TreatmentPlan plan;
  final VoidCallback onStartPlan;

  const PlanDetailScreen({
    Key? key,
    required this.plan,
    required this.onStartPlan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          plan.name,
          style: TextStyle(
            color: plan.color ?? Theme.of(context).primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: plan.color ?? Theme.of(context).primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (plan.color ?? Theme.of(context).primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  plan.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Plan details - FIXED: Wrap in a Column instead of a Row, or make the chips flexible
              // Option 1: Use Wrap instead of Row to allow wrapping to next line
              Wrap(
                spacing: 8, // space between chips
                runSpacing: 8, // space between lines
                children: [
                  Chip(
                    label: Text(
                      'Intensity: ${plan.intensity}',
                      style: TextStyle(
                        color: plan.color ?? Theme.of(context).primaryColor,
                      ),
                    ),
                    backgroundColor: (plan.color ?? Theme.of(context).primaryColor).withOpacity(0.1),
                  ),
                  Chip(
                    label: Text(
                      'Duration: ${plan.duration}',
                      style: TextStyle(
                        color: plan.color ?? Theme.of(context).primaryColor,
                      ),
                    ),
                    backgroundColor: (plan.color ?? Theme.of(context).primaryColor).withOpacity(0.1),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Activities list
              const Text(
                'Plan Activities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: plan.activities.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final activity = plan.activities[index];
                    return ActivityItem(
                      activity: activity,
                      color: plan.color ?? Theme.of(context).primaryColor,
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Start plan button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onStartPlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: plan.color ?? Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Start This Plan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}