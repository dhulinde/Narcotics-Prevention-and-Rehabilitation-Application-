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

@override
void initState() {
  super.initState();
  _loadChatHistory();
}

@override
void dispose() {
  _messageController.dispose();
  _scrollController.dispose();
  super.dispose();
}

Future<void> _loadChatHistory() async {
  setState(() {
    _isLoading = true;
    _isHistoryCleared = false;
  });

  try {
    final apiService = ApiDataService();
    final messages = await apiService.loadChatHistory();

    setState(() {
      _messages = messages;
      _savedHistory = List.from(messages);
      _isLoading = false;
      _initialLoadComplete = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  } catch (e) {
    print('Error loading chat history: $e');
    setState(() {
      _messages = [
        ChatMessage(
          text: "Hello! I'm your recovery assistant. How can I help you today?",
          isUserMessage: false,
        )
      ];
      _savedHistory = List.from(_messages);
      _isLoading = false;
      _initialLoadComplete = true;
    });
  }
}

void _clearChatHistory() {
  if (!_isHistoryCleared) {
    _savedHistory = List.from(_messages);
  }

  setState(() {
    _messages = [
      ChatMessage(
        text:
            "Chat history has been cleared temporarily. You can continue chatting or restore history.",
        isUserMessage: false,
      )
    ];
    _isHistoryCleared = true;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text(
          'Chat display cleared. Your history is still saved on the server.'),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Restore',
        onPressed: _restoreHistory,
      ),
    ),
  );
}

void _restoreHistory() {
  if (_isHistoryCleared) {
    setState(() {
      _messages = List.from(_savedHistory);
      _isHistoryCleared = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chat history restored'),
        duration: Duration(seconds: 2),
      ),
    );
  } else {
    _loadChatHistory();
  }
}
