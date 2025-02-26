// question3_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import '../widgets/base_screen.dart';
import '../widgets/substance_option_tile.dart';
import 'question4_screen.dart';

class Question3Screen extends StatelessWidget {
  const Question3Screen({super.key});

  String getUrgeFrequencyLabel(int value) {
    switch (value) {
      case 0:
        return 'Never experienced urges';
      case 3:
        return 'Once or twice';
      case 4:
        return 'Monthly urges';
      case 5:
        return 'Weekly urges';
      case 6:
        return 'Daily or almost daily';
      default:
        return '';
    }
  }

  Widget buildExplanationBox() {
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
            'What counts as a strong desire or urge?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('• Intense cravings or thoughts about using'),
          Text('• Difficulty thinking about other things'),
          Text('• Feeling a strong need to use'),
          Text('• Experiencing physical reactions to thoughts of using'),
        ],
      ),
    );
  }

  Widget buildUrgeFrequencySelector(
    String substance,
    int currentValue,
    Function(int) onChanged,
  ) {
    final frequencies = [0, 3, 4, 5, 6];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: frequencies.map((value) {
        final isSelected = currentValue == value;

        return GestureDetector(
          onTap: () => onChanged(value),
          child: Container(
            width: 55,
            height: 60, 
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    getUrgeFrequencyLabel(value).split(' ')[0],
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
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
      questionNumber: '3 OF 8',
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
                    TextSpan(text: 'During the '),
                    TextSpan(
                      text: 'past three months',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          ', how often have you had a strong desire or urge to use:',
                    ),
                  ],
                ),
              ),


              buildExplanationBox(),

              Expanded(
                child: ListView.builder(
                  itemCount: recentlyUsedSubstances.length,
                  itemBuilder: (context, index) {
                    final substance = recentlyUsedSubstances[index];
                    final desire = provider.responses[substance]?.desire ?? 0;

                    return SubstanceOptionTile(
                      substance: substance,
                      backgroundColor: Colors.white,
                      trailing: SizedBox(
                        width: 300, // 300
                        child: buildUrgeFrequencySelector(
                          substance,
                          desire,
                          (value) => provider.updateDesire(substance, value),
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
                        builder: (context) => const Question4Screen(),
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
