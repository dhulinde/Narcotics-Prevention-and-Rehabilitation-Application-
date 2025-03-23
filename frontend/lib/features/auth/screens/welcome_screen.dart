// features/auth/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import '../../../core/services/local_storage_service.dart';
import '../widgets/auth_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../config/constants.dart';
import '../../../core/services/api_data_service.dart';
import '../../../config/routes.dart';
import 'create_account_screen.dart';
import 'security_questions_recovery_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Remove the demo user creation
    // AuthService.createDemoUser();
  }

  Future<void> _handleLogin() async {
    // Basic validation
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = "Please enter both username and password";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Verify login with backend
      final isValid = await AuthService.verifyLogin(
          _usernameController.text,
          _passwordController.text
      );

      if (isValid) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        // Get status directly from SharedPreferences
        final hasCompletedAssessment = LocalStorageService.prefs.getBool('has_completed_assessment') ?? false;
        final hasTreatmentPlan = LocalStorageService.prefs.getBool('has_treatment_plan') ?? false;

        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login successful!"),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 1),
          ),
        );

        // Navigate based on status
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;

        if (!hasCompletedAssessment) {
          // Navigate to the ASSIST questionnaire
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.assist,
                (route) => false,
          );
        } else if (!hasTreatmentPlan) {
          // Navigate to treatment plan selection
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.treatmentPlans,
                (route) => false,
          );
        } else {
          // Navigate directly to dashboard
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.dashboard,
                (route) => false,
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Invalid username or password";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "An error occurred. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Same build method as original
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // App logo/icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.healing_rounded,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App name
                  Text(
                    AppStrings.appName,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // App tagline
                  Text(
                    AppStrings.appTagline,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Welcome text
                  const Text(
                    AppStrings.welcomeText,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Username field
                  AuthTextField(
                    controller: _usernameController,
                    hintText: 'Username',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  PasswordTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(),
                  ),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        if (_usernameController.text.isEmpty) {
                          setState(() {
                            _errorMessage = "Please enter your username first";
                          });
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SecurityQuestionsRecoveryScreen(
                                username: _usernameController.text,
                              ),
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Error message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Login button
                  CustomButton(
                    text: 'Login',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                    variant: ButtonVariant.gradient,
                    height: 56,
                  ),

                  const SizedBox(height: 20),

                  // Or divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.lightGrey, thickness: 1.5)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.lightGrey, thickness: 1.5)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Create account button
                  CustomButton(
                    text: 'Create an account',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateAccountScreen(),
                        ),
                      );
                    },
                    variant: ButtonVariant.outline,
                    height: 56,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}