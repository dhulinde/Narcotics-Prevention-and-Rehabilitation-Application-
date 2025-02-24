import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xFFFF9FA8DA),
      ),
      body: const Center(
        child: Text(
          'Home',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
