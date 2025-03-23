import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/chat_message_model.dart'; // Importing the model for chat messages
import '../../../config/constants.dart'; // Importing constants like colors

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage
      message; // ChatMessage object to display the message content

  const ChatMessageWidget({
    super.key,
    required this.message, // The message is passed into this widget
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: message.isUserMessage
            ? 64
            : 16, // Adjust padding for user vs. bot message
        right: message.isUserMessage
            ? 16
            : 64, // Adjust padding for user vs. bot message
      ),
      child: Column(
        crossAxisAlignment: message.isUserMessage
            ? CrossAxisAlignment.end // Align user messages to the right
            : CrossAxisAlignment.start, // Align bot messages to the left
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12), // Padding inside the message container
            decoration: BoxDecoration(
              color: message.isUserMessage
                  ? AppColors.chatAccent
                  : Colors.white, // Change color based on user/bot
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: message.isUserMessage
                    ? const Radius.circular(
                        20) // Rounded bottom-left corner for user messages
                    : const Radius.circular(
                        0), // No rounded bottom-left corner for bot messages
                bottomRight: message.isUserMessage
                    ? const Radius.circular(
                        0) // No rounded bottom-right corner for user messages
                    : const Radius.circular(
                        20), // Rounded bottom-right corner for bot messages
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(0.05), // Subtle shadow for depth
                  blurRadius: 5, // Amount of blur for the shadow
                  offset: const Offset(0, 2), // Slight offset for shadow
                ),
              ],
            ),
            child: Text(
              message.text, // Display the message text
              style: TextStyle(
                color: message.isUserMessage
                    ? Colors.white // White text for user messages
                    : AppColors
                        .textPrimary, // Primary text color for bot messages
                fontSize: 16, // Font size for the message text
                height: 1.4, // Line height for better readability
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 4, left: 4, right: 4), // Padding for the timestamp
            child: Text(
              DateFormat('h:mm a').format(
                  message.timestamp), // Format the timestamp (e.g., 4:30 PM)
              style: const TextStyle(
                fontSize: 12, // Font size for the timestamp
                color: AppColors
                    .textSecondary, // Secondary text color for the timestamp
              ),
            ),
          ),
        ],
      ),
    );
  }
}
