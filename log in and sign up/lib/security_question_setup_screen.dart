import 'package:flutter/material.dart';
import 'constants.dart';
import 'login_screen.dart';
import 'user_data.dart';

class SecurityQuestionSetupScreen extends StatefulWidget {
  final String username;
  final String email;
  final String password;

  const SecurityQuestionSetupScreen({
    Key? key,
    required this.username,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  State<SecurityQuestionSetupScreen> createState() => _SecurityQuestionSetupScreenState();
}

class _SecurityQuestionSetupScreenState extends State<SecurityQuestionSetupScreen> {
  String _selectedQuestion = 'Please select your question';
  final TextEditingController _answerController = TextEditingController();
  bool _isDropdownOpen = false;

  final List<String> _securityQuestions = [
    'What is your pet\'s name?',
    'What\'s you favourite colour?',
    'What is your lucky number?',
    'Type your Question...',
  ];

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
      subtitle: 'For security purposes, please fill out these security questions and remember them,in case you forgot your password or ID',
      children: [
        _buildSecurityQuestionDropdown(),
        const SizedBox(height: 20),
        _buildAnswerField(),
        const SizedBox(height: 50),
        buildButton(
          text: 'Create Account',
          onPressed: _createAccount,
          width: 250,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSecurityQuestionDropdown() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isDropdownOpen = !_isDropdownOpen;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedQuestion,
                    style: TextStyle(
                      color: _selectedQuestion == 'Please select your question'
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
                Icon(
                  _isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        if (_isDropdownOpen)
          Container(
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _securityQuestions.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedQuestion = _securityQuestions[index];
                      _isDropdownOpen = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    color: _securityQuestions[index] == _selectedQuestion
                        ? kLightBlue
                        : Colors.white,
                    child: Text(
                      _securityQuestions[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
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

  void _createAccount() {
    // Validate security question and answer
    if (_selectedQuestion == 'Please select your question') {
      _showErrorSnackBar('Please select a security question');
      return;
    }

    if (_answerController.text.isEmpty) {
      _showErrorSnackBar('Please provide an answer to your security question');
      return;
    }

    // Save user data to our simulated storage
    UserData().saveRegistrationData(
      username: widget.username,
      email: widget.email,
      password: widget.password,
      securityQuestion: _selectedQuestion,
      securityAnswer: _answerController.text,
    );

    // Print data for debugging
    print('Creating account with:');
    print('Username: ${widget.username}');
    print('Email: ${widget.email}');
    print('Security Question: $_selectedQuestion');
    print('Security Answer: ${_answerController.text}');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate to login screen
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
      ),
    );
  }
}