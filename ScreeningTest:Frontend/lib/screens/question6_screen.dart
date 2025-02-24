// question6_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import '../widgets/base_screen.dart';
import 'question7_screen.dart';

class Question6Screen extends StatelessWidget {
  const Question6Screen({super.key});

  String getConcernResponseLabel(int value) {
    switch (value) {
      case 0:
        return 'No, never';
      case 6:
        return 'Yes, in the past 3 months';
      case 3:
        return 'Yes, but not in the past 3 months';
      default:
        return '';
    }
  }

  Widget buildConcernResponseSelector(
    String substance,
    int currentValue,
    Function(int) onChanged,
  ) {
    final responses = [0, 6, 3];

    return Column(
      children: responses.map((value) {
        final isSelected = currentValue == value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => onChanged(value),
            child: Container(
              width: double.infinity,
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
                getConcernResponseLabel(value),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildContextBox() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Text(
        'Consider concerns expressed about:\n'
        '• Amount or frequency of use\n'
        '• Changes in behavior or mood\n'
        '• Impact on health or relationships\n'
        '• Suggestions to cut down or stop use',
        style: TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Assessment',
      questionNumber: '6 OF 8',
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
                'Has a friend or relative or anyone else ever expressed concern about your use of the following substances?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),


              buildContextBox(),

              Expanded(
                child: ListView.builder(
                  itemCount: everUsedSubstances.length,
                  itemBuilder: (context, index) {
                    final substance = everUsedSubstances[index];
                    final concern = provider.responses[substance]?.concern ?? 0;

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
                            buildConcernResponseSelector(
                              substance,
                              concern,
                              (value) {
                                provider.updateConcern(substance, value);
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
                        builder: (context) => const Question7Screen(),
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
