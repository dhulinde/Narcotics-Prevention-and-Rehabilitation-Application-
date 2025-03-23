import 'package:flutter/material.dart';
import '../../../core/models/chat_message_model.dart'; // Import the chat message model
import '../../../config/constants.dart'; // Import constants (colors, strings, etc.)
import '../../../core/services/api_data_service.dart'; // API service to fetch/send chat data
import '../widgets/chat_message.dart'; // Widget to display chat messages
import '../widgets/message_composer.dart'; // Widget to compose and send messages

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key}); // Constructor for ChatBotScreen

  @override
  State<ChatBotScreen> createState() =>
      _ChatBotScreenState(); // Creating the state
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController =
      TextEditingController(); // Controller to handle message input
  List<ChatMessage> _messages = []; // List to store chat messages
  List<ChatMessage> _savedHistory =
      []; // To store chat history before clearing it
  final ScrollController _scrollController =
      ScrollController(); // Scroll controller for message list
  bool _isLoading = false; // Flag to track if the bot is typing
  bool _initialLoadComplete =
      false; // Flag to check if initial chat history has been loaded
  bool _isHistoryCleared = false; // Flag to track if chat history is cleared

  @override
  void initState() {
    super.initState();
    _loadChatHistory(); // Load chat history when screen is initialized
  }

  @override
  void dispose() {
    _messageController
        .dispose(); // Dispose of the controller when the screen is disposed
    _scrollController.dispose(); // Dispose of the scroll controller
    super.dispose();
  }

  Future<void> _loadChatHistory() async {
    setState(() {
      _isLoading = true; // Set loading to true while fetching history
      _isHistoryCleared = false; // Reset history cleared flag
    });

    try {
      final apiService = ApiDataService(); // API service to fetch data
      final messages =
          await apiService.loadChatHistory(); // Fetching chat history

      setState(() {
        _messages = messages; // Assign fetched messages to _messages
        _savedHistory = List.from(
            messages); // Save a copy of messages in case history is cleared
        _isLoading = false; // Stop loading indicator
        _initialLoadComplete = true; // Mark initial load as complete
      });

      // Scroll to bottom after messages are loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print('Error loading chat history: $e');

      setState(() {
        // Add a default message if error occurs
        _messages = [
          ChatMessage(
            text:
                "Hello! I'm your recovery assistant. How can I help you today?", // Fallback message
            isUserMessage: false,
          )
        ];
        _savedHistory =
            List.from(_messages); // Save the default message as history
        _isLoading = false; // Stop loading indicator
        _initialLoadComplete = true; // Mark initial load as complete
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
          isUserMessage: false, // Display system message
        )
      ];
      _isHistoryCleared = true; // Mark chat history as cleared
    });

    // Show a snackbar to confirm the action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'Chat display cleared. Your history is still saved on the server.'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Restore',
          onPressed: _restoreHistory, // Action to restore history
        ),
      ),
    );
  }

  void _restoreHistory() {
    if (_isHistoryCleared) {
      setState(() {
        _messages = List.from(_savedHistory); // Restore saved history
        _isHistoryCleared = false; // Mark history as restored
      });

      // Scroll to bottom after restoring history
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      // Show a snackbar to confirm history restoration
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat history restored'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // If history wasn't cleared, reload it from the server
      _loadChatHistory();
    }
  }

  Future<void> _handleSubmitted(String text) async {
    _messageController.clear(); // Clear the message input field

    if (text.trim().isEmpty) return; // Don't send if the message is empty

    // Add user message to the UI
    final userMessage = ChatMessage(
      text: text,
      isUserMessage: true, // Mark the message as from the user
    );

    setState(() {
      _messages.add(userMessage); // Add user message to the chat
      _isLoading = true; // Set loading state while waiting for bot's response
    });

    // Scroll to the bottom after user message
    _scrollToBottom();

    try {
      final apiService = ApiDataService(); // API service to fetch data

      // Send the chat message and get the bot's response
      final botMessage = await apiService.sendChatMessage(text);

      // Only add the bot's message to the UI
      setState(() {
        _messages.add(botMessage); // Add bot response to the chat
        _isLoading = false; // Stop loading indicator
        _isHistoryCleared =
            false; // We're adding new messages, so we're no longer in cleared state
      });

      // Scroll to the bottom again after bot response
      _scrollToBottom();
    } catch (e) {
      print('Error getting bot response: $e');

      // Create fallback response if an error occurs
      final botMessage = ChatMessage(
        text:
            "I'm having trouble connecting right now. Let's try again in a moment.", // Fallback message
        isUserMessage: false,
      );

      setState(() {
        _messages.add(botMessage); // Add fallback message to the chat
        _isLoading = false; // Stop loading indicator
      });

      // Scroll to bottom after fallback response
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController
            .position.maxScrollExtent, // Scroll to the bottom of the chat
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
          AppStrings.recoveryAssistantTitle, // App title
          style: TextStyle(
            color: AppColors.chatAccent, // Accent color for title
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios, // Back button
            color: AppColors.chatAccent,
          ),
          onPressed: () =>
              Navigator.pop(context), // Action on back button press
        ),
        actions: [
          // Chat options popup menu
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert, // More options icon
              color: AppColors.chatAccent,
            ),
            onSelected: (value) {
              if (value == 'clear') {
                _clearChatHistory(); // Option to clear chat history
              } else if (value == 'restore') {
                _restoreHistory(); // Option to restore chat history
              } else if (value == 'refresh') {
                _loadChatHistory(); // Option to refresh chat history from the server
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.textPrimary),
                    SizedBox(width: 8),
                    Text(
                        'Clear Chat Display'), // Option to clear the chat display
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'restore',
                enabled: _isHistoryCleared, // Only enable if history is cleared
                child: Row(
                  children: [
                    Icon(Icons.restore,
                        color: _isHistoryCleared
                            ? AppColors.textPrimary
                            : AppColors.mediumGrey),
                    const SizedBox(width: 8),
                    const Text(
                        'Restore History'), // Option to restore the history
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: AppColors.textPrimary),
                    SizedBox(width: 8),
                    Text(
                        'Refresh from Server'), // Option to refresh chat from server
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

          // Chat messages list
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
                      return ChatMessageWidget(
                          message: _messages[index]); // Display each message
                    },
                  ),
          ),

          // Loading indicator when bot is typing
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
                    'Typing...', // Display "typing" message when the bot is typing
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
                      onTap: () => _handleSubmitted(
                          message), // Handle when a suggested message is clicked
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
            controller: _messageController, // Message input controller
            onSubmit: _handleSubmitted, // Handle message submission
            isLoading: _isLoading, // Loading state for bot
          ),
        ],
      ),
    );
  }
}
