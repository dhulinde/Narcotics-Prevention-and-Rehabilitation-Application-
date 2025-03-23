// features/onboarding/widgets/onboarding_page.dart
import 'package:flutter/material.dart';
import '../../../config/constants.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final Widget? illustration;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.description,
    this.imageUrl,
    this.illustration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image or illustration
          if (illustration != null)
            illustration!
          else if (imageUrl != null)
            Image.asset(
              imageUrl!,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
            ),

          const SizedBox(height: 40),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}