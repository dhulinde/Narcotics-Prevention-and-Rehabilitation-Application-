// features/onboarding/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import '../widgets/onboarding_page.dart';
import '../../../config/constants.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../config/routes.dart';
import '../../../shared/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  final int initialPage;

  const OnboardingScreen({
    Key? key,
    this.initialPage = 0,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  final int _totalPages = 3;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    // Mark onboarding as completed
    LocalStorageService.setOnboardingCompleted(true);

    // Navigate to welcome screen
    Navigator.pushReplacementNamed(context, AppRoutes.welcome);
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Page view for onboarding content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const BouncingScrollPhysics(),
                children: [
                  // Page 1
                  OnboardingPage(
                    title: AppStrings.onboarding1Title,
                    description: 'Take the first step towards recovery with our personalized support system.',
                    imageUrl: 'assets/images/onboarding1.png',
                    illustration: _buildIllustration1(),
                  ),

                  // Page 2
                  OnboardingPage(
                    title: AppStrings.onboarding2Title,
                    description: 'Connect with a community of people who understand your journey.',
                    imageUrl: 'assets/images/onboarding2.png',
                    illustration: _buildIllustration2(),
                  ),

                  // Page 3
                  OnboardingPage(
                    title: AppStrings.onboarding3Title,
                    description: 'Our AI assistant helps you navigate challenges with personalized guidance.',
                    imageUrl: 'assets/images/onboarding3.png',
                    illustration: _buildIllustration3(),
                  ),
                ],
              ),
            ),

            // Page indicator and navigation buttons
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _totalPages,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        height: 10,
                        width: index == _currentPage ? 30 : 10,
                        decoration: BoxDecoration(
                          color: index == _currentPage
                              ? AppColors.primary
                              : AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button (except on first page)
                      _currentPage > 0
                          ? IconButton(
                              onPressed: _goToPreviousPage,
                              icon: const Icon(Icons.arrow_back_rounded),
                              color: AppColors.primary,
                            )
                          : const SizedBox(width: 48), // Placeholder for alignment

                      // Next/Done button
                      CustomButton(
                        text: _currentPage == _totalPages - 1 ? 'Get Started' : 'Next',
                        onPressed: _goToNextPage,
                        variant: ButtonVariant.gradient,
                        width: 180,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom illustrations for onboarding pages
  Widget _buildIllustration1() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.healing_rounded,
              size: 120,
              color: AppColors.primary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration2() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.people_alt_rounded,
              size: 120,
              color: AppColors.secondary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration3() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: AppColors.resourcesAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.resourcesAccent.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.psychology_alt_rounded,
              size: 120,
              color: AppColors.resourcesAccent.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}