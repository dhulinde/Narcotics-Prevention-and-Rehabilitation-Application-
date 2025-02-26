import 'package:flutter/material.dart';
import 'constants.dart';
import 'register_screen.dart';
import 'security_question_recovery_screen.dart';
import 'user_data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundDecoration(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome!',
                        style: kTitleStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 60),
                      _buildUsernameField(),
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                      _buildForgotPassword(),
                      const SizedBox(height: 30),
                      buildButton(
                        text: 'Sign in',
                        onPressed: _signIn,
                      ),
                      const SizedBox(height: 20),
                      _buildDivider(),
                      const SizedBox(height: 20),
                      buildButton(
                        text: 'Create Account',
                        onPressed: _navigateToRegister,
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextField(
      controller: _usernameController,
      keyboardType: TextInputType.emailAddress,
      decoration: textFieldDecoration(
        hintText: 'enter your email/username here',
        prefixIcon: Icons.person,
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

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _navigateToForgotPassword,
        child: const Text(
          'Forgot Password?',
          style: kLinkTextStyle,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'or',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  void _signIn() {
    // Validate inputs
    if (_usernameController.text.isEmpty) {
      _showErrorSnackBar('Please enter your username');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showErrorSnackBar('Please enter your password');
      return;
    }

    // Check if a user account exists
    if (UserData().username == null) {
      _showErrorSnackBar('No account found. Please register first.');
      return;
    }

    // Check if username and password match
    if (_usernameController.text != UserData().username ||
        _passwordController.text != UserData().password) {
      _showErrorSnackBar('Invalid username or password');
      return;
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login successful!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // In a real app, you would navigate to the main content screen here
    print('User logged in: ${UserData().username}');
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  void _navigateToForgotPassword() {
    // Check if a user account exists before allowing password reset
    if (UserData().username == null) {
      _showErrorSnackBar('No account found. Please register first.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SecurityQuestionRecoveryScreen(),
      ),
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