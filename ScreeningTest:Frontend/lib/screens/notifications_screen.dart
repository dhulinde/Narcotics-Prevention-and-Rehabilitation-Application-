import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFFFF9FA8DA),
      ),
      body: const Center(
        child: Text(
          'Notifications',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}