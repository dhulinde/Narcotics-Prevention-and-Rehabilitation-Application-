// question_card.dart
import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String title;
  final Widget content;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const QuestionCard({
    super.key,
    required this.title,
    required this.content,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: backgroundColor ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }
}

class OptionQuestionCard extends QuestionCard {
  OptionQuestionCard({
    super.key,
    required super.title,
    required List<Widget> options,
  }) : super(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: options
                .map((option) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: option,
                    ))
                .toList(),
          ),
        );
}

class FrequencyQuestionCard extends QuestionCard {
  FrequencyQuestionCard({
    super.key,
    required super.title,
    required Widget frequencySelector,
    String? subtitle,
  }) : super(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null) ...[
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16,), // og 16
              ],
              frequencySelector,
            ],
          ),
          padding: const EdgeInsets.all(20), // og 20
        );
}

class QuestionCardStyles {
  static BoxDecoration get optionDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
      );

  static BoxDecoration get selectedOptionDecoration => BoxDecoration(
        color: const Color(0xFF9FA8DA),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static TextStyle get optionTextStyle => const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      );

  static TextStyle get selectedOptionTextStyle => const TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      );
}
