// question2_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import '../widgets/base_screen.dart';
import '../widgets/substance_option_tile.dart';
import 'question3_screen.dart';
import 'question6_screen.dart';

class Question2Screen extends StatelessWidget {
  const Question2Screen({super.key});

  String getFrequencyLabel(int value) {
    switch (value) {
      case 0:
        return 'Never';
      case 2:
        return 'Once or twice';
      case 3:
        return 'Monthly';
      case 4:
        return 'Weekly';
      case 6:
        return 'Daily or almost daily';
      default:
        return '';
    }
  }

  Widget buildFrequencySelector(
    String substance,
    int currentValue,
    Function(int) onChanged,
  ) {
    final frequencies = [0, 2, 3, 4, 6];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: frequencies.map((value) {
        final isSelected = currentValue == value;

        return GestureDetector(
          onTap: () => onChanged(value),
          child: Container(
            width: 55,
            height: 55,
            margin: const EdgeInsets.symmetric(horizontal: 2),
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
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  getFrequencyLabel(value).split(' ')[0],
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

  Widget buildLegendBox() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Frequency Guide:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('• Never: No use in the past 3 months'),
          Text('• Once/Twice: 1-2 times total'),
          Text('• Monthly: About 1-3 times per month'),
          Text('• Weekly: About 1-4 times per week'),
          Text('• Daily: Daily or almost daily use'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Assessment',
      questionNumber: '2 OF 8',
      child: Consumer<AssessmentProvider>(
        builder: (context, provider, child) {
          final usedSubstances = provider.substances
              .where((substance) =>
                  provider.responses[substance]?.everUsed == true)
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
                    TextSpan(text: 'In the '),
                    TextSpan(
                      text: 'past three months',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ', how often have you used these substances?',
                    ),
                  ],
                ),
              ),

              buildLegendBox(),

              Expanded(
                child: ListView.builder(
                  itemCount: usedSubstances.length,
                  itemBuilder: (context, index) {
                    final substance = usedSubstances[index];
                    final frequency =
                        provider.responses[substance]?.frequency ?? 0;

                    return SubstanceOptionTile(
                      substance: substance,
                      backgroundColor: Colors.white,
                      trailing: SizedBox(
                        width: 300,
                        child: buildFrequencySelector(
                          substance,
                          frequency,
                          (value) => provider.updateFrequency(substance, value),
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
                        builder: (context) => provider.hasRecentUse
                            ? const Question3Screen() // If any recent use
                            : const Question6Screen(), // If no recent use
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9FA8DA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
