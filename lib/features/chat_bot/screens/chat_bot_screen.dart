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
  List<ChatMessage> _savedHistory = []; // To store the history when cleared
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _initialLoadComplete = false;
  bool _isHistoryCleared = false;

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
      // Use ApiDataService to load chat history
      final apiService = ApiDataService();
      final messages = await apiService.loadChatHistory();

      setState(() {
        _messages = messages;
        _savedHistory = List.from(messages); // Save a copy
        _isLoading = false;
        _initialLoadComplete = true;
      });

      // Scroll to bottom after messages are loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print('Error loading chat history: $e');

      setState(() {
        // Add a default message if error
        _messages = [
          ChatMessage(
            text:
                "Hello! I'm your recovery assistant. How can I help you today?",
            isUserMessage: false,
          )
        ];
        _savedHistory = List.from(_messages); // Save a copy
        _isLoading = false;
        _initialLoadComplete = true;
      });
    }
  }

  void _clearChatHistory() {
    // Save current messages before clearing
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

    // Show a snackbar to confirm
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

      // Scroll to bottom after restoring
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      // Show a snackbar to confirm
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat history restored'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // If not cleared, reload from server
      _loadChatHistory();
    }
  }

  Future<void> _handleSubmitted(String text) async {
    _messageController.clear();

    if (text.trim().isEmpty) return;

    // Add user message to UI
    final userMessage = ChatMessage(
      text: text,
      isUserMessage: true,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    // Scroll to bottom after message is added
    _scrollToBottom();

    try {
      // Get bot response using ApiDataService
      final apiService = ApiDataService();

      // Send the chat message
      final botMessage = await apiService.sendChatMessage(text);

      // Only add the bot message to the UI
      setState(() {
        _messages.add(botMessage);
        _isLoading = false;
        _isHistoryCleared =
            false; // We're adding new messages, so we're no longer in cleared state
      });

      // Scroll again after bot response
      _scrollToBottom();
    } catch (e) {
      print('Error getting bot response: $e');

      // Create fallback response
      final botMessage = ChatMessage(
        text:
            "I'm having trouble connecting right now. Let's try again in a moment.",
        isUserMessage: false,
      );

      setState(() {
        _messages.add(botMessage);
        _isLoading = false;
      });

      // Scroll again after fallback response
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  