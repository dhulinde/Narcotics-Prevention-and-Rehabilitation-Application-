// features/assessment/widgets/results_screen.dart
import 'package:flutter/material.dart';
import '../../../core/models/assist_questionnaire_model.dart';
import '../../../config/constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../services/assist_questionnaire_service.dart';

/// Custom circle painter for the results screen
class DashedCirclePainter extends CustomPainter {
  final Color color;

  DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    final Path path = Path();

    // Create a dashed circular path
    for (double i = 0; i < 360; i += 12) {
      final double startAngle = i * (3.14159 / 180);
      final double endAngle = (i + 6) * (3.14159 / 180);

      path.addArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        startAngle,
        endAngle - startAngle,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Results Screen
class ResultsScreen extends StatelessWidget {
  final AssistQuestionnaire questionnaire;
  final VoidCallback onFinish;

  const ResultsScreen({
    Key? key,
    required this.questionnaire,
    required this.onFinish,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final highestScore = questionnaire.calculateHighestScore();
    final riskLevel = questionnaire.getOverallRiskLevel();
    final riskVisuals = AssistQuestionnaireService.getRiskLevelVisuals(riskLevel);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Risk level circle
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: riskVisuals['background'] as Color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CustomPaint(
                        painter: DashedCirclePainter(color: riskVisuals['color'] as Color),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          highestScore.toString(),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: riskVisuals['color'] as Color,
                          ),
                        ),
                        Text(
                          'points',
                          style: TextStyle(
                            fontSize: 14,
                            color: riskVisuals['color'] as Color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Risk level text
            Text(
              AssistQuestionnaireService.getRiskText(riskLevel),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 24),

            // Advice cards
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        riskVisuals['icon'] as IconData,
                        color: riskVisuals['color'] as Color,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AssistQuestionnaireService.getAdviceText1(riskLevel),
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1, color: AppColors.lightGrey),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.warning,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AssistQuestionnaireService.getAdviceText2(riskLevel),
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1, color: AppColors.lightGrey),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AssistQuestionnaireService.getRecommendation(riskLevel),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Complete button
            CustomButton(
              text: 'Choose Your Plan',
              onPressed: onFinish,
              variant: ButtonVariant.gradient,
            ),

            const SizedBox(height: 16),

            // Disclaimer text
            const Text(
              'This assessment is for informational purposes only and does not replace professional medical advice.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}