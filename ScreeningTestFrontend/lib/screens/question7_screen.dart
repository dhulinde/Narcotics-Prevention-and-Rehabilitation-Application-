// question7_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import '../widgets/base_screen.dart';
import 'question8_screen.dart';

class Question7Screen extends StatelessWidget {
  const Question7Screen({super.key});


  String getAttemptResponseLabel(int value) {
    switch (value) {
      case 0:
        return 'No, never tried to reduce';
      case 6:
        return 'Yes, tried in the past 3 months';
      case 3:
        return 'Yes, but not in the past 3 months';
      default:
        return '';
    }
  }


  Widget buildGuidanceBox() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Text(
        'Consider attempts such as:\n'
        '• Trying to use less frequently\n'
        '• Trying to reduce the amount used\n'
        '• Attempting to quit completely\n'
        '• Seeking help or support to cut down',
        style: TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget buildAttemptResponseSelector(
    String substance,
    int currentValue,
    Function(int) onChanged,
  ) {
    final responses = [0, 6, 3]; // The possible response values

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: responses.map((value) {
        final isSelected = currentValue == value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => onChanged(value),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF9FA8DA) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFF9FA8DA) : Colors.grey[300]!,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                getAttemptResponseLabel(value),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Assessment',
      questionNumber: '7 OF 8',
      child: Consumer<AssessmentProvider>(
        builder: (context, provider, child) {
          final everUsedSubstances = provider.substances
              .where((substance) =>
                  provider.responses[substance]?.everUsed == true)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Have you ever tried to cut down on using these substances but failed?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              buildGuidanceBox(),

              Expanded(
                child: ListView.builder(
                  itemCount: everUsedSubstances.length,
                  itemBuilder: (context, index) {
                    final substance = everUsedSubstances[index];
                    final attempts =
                        provider.responses[substance]?.reduceFailed ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      color: const Color(0xFFE6F0FF).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              substance,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            buildAttemptResponseSelector(
                              substance,
                              attempts,
                              (value) {
                                provider.updateReduceAttempts(substance, value);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Question8Screen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9FA8DA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: const Text('Next'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
