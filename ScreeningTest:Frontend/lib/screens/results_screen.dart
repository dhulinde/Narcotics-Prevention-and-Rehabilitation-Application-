// results_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  Map<String, String> _getMessages(String riskLevel) {
    switch (riskLevel) {
      case "low":
        return {
          "risk": "Your responses indicate a low risk of addiction.",
          "impact":
              "While your current substance use appears to be under control, it's important to maintain healthy habits and stay aware of potential risks.",
          "recommendation":
              "Consider periodic self-assessments to ensure continued well-being.",
        };
      case "moderate":
        return {
          "risk": "Your responses suggest a moderate risk of addiction.",
          "impact":
              "This indicates a pattern that may affect your health and well-being over time.",
          "recommendation":
              "It could be helpful to reflect on your substance use and consider seeking professional guidance to prevent further risks.",
        };
      case "high":
        return {
          "risk": "Your responses indicate a high risk of addiction.",
          "impact":
              "This suggests significant concerns related to substance use.",
          "recommendation":
              "Seeking professional support is highly recommended to address these issues and prevent serious health, social, or legal consequences. Early intervention can be crucial for recovery.",
        };
      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        final score = provider.calculateTotalScore();
        final riskLevel = provider.getRiskLevel();
        final messages = _getMessages(riskLevel);

        return Scaffold(
          body: Stack(
            children: [
              Positioned(
                top: -40,
                left: -40,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFD6D6),
                  ),
                ),
              ),
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100, // og 100
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFF7F7F),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Results!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "You've completed the first step towards recovery.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 60),
                      // Score display
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFE6F0FF),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            // Purple accent circle
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF9FA8DA),
                                ),
                              ),
                            ),
                            // Pink accent circle
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFFD6D6),
                                ),
                              ),
                            ),
                            Text(
                              score.toString(),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),
                      Text(
                        messages["risk"]!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        messages["impact"]!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        messages["recommendation"]!,
                        style: TextStyle(
                          fontSize: riskLevel == "high" ? 16 : 14,
                          fontWeight: riskLevel == "high"
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: riskLevel == "high"
                              ? Colors.black
                              : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7F7F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8), // og 16
                            minimumSize: const Size(120, 0),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
