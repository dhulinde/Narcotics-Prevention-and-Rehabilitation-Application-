// features/assessment/screens/assist_landing_screen.dart
import 'package:flutter/material.dart';
import '../../../config/constants.dart';
import '../../../shared/widgets/custom_button.dart';
import 'assist_questionnaire_screen.dart';

class AssistLandingScreen extends StatelessWidget {
  const AssistLandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 40, bottom: 30), // Reduced padding
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.assessmentAccent,
                    AppColors.assessmentAccent.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Assessment icon
                  Container(
                    width: 70, // Slightly smaller
                    height: 70, // Slightly smaller
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.assignment_rounded,
                      size: 36, // Slightly smaller
                      color: AppColors.assessmentAccent,
                    ),
                  ),
                  const SizedBox(height: 12), // Reduced spacing

                  // Title
                  const Text(
                    AppStrings.assistTitle,
                    style: TextStyle(
                      fontSize: 28, // Smaller font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Reduced vertical padding
                child: SingleChildScrollView( // Wrap in SingleChildScrollView to allow scrolling
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Welcome text
                      const Text(
                        AppStrings.assistWelcome,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22, // Smaller font size
                          fontWeight: FontWeight.bold,
                          color: AppColors.assessmentAccent,
                        ),
                      ),

                      const SizedBox(height: 16), // Reduced spacing

                      // Description
                      Container(
                        padding: const EdgeInsets.all(16), // Reduced padding
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.assessmentAccent.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              AppStrings.assistDescription,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15, // Smaller font size
                                height: 1.4, // Reduced line height
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12), // Reduced spacing

                            // Information points
                            _buildInfoPoint(
                              context,
                              'This questionnaire helps assess your substance use patterns',
                              Icons.analytics_rounded,
                            ),
                            _buildInfoPoint(
                              context,
                              'Your answers will help create a personalized recovery plan',
                              Icons.psychology_alt_rounded,
                            ),
                            _buildInfoPoint(
                              context,
                              'All information is kept private and confidential',
                              Icons.lock_rounded,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24), // Added fixed spacing instead of Spacer

                      // Start button
                      CustomButton(
                        text: 'Start Questionnaire',
                        variant: ButtonVariant.gradient,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AssistQuestionnaireScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 8), // Small bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPoint(BuildContext context, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0), // Reduced padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6), // Reduced padding
            decoration: BoxDecoration(
              color: AppColors.assessmentAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.assessmentAccent,
              size: 18, // Smaller icon
            ),
          ),
          const SizedBox(width: 10), // Reduced spacing
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13, // Smaller font size
                height: 1.3, // Reduced line height
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}