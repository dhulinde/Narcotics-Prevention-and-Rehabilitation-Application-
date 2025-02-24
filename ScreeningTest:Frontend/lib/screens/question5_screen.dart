// question5_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import '../widgets/base_screen.dart';
import 'question6_screen.dart';

class Question5Screen extends StatelessWidget {
  const Question5Screen({super.key});


  String getFailureFrequencyLabel(int value) {
    switch (value) {
      case 0:
        return 'Never';
      case 5:
        return 'Once or twice';
      case 6:
        return 'Monthly';
      case 7:
        return 'Weekly';
      case 8:
        return 'Daily or almost daily';
      default:
        return '';
    }
  }


  Widget buildFailureFrequencySelector(
    String substance,
    int currentValue,
    Function(int) onChanged,
  ) {
    final frequencies = [
      0,
      5,
      6,
      7,
      8
    ]; 

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: frequencies.map((value) {
        final isSelected = currentValue == value;

        return GestureDetector(
          onTap: () => onChanged(value),
          child: Container(
            width: 52, 
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF9FA8DA) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? const Color(0xFF9FA8DA) : Colors.grey[300]!,
                width: 1.5,
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
                  getFailureFrequencyLabel(value).split(' ')[0],
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

  Widget buildExamplesBox() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Text(
        'Examples of responsibilities:\n'
        '• Work or school attendance\n'
        '• Family obligations\n'
        '• Important appointments\n'
        '• Household duties',
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
      questionNumber: '5 OF 8',
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
                          ', how often have you failed to do what was normally expected of you because of your substance use?',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),


              buildExamplesBox(),

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
                    final failures = provider.responses[substance]?.failed ?? 0;

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
                            buildFailureFrequencySelector(
                              substance,
                              failures,
                              (value) {
                                provider.updateFailedResponsibilities(
                                    substance, value);
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
                        builder: (context) => const Question6Screen(),
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
