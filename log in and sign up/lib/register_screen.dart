import 'package:flutter/material.dart';
import 'constants.dart';
import 'security_question_setup_screen.dart';
import 'user_data.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildScreenLayout(
      context: context,
      title: 'Create\nAccount',
      children: [
        const Text('Username', style: kLabelStyle),
        const SizedBox(height: 10),
        _buildUsernameField(),
        const SizedBox(height: 20),

        const Text('Email(optional)', style: kLabelStyle),
        const SizedBox(height: 10),
        _buildEmailField(),
        const SizedBox(height: 20),

        const Text('Password', style: kLabelStyle),
        const SizedBox(height: 10),
        _buildPasswordField(),
        const SizedBox(height: 20),

        const Text('Confirm Password', style: kLabelStyle),
        const SizedBox(height: 10),
        _buildConfirmPasswordField(),
        const SizedBox(height: 40),

        buildButton(
          text: 'Next',
          onPressed: _navigateToSecurityQuestions,
          width: 200,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildUsernameField() {
    return TextField(
      controller: _usernameController,
      decoration: textFieldDecoration(
        hintText: 'enter your username here',
        prefixIcon: Icons.person,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: textFieldDecoration(
        hintText: 'someone@gmail.com',
        prefixIcon: Icons.email,
      ),
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

  void _navigateToSecurityQuestions() {
    if (_validateForm()) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SecurityQuestionSetupScreen(
            username: _usernameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          ),
        ),
      );
    }
  }

  bool _validateForm() {
    // Username validation
    if (_usernameController.text.isEmpty) {
      _showErrorSnackBar('Username is required');
      return false;
    }

    if (_usernameController.text.length < 3) {
      _showErrorSnackBar('Username must be at least 3 characters long');
      return false;
    }

    // Email validation (optional)
    if (_emailController.text.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(_emailController.text)) {
        _showErrorSnackBar('Please enter a valid email address');
        return false;
      }
    }

    // Password validation
    if (_passwordController.text.isEmpty) {
      _showErrorSnackBar('Password is required');
      return false;
    }

    if (_passwordController.text.length < 6) {
      _showErrorSnackBar('Password must be at least 6 characters long');
      return false;
    }

    // Confirm password validation
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Passwords do not match');
      return false;
    }

    // Check if username already exists
    if (UserData().username == _usernameController.text) {
      _showErrorSnackBar('Username already exists. Please choose another username.');
      return false;
    }

    return true;
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