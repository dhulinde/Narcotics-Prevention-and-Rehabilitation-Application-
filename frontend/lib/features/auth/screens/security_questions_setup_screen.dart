// features/auth/screens/security_questions_setup_screen.dart
import 'package:flutter/material.dart';
import '../widgets/auth_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../config/constants.dart';
import '../../../core/services/api_data_service.dart';
import '../../../core/models/user_model.dart';
import 'welcome_screen.dart';

class SecurityQuestionsSetupScreen extends StatefulWidget {
  final String username;
  final String email;
  final String password;

  const SecurityQuestionsSetupScreen({
    Key? key,
    required this.username,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  State<SecurityQuestionsSetupScreen> createState() => _SecurityQuestionsSetupScreenState();
}

class _SecurityQuestionsSetupScreenState extends State<SecurityQuestionsSetupScreen> {
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _customQuestionController = TextEditingController();
  String? _selectedQuestion;
  bool _isCustomQuestion = false;
  String? _errorMessage;
  bool _isLoading = false;

  final List<String> _securityQuestions = [
    'Select a question',
    'What was your first pet\'s name?',
    'What is your mother\'s maiden name?',
    'What was the name of your first school?',
    'What city were you born in?',
    'What was the make of your first car?',
    'What is your favorite book?',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    _selectedQuestion = _securityQuestions[0];
  }

  @override
  void dispose() {
    _answerController.dispose();
    _customQuestionController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    // Validate security question setup
    if (_selectedQuestion == _securityQuestions[0]) {
      setState(() {
        _errorMessage = "Please select a security question";
      });
      return;
    }

    if (_isCustomQuestion && _customQuestionController.text.isEmpty) {
      setState(() {
        _errorMessage = "Please enter a custom security question";
      });
      return;
    }

    if (_answerController.text.isEmpty) {
      setState(() {
        _errorMessage = "Please provide an answer to your security question";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create user data object
      final userData = UserData(
        username: widget.username,
        email: widget.email,
        password: widget.password,
        securityQuestion: _isCustomQuestion
            ? _customQuestionController.text
            : _selectedQuestion!,
        securityAnswer: _answerController.text.toLowerCase().trim(),
      );

      // Save user data to backend
      final success = await AuthService.saveUser(userData);

      if (!success) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to create account. Please try again.";
        });
        return;
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account created successfully!"),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });

      // Navigate to welcome/login screen after successful account creation
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomeScreen(),
          ),
              (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "An error occurred while creating your account. Please check your internet connection and try again.";
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
          AppStrings.securityQuestionText,
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
          onTap: () {
            // Dismiss keyboard and dropdown on tap
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Description
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: const Text(
                      'For security purposes, please set up a security question and answer. This will help you recover your account if you forget your password.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Question dropdown
                  _buildSecurityQuestionDropdown(),

                  // Custom question field (if selected)
                  if (_isCustomQuestion) ...[
                    const SizedBox(height: 20),
                    AuthTextField(
                      controller: _customQuestionController,
                      hintText: 'Enter your custom question',
                      textInputAction: TextInputAction.next,
                      labelText: 'Custom Question',
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Answer field
                  AuthTextField(
                    controller: _answerController,
                    hintText: 'Your answer',
                    textInputAction: TextInputAction.done,
                    labelText: 'Answer',
                    onSubmitted: (_) => _createAccount(),
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

                  // Create account button
                  CustomButton(
                    text: 'Create Account',
                    onPressed: _createAccount,
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

  Widget _buildSecurityQuestionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Security Question',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(
              color: Colors.transparent,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedQuestion,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primary,
              ),
              elevation: 1,
              isExpanded: true,
              dropdownColor: Colors.white,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedQuestion = newValue;
                  _isCustomQuestion = newValue == 'Custom';
                });
              },
              items: _securityQuestions
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: value == 'Select a question'
                          ? AppColors.mediumGrey
                          : AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}