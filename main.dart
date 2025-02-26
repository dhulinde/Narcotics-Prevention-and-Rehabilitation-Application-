import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login & Registration UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Color scheme - from PlanSelectionScreen
  final Color primaryAccentColor = const Color(0xFFF97B62);
  final Color primaryTextColor = const Color(0xFF5A3D2B);
  final Color secondaryTextColor = Colors.black54;
  final Color backgroundGradientStart = Colors.blue.shade50;
  final Color backgroundGradientEnd = Colors.white;
  final Color decorativeShapeColor = Colors.pink.shade100;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient
          _buildGradientBackground(),

          // Decorative shapes
          _buildDecorativeShapes(),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Welcome!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Email/Username field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email or Username',
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 0,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _emailController,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: 'Enter your email/username here',
                                hintStyle: TextStyle(color: secondaryTextColor),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.person_outline, color: secondaryTextColor),
                                prefixIconConstraints: const BoxConstraints(minWidth: 40),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Password field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 0,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                hintStyle: TextStyle(color: secondaryTextColor),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.lock_outline, color: secondaryTextColor),
                                prefixIconConstraints: const BoxConstraints(minWidth: 40),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Forgot Password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Sign in button
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryAccentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      // Divider with "or"
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.black26),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'or',
                                style: TextStyle(color: Colors.black45),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.black26),
                            ),
                          ],
                        ),
                      ),

                      // Create Account button
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to Create Account screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryAccentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
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

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [backgroundGradientStart, backgroundGradientEnd],
        ),
      ),
    );
  }

  Widget _buildDecorativeShapes() {
    return Stack(
      children: [
        // Top-right decorative shape
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: decorativeShapeColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Bottom-left decorative shape
        Positioned(
          bottom: 40,
          left: -60,
          child: Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              color: decorativeShapeColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Color scheme - from PlanSelectionScreen
  final Color primaryAccentColor = const Color(0xFFF97B62);
  final Color primaryTextColor = const Color(0xFF5A3D2B);
  final Color secondaryTextColor = Colors.black54;
  final Color backgroundGradientStart = Colors.blue.shade50;
  final Color backgroundGradientEnd = Colors.white;
  final Color decorativeShapeColor = Colors.pink.shade100;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient
          _buildGradientBackground(),

          // Decorative shapes
          _buildDecorativeShapes(),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Create\nAccount',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Username field
                      Text(
                        'Username',
                        style: TextStyle(
                          fontSize: 14,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _usernameController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'enter your username here',
                            hintStyle: TextStyle(color: secondaryTextColor),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.person_outline, color: secondaryTextColor),
                            prefixIconConstraints: const BoxConstraints(minWidth: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email field
                      Text(
                        'Email (optional)',
                        style: TextStyle(
                          fontSize: 14,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _emailController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'someone@gmail.com',
                            hintStyle: TextStyle(color: secondaryTextColor),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.email_outlined, color: secondaryTextColor),
                            prefixIconConstraints: const BoxConstraints(minWidth: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password field
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 14,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: TextStyle(color: secondaryTextColor),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.lock_outline, color: secondaryTextColor),
                            prefixIconConstraints: const BoxConstraints(minWidth: 40),
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Navigation Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back button
                          Container(
                            width: 100,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                // Go back to login screen
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryAccentColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: const Icon(Icons.arrow_back),
                            ),
                          ),

                          // Next button
                          Container(
                            width: 100,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                // Implement next step of registration
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryAccentColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
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

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [backgroundGradientStart, backgroundGradientEnd],
        ),
      ),
    );
  }

  Widget _buildDecorativeShapes() {
    return Stack(
      children: [
        // Top-right decorative shape
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: decorativeShapeColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Bottom-left decorative shape
        Positioned(
          bottom: 40,
          left: -60,
          child: Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              color: decorativeShapeColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}