// features/onboarding/screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../../../config/constants.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/api_data_service.dart';
import '../screens/onboarding_screen.dart';
import '../../../config/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final ApiDataService _apiService = ApiDataService();

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Start animation
    _animationController.forward();

    // Auto-navigate after animation completes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    // Check flags locally first
    final hasCompletedOnboarding = LocalStorageService.hasCompletedOnboarding();
    final isLoggedIn = LocalStorageService.isLoggedIn();
    final authToken = LocalStorageService.getAuthToken();

    // If not onboarded, go to onboarding
    if (!hasCompletedOnboarding) {
      // First time user - start with onboarding
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ),
      );
      return;
    }

    // If not logged in, go to welcome/login screen
    if (!isLoggedIn || authToken == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
      return;
    }

    // User is logged in, check screening status from API service
    try {
      final hasCompletedScreening = await _apiService.hasCompletedAssessment();

      if (!mounted) return;

      if (!hasCompletedScreening) {
        // Navigate to ASSIST questionnaire
        Navigator.pushReplacementNamed(context, AppRoutes.assist);
      } else {
        // Navigate to dashboard
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    } catch (e) {
      print('Error checking user status: $e');
      // Error - go to login screen
      if (!mounted) return;
      LocalStorageService.clearAuthToken();
      LocalStorageService.setLoggedIn(false);
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.healing_rounded,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App name
                    const Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // App tagline
                    Text(
                      AppStrings.appTagline,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Loading indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                        value: _animationController.value,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}