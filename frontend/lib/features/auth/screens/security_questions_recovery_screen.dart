// features/auth/screens/security_questions_recovery_screen.dart
import 'package:flutter/material.dart';
import '../widgets/auth_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../config/constants.dart';
import '../../../core/services/api_data_service.dart';
import '../../../core/models/user_model.dart';
import 'reset_password_screen.dart';

class SecurityQuestionsRecoveryScreen extends StatefulWidget {
  final String username;

  const SecurityQuestionsRecoveryScreen({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  State<SecurityQuestionsRecoveryScreen> createState() => _SecurityQuestionsRecoveryScreenState();
}

class _SecurityQuestionsRecoveryScreenState extends State<SecurityQuestionsRecoveryScreen> {
  final TextEditingController _answerController = TextEditingController();
  String? _userQuestion;
  String? _errorMessage;
  bool _isLoading = false;
  UserData? _userData;

  @override
  void initState() {
    super.initState();
    // Fetch the user's security question from the database
    _fetchUserSecurityQuestion();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  // Fetch the user's security question
  Future<void> _fetchUserSecurityQuestion() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if username exists before trying to get security question
      final usernameExists = await AuthService.usernameExists(widget.username);

      if (!usernameExists) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Username not found. Please check your username.";
        });
        return;
      }

      // Get the security question using the reset_password_request endpoint
      final response = await AuthService.getSecurityQuestion(widget.username);

      if (response == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Unable to retrieve security question. Please try again.";
        });
        return;
      }

      // Store the user's security question from the response
      _userQuestion = response['security_question'];

      print("Retrieved security question: $_userQuestion");

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "An error occurred. Please check your internet connection and try again.";
      });
    }
  }

  // Verify the security answer
  Future<void> _verifySecurityAnswer() async {
    if (_answerController.text.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your answer";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Verify the security answer using the API
      final result = await AuthService.verifySecurityAnswer(
        widget.username,
        _answerController.text,
      );

      if (result) {
        setState(() {
          _isLoading = false;
        });

        // Show success message
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Security answer verified!"),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 1),
          ),
        );

        // Navigate to reset password screen
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(username: widget.username),
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Incorrect answer. Please try again.";
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
          'Password Recovery',
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Recovery icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.password_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: const Text(
                      'To reset your password, please answer the security question you set up when creating your account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Security question
                  _isLoading && _userQuestion == null
                      ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Security Question:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _userQuestion ?? "No security question found for this user",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Answer field
                  AuthTextField(
                    controller: _answerController,
                    hintText: 'Your answer',
                    textInputAction: TextInputAction.done,
                    labelText: 'Answer',
                    onSubmitted: (_) => _verifySecurityAnswer(),
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

                  // Verify button
                  CustomButton(
                    text: 'Verify Answer',
                    onPressed: _userQuestion == null ? () {} : _verifySecurityAnswer,
                    isLoading: _isLoading,
                    variant: _userQuestion == null ? ButtonVariant.outline : ButtonVariant.gradient,
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