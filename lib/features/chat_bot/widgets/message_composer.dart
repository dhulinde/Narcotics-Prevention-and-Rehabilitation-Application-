import 'package:flutter/material.dart';
import '../../../config/constants.dart';

class MessageComposer extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSubmit;
  final bool isLoading;

  const MessageComposer({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 5,
              minLines: 1,
              enabled: !widget.isLoading,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: AppColors.mediumGrey),
                filled: true,
                fillColor: AppColors.lightGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (value) {
                if (value.isNotEmpty && !widget.isLoading) {
                  widget.onSubmit(value);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _hasText && !widget.isLoading
                  ? AppColors.chatAccent
                  : AppColors.lightGrey,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.mediumGrey,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              color: _hasText && !widget.isLoading
                  ? Colors.white
                  : AppColors.mediumGrey,
              onPressed: _hasText && !widget.isLoading
                  ? () {
                      final message = widget.controller.text;
                      if (message.isNotEmpty) {
                        widget.onSubmit(message);
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
