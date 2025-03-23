// features/auth/screens/create_account_screen.dart
import 'package:flutter/material.dart';
import '../widgets/auth_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../config/constants.dart';
import '../../../core/services/api_data_service.dart';
import '../../../core/utils/validators.dart';
import 'security_questions_setup_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _validateAndContinue() async {
    // Reset error message
    setState(() {
      _errorMessage = null;
    });

    // Validate inputs
    final usernameError = Validators.validateUsername(_usernameController.text);
    if (usernameError != null) {
      setState(() {
        _errorMessage = usernameError;
      });
      return;
    }

    if (_emailController.text.isNotEmpty) {
      final emailError = Validators.validateEmail(_emailController.text);
      if (emailError != null) {
        setState(() {
          _errorMessage = emailError;
        });
        return;
      }
    }

    final passwordError = Validators.validatePassword(_passwordController.text);
    if (passwordError != null) {
      setState(() {
        _errorMessage = passwordError;
      });
      return;
    }

    final passwordsMatchError = Validators.validatePasswordsMatch(
        _passwordController.text,
        _confirmPasswordController.text
    );
    if (passwordsMatchError != null) {
      setState(() {
        _errorMessage = passwordsMatchError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Check if username already exists via backend API
    try {
      final usernameExists = await AuthService.usernameExists(_usernameController.text);

      if (usernameExists) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Username already exists. Please choose another.";
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });

      // If all validations pass, navigate to security questions setup
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SecurityQuestionsSetupScreen(
              username: _usernameController.text,
              email: _emailController.text,
              password: _passwordController.text,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "An error occurred. Please check your internet connection and try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build method remains the same
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          AppStrings.createAccountText,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instructions text
                  const Text(
                    'Create your account to start your recovery journey',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Username field
                  AuthTextField(
                    controller: _usernameController,
                    hintText: 'Username',
                    textInputAction: TextInputAction.next,
                    labelText: 'Username',
                  ),
                  const SizedBox(height: 20),

                  // Email field
                  AuthTextField(
                    controller: _emailController,
                    hintText: 'Email (Optional)',
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    labelText: 'Email',
                  ),
                  const SizedBox(height: 20),

                  // Password field
                  PasswordTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    textInputAction: TextInputAction.next,
                    labelText: 'Password',
                  ),
                  const SizedBox(height: 20),

                  // Confirm password field
                  PasswordTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    textInputAction: TextInputAction.done,
                    labelText: 'Confirm Password',
                    onSubmitted: (_) => _validateAndContinue(),
                  ),

                  // Password requirements
                  const SizedBox(height: 12),
                  const Text(
                    'Password must be at least 6 characters.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  // Error message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
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

                  const SizedBox(height: 32),

                  // Continue button
                  CustomButton(
                    text: 'Continue',
                    onPressed: _validateAndContinue,
                    isLoading: _isLoading,
                    variant: ButtonVariant.gradient,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}