// lib/core/models/treatment_plan_model.dart
import 'dart:ui';

class PlanActivity {
  final String id; // Added id field
  final String title;
  final String? description;
  final String? icon;

  PlanActivity({
    this.id = '',
    required this.title,
    this.description,
    this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'icon': icon,
    };
  }

  factory PlanActivity.fromJson(Map<String, dynamic> json) {
    return PlanActivity(
      id: json['id'] ?? '',
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}

class TreatmentPlan {
  final String id; // Added id field
  final String name;
  final String description;
  final List<PlanActivity> activities;
  final String duration;
  final String intensity;
  final Color? color;
  final String? icon;

  TreatmentPlan({
    this.id = '',
    required this.name,
    required this.description,
    required this.activities,
    required this.duration,
    this.intensity = 'Moderate',
    this.color,
    this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'activities': activities.map((activity) => activity.toJson()).toList(),
      'duration': duration,
      'intensity': intensity,
      'color': color?.value,
      'icon': icon,
    };
  }

  factory TreatmentPlan.fromJson(Map<String, dynamic> json) {
    var activitiesList = <PlanActivity>[];

    if (json['activities'] != null) {
      activitiesList = (json['activities'] as List)
          .map((activityJson) => PlanActivity.fromJson(activityJson))
          .toList();
    }

    // Process color - handle different formats
    Color? planColor;
    if (json['color'] != null) {
      if (json['color'] is int) {
        planColor = Color(json['color']);
      } else if (json['color'] is String) {
        // Handle hex color string (e.g., "#10B981")
        final colorString = json['color'] as String;
        if (colorString.startsWith('#') && colorString.length == 7) {
          planColor = Color(int.parse('0xFF${colorString.substring(1)}'));
        }
      }
    }

    return TreatmentPlan(
      id: json['id'] ?? '',
      name: json['name'],
      description: json['description'],
      activities: activitiesList,
      duration: json['duration'],
      intensity: json['intensity'] ?? 'Moderate',
      color: planColor,
      icon: json['icon'],
    );
  }
}

// Add UserTreatmentPlan class to match backend model
class UserTreatmentPlan {
  final String id;
  final String userId;
  final TreatmentPlan plan;
  final DateTime startDate;

  UserTreatmentPlan({
    this.id = '',
    required this.userId,
    required this.plan,
    required this.startDate,
  });

  factory UserTreatmentPlan.fromJson(Map<String, dynamic> json) {
    return UserTreatmentPlan(
      id: json['id'] ?? '',
      userId: json['user'] ?? '',
      plan: TreatmentPlan.fromJson(json['plan']),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
    );
  }
}

/// Service for providing treatment plans
class TreatmentPlanService {
  /// Get available treatment plans
  static List<TreatmentPlan> getPlans() {
    return [
      TreatmentPlan(
        name: 'Fresh Start',
        description: 'A new day, a fresh start. This plan helps you build stability with small, mindful steps. One choice at a time—you\'re not alone.',
        activities: [
          PlanActivity(
            title: 'Self-check-in, gratitude journaling',
            description: 'Begin and end each day with mindful reflection',
            icon: 'journal',
          ),
          PlanActivity(
            title: 'Hydration, balanced meals',
            description: 'Focus on nourishing your body properly',
            icon: 'nutrition',
          ),
          PlanActivity(
            title: 'Gentle stretching, short walks',
            description: 'Light movement to reconnect with your body',
            icon: 'exercise',
          ),
          PlanActivity(
            title: 'Support groups, meaningful conversations',
            description: 'Building your support network is essential',
            icon: 'support',
          ),
        ],
        duration: '10-15 mins daily',
        intensity: 'Gentle',
        color: const Color(0xFF10B981), // Emerald green
        icon: 'sunrise',
      ),
      TreatmentPlan(
        name: 'Strong Everyday',
        description: 'Show up daily, build strength & balance, and take control of your recovery.',
        activities: [
          PlanActivity(
            title: 'Walking, light strength training',
            description: 'Build physical strength and resilience',
            icon: 'fitness',
          ),
          PlanActivity(
            title: 'Affirmations, deep breathing',
            description: 'Mental and emotional techniques for stability',
            icon: 'mindfulness',
          ),
          PlanActivity(
            title: 'Triggers & coping strategies',
            description: 'Learning to identify and manage triggers',
            icon: 'strategy',
          ),
        ],
        duration: '20-30 mins daily',
        intensity: 'Moderate',
        color: const Color(0xFF3B82F6), // Blue
        icon: 'mountain',
      ),
      TreatmentPlan(
        name: 'Resilience',
        description: 'Push forward with discipline. Your past doesn\'t define you—your actions do.',
        activities: [
          PlanActivity(
            title: 'Strength training, endurance workouts',
            description: 'Challenge yourself physically to build mental strength',
            icon: 'strength',
          ),
          PlanActivity(
            title: 'Journaling, reframing challenges',
            description: 'Transform your mindset and perspective',
            icon: 'transform',
          ),
          PlanActivity(
            title: 'Screen-free relaxation, gratitude',
            description: 'Find peace in unplugged moments of appreciation',
            icon: 'relax',
          ),
        ],
        duration: '30-45 mins daily',
        intensity: 'Challenging',
        color: const Color(0xFF8B5CF6), // Purple
        icon: 'shield',
      ),
      TreatmentPlan(
        name: 'Unbreakable',
        description: 'A holistic approach to emotional & physical recovery—you are unbreakable.',
        activities: [
          PlanActivity(
            title: 'Meditation, emotional check-ins',
            description: 'Deep inner work to process feelings and build awareness',
            icon: 'meditation',
          ),
          PlanActivity(
            title: 'Walks, swimming, stretching',
            description: 'Varied physical activities to strengthen body and mind',
            icon: 'activity',
          ),
          PlanActivity(
            title: 'Support groups, meaningful conversations',
            description: 'Connection as the foundation of lasting recovery',
            icon: 'connection',
          ),
        ],
        duration: '20-30 mins daily',
        intensity: 'Balanced',
        color: const Color(0xFFF59E0B), // Amber
        icon: 'diamond',
      ),
    ];
  }

  /// Find a plan by name
  static TreatmentPlan? findPlanByName(String name) {
    final plans = getPlans();
    for (var plan in plans) {
      if (plan.name == name) {
        return plan;
      }
    }
    return null;
  }
}