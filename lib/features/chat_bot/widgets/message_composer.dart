import 'package:flutter/material.dart';
import '../../../config/constants.dart';

class MessageComposer extends StatefulWidget {
  final TextEditingController
      controller; // Text editing controller to manage input text
  final Function(String)
      onSubmit; // Function to handle the submission of the message
  final bool isLoading; // Flag to indicate if a loading state is active

  const MessageComposer({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.isLoading = false, // Default is loading state to false
  });

  @override
  State<MessageComposer> createState() =>
      _MessageComposerState(); // Create the state for this widget
}

class _MessageComposerState extends State<MessageComposer> {
  bool _hasText = false; // Track whether the text field contains any text

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(
        _onTextChanged); // Listen to text changes in the controller
  }

  @override
  void dispose() {
    widget.controller
        .removeListener(_onTextChanged); // Remove the listener when disposed
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget
        .controller.text.isNotEmpty; // Check if the text field is not empty
    if (hasText != _hasText) {
      // If text availability has changed, update the state
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12), // Padding for the container
      decoration: BoxDecoration(
        color: Colors.white, // White background color
        boxShadow: [
          // Add a subtle shadow effect
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5), // Shadow is below the container
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.end, // Align children at the bottom
        children: [
          // Text field
          Expanded(
            child: TextField(
              controller:
                  widget.controller, // Controller for the text input field
              textCapitalization: TextCapitalization
                  .sentences, // Auto capitalize first letter of sentences
              maxLines: 5, // Allow multiple lines
              minLines: 1, // Minimum height of the text field
              enabled: !widget
                  .isLoading, // Disable the text field if loading is true
              decoration: InputDecoration(
                hintText: 'Type a message...', // Placeholder text
                hintStyle: const TextStyle(
                    color: AppColors.mediumGrey), // Style for the hint text
                filled: true, // Allow filling the background with color
                fillColor:
                    AppColors.lightGrey, // Background color of the text field
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24), // Rounded corners
                  borderSide: BorderSide.none, // No border line
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10, // Padding inside the text field
                ),
              ),
              textInputAction:
                  TextInputAction.send, // Set the action button to "Send"
              onSubmitted: (value) {
                if (value.isNotEmpty && !widget.isLoading) {
                  // Only submit if there is text and not loading
                  widget.onSubmit(
                      value); // Call the onSubmit function with the text value
                }
              },
            ),
          ),

          const SizedBox(
              width: 8), // Space between the text field and send button

          // Send button
          Container(
            decoration: BoxDecoration(
              color: _hasText &&
                      !widget
                          .isLoading // Highlight send button when there is text and not loading
                  ? AppColors.chatAccent
                  : AppColors
                      .lightGrey, // Default to light grey if no text or loading
              shape: BoxShape.circle, // Round shape for the send button
            ),
            child: IconButton(
              icon: widget
                      .isLoading // Show a loading indicator if isLoading is true
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors
                            .mediumGrey, // Color for the loading indicator
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded), // Show the send icon otherwise
              color: _hasText &&
                      !widget
                          .isLoading // White icon color if text is present and not loading
                  ? Colors.white
                  : AppColors
                      .mediumGrey, // Grey icon color if no text or loading
              onPressed: _hasText &&
                      !widget
                          .isLoading // Enable the button only if there's text and not loading
                  ? () {
                      final message =
                          widget.controller.text; // Get the message text
                      if (message.isNotEmpty) {
                        // If message is not empty
                        widget.onSubmit(message); // Submit the message
                      }
                    }
                  : null, // Disable the button if conditions are not met
            ),
          ),
        ],
      ),
    );
  }
}
