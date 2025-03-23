// features/chat_bot/screens/chat_bot_screen.dart
import 'package:flutter/material.dart';
import '../../../core/models/chat_message_model.dart';
import '../../../config/constants.dart';
import '../../../core/services/api_data_service.dart';
import '../widgets/chat_message.dart';
import '../widgets/message_composer.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  List<ChatMessage> _savedHistory = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _initialLoadComplete = false;
  bool _isHistoryCleared = false;
}
