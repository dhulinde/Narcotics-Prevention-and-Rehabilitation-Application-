// features/menu/screens/menu_screen.dart
import 'package:flutter/material.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../config/constants.dart';
import '../../../config/routes.dart';
import '../../chat_bot/screens/chat_bot_screen.dart';
import '../../mood_tracker/screens/mood_tracker_screen.dart';
import '../widgets/menu_option.dart';
import '../../resources/screens/resources_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  // Handle logout
  void _handleLogout(BuildContext context) {
    // Show logout confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear logged in status but keep onboarding and screening flags
              LocalStorageService.setLoggedIn(false);

              // Close the dialog
              Navigator.pop(context);

              // Navigate back to welcome/login screen and remove all routes from stack
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.welcome,
                    (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 16),
                  // User info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'NARA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Menu options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  // Features section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      'FEATURES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  MenuOption(
                    icon: Icons.check_circle_outline,
                    title: 'Daily Tasks',
                    onTap: () {
                      // Navigate to the home tab
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.dashboard,
                      );
                    },
                  ),
                  MenuOption(
                    icon: Icons.mood,
                    title: 'Mood Tracker',
                    onTap: () {
                      // Navigate to resources screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MoodTrackerScreen(),
                        ),
                      );
                    },
                  ),
                  MenuOption(
                    icon: Icons.chat_bubble_outline,
                    title: 'Recovery Assistant',
                    onTap: () {
                      // Navigate to resources screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatBotScreen(),
                        ),
                      );
                    },
                  ),
                  MenuOption(
                    icon: Icons.menu_book_outlined,
                    title: 'Resources',
                    onTap: () {
                      // Navigate to resources screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResourcesScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 32, thickness: 1),

                  // Logout option
                  MenuOption(
                    icon: Icons.logout,
                    title: 'Logout',
                    color: Colors.red,
                    onTap: () => _handleLogout(context),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}