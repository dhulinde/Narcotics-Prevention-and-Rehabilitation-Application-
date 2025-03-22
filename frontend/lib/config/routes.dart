// config/routes.dart
import 'package:flutter/material.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/assessment/screens/assist_landing_screen.dart';
import '../features/treatment_plan/screens/treatment_plan_flow.dart';
import '../features/dashboard/screens/main_navigation_screen.dart';
import '../core/services/local_storage_service.dart';
import '../core/models/treatment_plan_model.dart';

class AppRoutes {
  // Named routes
  // static const String splash = '/';
  // static const String onboarding = '/onboarding/';
  static const String welcome = '/welcome/';
  static const String login = '/login/';
  // static const String createAccount = '/create-account/';
  // static const String securityQuestions = '/security_questions/';
  // static const String resetPassword = '/reset-password/';
  // static const String securityRecovery = '/security-recovery/';
  static const String assist = '/assist/';
  static const String treatmentPlans = '/treatment-plans/';
  static const String dashboard = '/dashboard/';
  // static const String moodTracker = '/mood-tracker/';
  // static const String recoveryAssistant = '/recovery-assistant/';
  // static const String resources = '/resources/';
  // static const String resourceDetails = '/resource-details/';
  // static const String menu = '/menu/';
  // static const String profile = '/profile/';
  // static const String settings = '/settings/';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case assist:
        return MaterialPageRoute(builder: (_) => const AssistLandingScreen());

      case treatmentPlans:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TreatmentPlanFlow(
            onComplete: args?['onComplete'] ?? () {},
          ),
        );

      case dashboard:
        final args = settings.arguments as Map<String, dynamic>?;

        // Get selected plan from arguments or try to find by name in preferences
        TreatmentPlan? selectedPlan = args?['selectedPlan'];
        final startDate = args?['startDate'] ?? DateTime.fromMillisecondsSinceEpoch(
            LocalStorageService.prefs.getInt('startDate') ?? DateTime.now().millisecondsSinceEpoch);

        // If arguments don't have the plan, try to get it from preferences
        if (selectedPlan == null) {
          final planName = LocalStorageService.prefs.getString('selectedPlanName');
          if (planName != null) {
            // Find the plan with the saved name
            final plans = TreatmentPlanService.getPlans();
            for (var plan in plans) {
              if (plan.name == planName) {
                selectedPlan = plan;
                break;
              }
            }
          }
        }

        // Save start date to preferences if it's from arguments
        if (args != null && args.containsKey('startDate')) {
          LocalStorageService.prefs.setInt('startDate', startDate.millisecondsSinceEpoch);
        }

        return MaterialPageRoute(
          builder: (_) => MainNavigationScreen(
            selectedPlan: selectedPlan,
            startDate: startDate,
          ),
        );

      // Add other routes as needed

      default:
        // Return a 404 page or default route
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Simple route map for legacy code compatibility
  static Map<String, WidgetBuilder> get routes => {
    welcome: (context) => const WelcomeScreen(),
    login: (context) => const WelcomeScreen(),
    assist: (context) => const AssistLandingScreen(),
    treatmentPlans: (context) {
      // Extract arguments if available
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return TreatmentPlanFlow(
        onComplete: args?['onComplete'] ?? () {
          // Default completion handler
          Navigator.pushReplacementNamed(context, dashboard);
        },
      );
    },
    dashboard: (context) {
      // Extract arguments if available
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      // Get selected plan from arguments or try to find by name in preferences
      TreatmentPlan? selectedPlan = args?['selectedPlan'];
      final startDate = args?['startDate'] ?? DateTime.fromMillisecondsSinceEpoch(
          LocalStorageService.prefs.getInt('startDate') ?? DateTime.now().millisecondsSinceEpoch);

      // If arguments don't have the plan, try to get it from preferences
      if (selectedPlan == null) {
        final planName = LocalStorageService.prefs.getString('selectedPlanName');
        if (planName != null) {
          // Find the plan with the saved name
          final plans = TreatmentPlanService.getPlans();
          for (var plan in plans) {
            if (plan.name == planName) {
              selectedPlan = plan;
              break;
            }
          }
        }
      }

      // Save start date to preferences if it's from arguments
      if (args != null && args.containsKey('startDate')) {
        LocalStorageService.prefs.setInt('startDate', startDate.millisecondsSinceEpoch);
      }

      return MainNavigationScreen(
        selectedPlan: selectedPlan,
        startDate: startDate,
      );
    },
  };
}