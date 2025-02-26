// question4_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import '../widgets/base_screen.dart';
import 'question5_screen.dart';

class Question4Screen extends StatelessWidget {
  const Question4Screen({super.key});


  String getProblemFrequencyLabel(int value) {
    switch (value) {
      case 0:
        return 'Never';
      case 4:
        return 'Once or twice';
      case 5:
        return 'Monthly';
      case 6:
        return 'Weekly';
      case 7:
        return 'Daily or almost daily';
      default:
        return '';
    }
  }


  Widget buildProblemFrequencySelector(
    String substance,
    int currentValue,
    Function(int) onChanged,
  ) {

    final frequencies = [0, 4, 5, 6, 7];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: frequencies.map((value) {
        final isSelected = currentValue == value;

        return GestureDetector(
          onTap: () => onChanged(value),
          child: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF9FA8DA) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? const Color(0xFF9FA8DA) : Colors.grey[300]!,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                Text(
                  getProblemFrequencyLabel(value).split(' ')[0],
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                ),
              ],
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
      questionNumber: '4 OF 8',
      child: Consumer<AssessmentProvider>(
        builder: (context, provider, child) {
          final recentlyUsedSubstances = provider.substances
              .where((substance) =>
                  (provider.responses[substance]?.frequency ?? 0) > 0)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: 'During the ',
                    ),
                    TextSpan(
                      text: 'past three months',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text:
                          ', how often has your use led to health, social, legal, or financial problems?',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Consider issues like health concerns, relationship difficulties, legal troubles, or money problems.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Never', style: TextStyle(fontSize: 12)),
                  Text('Once/Twice', style: TextStyle(fontSize: 12)),
                  Text('Monthly', style: TextStyle(fontSize: 12)),
                  Text('Weekly', style: TextStyle(fontSize: 12)),
                  Text('Daily', style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: recentlyUsedSubstances.length,
                  itemBuilder: (context, index) {
                    final substance = recentlyUsedSubstances[index];
                    final problems =
                        provider.responses[substance]?.problems ?? 0;

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
                            buildProblemFrequencySelector(
                              substance,
                              problems,
                              (value) {
                                provider.updateProblems(substance, value);
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
                        builder: (context) => const Question5Screen(),
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
