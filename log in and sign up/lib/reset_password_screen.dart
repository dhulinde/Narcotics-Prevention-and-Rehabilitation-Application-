import 'package:flutter/material.dart';
import 'constants.dart';
import 'login_screen.dart';
import 'user_data.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildScreenLayout(
      context: context,
      title: 'Reset\nPassword',
      subtitle: 'Enter your new password.',
      children: [
        const Text('Password', style: kLabelStyle),
        const SizedBox(height: 10),
        _buildPasswordField(),
        const SizedBox(height: 20),
        const Text('Confirm Password', style: kLabelStyle),
        const SizedBox(height: 10),
        _buildConfirmPasswordField(),
        const SizedBox(height: 50),
        buildButton(
          text: 'Reset',
          onPressed: _resetPassword,
          width: 120,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: textFieldDecoration(
        hintText: '*******',
        prefixIcon: Icons.lock,
      ).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      decoration: textFieldDecoration(
        hintText: '*******',
        prefixIcon: Icons.lock,
      ).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
      ),
    );
  }

  void _resetPassword() {
    // Validate passwords
    if (_passwordController.text.isEmpty) {
      _showErrorSnackBar('Please enter a new password');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showErrorSnackBar('Password must be at least 6 characters long');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Passwords do not match');
      return;
    }

    // Check if a user account exists
    if (UserData().username == null) {
      _showErrorSnackBar('No account found. Please register first.');
      return;
    }

    // Update the password in our simulated storage
    UserData().updatePassword(_passwordController.text);

    // Print for debugging
    print('Password reset successfully for user: ${UserData().username}');
    print('New password: ${_passwordController.text}');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate back to login screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false, // Remove all previous routes
    );
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