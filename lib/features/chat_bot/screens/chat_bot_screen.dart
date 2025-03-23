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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          AppStrings.recoveryAssistantTitle,
          style: TextStyle(
            color: AppColors.chatAccent,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.chatAccent,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Chat options popup menu
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.chatAccent,
            ),
            onSelected: (value) {
              if (value == 'clear') {
                _clearChatHistory();
              } else if (value == 'restore') {
                _restoreHistory();
              } else if (value == 'refresh') {
                _loadChatHistory();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.textPrimary),
                    SizedBox(width: 8),
                    Text('Clear Chat Display'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'restore',
                enabled: _isHistoryCleared,
                child: Row(
                  children: [
                    Icon(Icons.restore,
                        color: _isHistoryCleared
                            ? AppColors.textPrimary
                            : AppColors.mediumGrey),
                    const SizedBox(width: 8),
                    const Text('Restore History'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: AppColors.textPrimary),
                    SizedBox(width: 8),
                    Text('Refresh from Server'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat header with description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.chatAccent.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const Text(
              "I'm your recovery assistant, here to support you through challenges and celebrate your progress. How can I help you today?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),

          // History status banner when cleared
          if (_isHistoryCleared)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.amber.withOpacity(0.2),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.amber[800]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chat display is temporarily cleared. Your history is still saved.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[800],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _restoreHistory,
                    child: const Text(
                      'RESTORE',
                      style: TextStyle(
                        color: AppColors.chatAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Chat messages
          Expanded(
            child: !_initialLoadComplete
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.chatAccent,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return ChatMessageWidget(message: _messages[index]);
                    },
                  ),
          ),

          // Loading indicator when bot is "typing"
          if (_isLoading && _initialLoadComplete)
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.chatAccent.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Typing...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          // Suggested messages list
          if (_initialLoadComplete &&
              _messages.isNotEmpty &&
              _messages.length < 3)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  "How can I manage cravings?",
                  "What helps with anxiety?",
                  "Tips for better sleep?",
                  "How to handle triggers?",
                  "Motivation strategies?"
                ].map((message) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => _handleSubmitted(message),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.mediumGrey.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          message,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Message composer
          MessageComposer(
            controller: _messageController,
            onSubmit: _handleSubmitted,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
