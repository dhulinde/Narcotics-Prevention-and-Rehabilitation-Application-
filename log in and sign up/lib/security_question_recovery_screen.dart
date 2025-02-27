import 'package:flutter/material.dart';
import 'constants.dart';
import 'reset_password_screen.dart';
import 'user_data.dart';

class SecurityQuestionRecoveryScreen extends StatefulWidget {
  const SecurityQuestionRecoveryScreen({Key? key}) : super(key: key);

  @override
  State<SecurityQuestionRecoveryScreen> createState() => _SecurityQuestionRecoveryScreenState();
}

class _SecurityQuestionRecoveryScreenState extends State<SecurityQuestionRecoveryScreen> {
  final TextEditingController _answerController = TextEditingController();
  String? _securityQuestion;
  int _wrongAttempts = 0;
  final int _maxWrongAttempts = 3;

  @override
  void initState() {
    super.initState();
    // Get the user's security question from our simulated storage
    _securityQuestion = UserData().securityQuestion;

    // If no security question is found, use a default (this shouldn't happen in a real app)
    if (_securityQuestion == null) {
      _securityQuestion = "No security question found. Please register first.";
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildScreenLayout(
      context: context,
      title: 'Security\nQuestions',
      subtitle: 'To recover your account, please answer the security questions you set up when creating your account.',
      children: [
        _buildQuestionDisplay(),
        const SizedBox(height: 20),
        _buildAnswerField(),
        const SizedBox(height: 40),
        buildButton(
          text: 'Reset Password',
          onPressed: _verifySecurityQuestion,
          width: 250,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildQuestionDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.grey),
      ),
      child: Text(
        _securityQuestion ?? '',
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }

  Widget _buildAnswerField() {
    return TextField(
      controller: _answerController,
      decoration: InputDecoration(
        hintText: 'Answer',
        hintStyle: TextStyle(color: Colors.grey[400]),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.blue, width: 1),
        ),
      ),
    );
  }

  void _verifySecurityQuestion() {
    // Check if a user account exists
    if (UserData().username == null) {
      _showErrorSnackBar('No account found. Please register first.');
      return;
    }

    // Check if the answer is empty
    if (_answerController.text.isEmpty) {
      _showErrorSnackBar('Please provide an answer');
      return;
    }

    // Verify security answer against stored answer
    bool isCorrect = UserData().validateSecurityAnswer(_answerController.text);

    if (isCorrect) {
      // Navigate to reset password screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ResetPasswordScreen(),
        ),
      );
    } else {
      _wrongAttempts++;

      // Show appropriate error message based on attempts
      if (_wrongAttempts >= _maxWrongAttempts) {
        _showErrorSnackBar('Too many wrong attempts. Please try again later.');

        // Navigate back after too many attempts
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });
      } else {
        _showErrorSnackBar(
            'Incorrect answer. ${_maxWrongAttempts - _wrongAttempts} attempts remaining.'
        );

        // Clear the text field for the next attempt
        _answerController.clear();
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}