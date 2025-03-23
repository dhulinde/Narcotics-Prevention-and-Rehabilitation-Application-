// features/chat_bot/widgets/chat_message.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/chat_message_model.dart';
import '../../../config/constants.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: message.isUserMessage ? 64 : 16,
        right: message.isUserMessage ? 16 : 64,
      ),
      child: Column(
        crossAxisAlignment: message.isUserMessage
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  message.isUserMessage ? AppColors.chatAccent : Colors.white,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: message.isUserMessage
                    ? const Radius.circular(20)
                    : const Radius.circular(0),
                bottomRight: message.isUserMessage
                    ? const Radius.circular(0)
                    : const Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: message.isUserMessage
                    ? Colors.white
                    : AppColors.textPrimary,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Text(
              DateFormat('h:mm a').format(message.timestamp),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
