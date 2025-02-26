// question1_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screening_test/screens/question1sub_screen.dart';
import '../providers/assessment_provider.dart';
import '../widgets/base_screen.dart';
import '../widgets/substance_option_tile.dart';
import 'results_screen.dart';

class Question1Screen extends StatefulWidget {
  const Question1Screen({super.key});

  @override
  State<Question1Screen> createState() => _Question1ScreenState();
}

class _Question1ScreenState extends State<Question1Screen> {
  bool _hasShownSchoolProbe = false;

  Future<void> _showSchoolProbeDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Additional Question'),
          content: const Text(
            'Not even used drugs when you were in school?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (result == false) {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ResultsScreen(),
          ),
        );
      }
    } else if (result == true) {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Question1SubScreen(),
          ),
        );
      }
    }
  }

  Future<void> _handleNext(BuildContext context) async {
    final provider = Provider.of<AssessmentProvider>(context, listen: false);

    if (!provider.hasAnySubstanceEverUsed && !_hasShownSchoolProbe) {
      setState(() {
        _hasShownSchoolProbe = true;
      });

      await _showSchoolProbeDialog(context);
    } else {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Question1SubScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Assessment',
      questionNumber: '1 OF 8',
      child: Consumer<AssessmentProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'In your life, which of the following substances have you ever used (non-medical use only)?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView.builder(
                  itemCount: provider.substances.length,
                  itemBuilder: (context, index) {
                    final substance = provider.substances[index];
                    final isSelected =
                        provider.responses[substance]?.everUsed ?? false;

                    return SubstanceOptionTile(
                      substance: substance,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildResponseButton(
                            label: 'No',
                            isSelected: !isSelected,
                            onPressed: () =>
                                provider.updateEverUsed(substance, false),
                          ),
                          const SizedBox(width: 8),
                          _buildResponseButton(
                            label: 'Yes',
                            isSelected: isSelected,
                            onPressed: () =>
                                provider.updateEverUsed(substance, true),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () => _handleNext(context),
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

  Widget _buildResponseButton({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF9FA8DA) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF9FA8DA) : Colors.grey[300]!,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      child: Text(label),
    );
  }
}