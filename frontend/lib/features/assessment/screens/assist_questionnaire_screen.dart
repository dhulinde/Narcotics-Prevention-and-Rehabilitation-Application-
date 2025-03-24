// features/assessment/screens/assist_questionnaire_screen.dart
import 'package:flutter/material.dart';
import '../../../core/models/assist_questionnaire_model.dart';
import '../widgets/question_screens.dart';
import '../widgets/results_screen.dart';
import '../../../config/routes.dart';
import '../../../config/constants.dart';
import '../../../core/services/api_data_service.dart';

// Main ASSIST Questionnaire Flow Screen
class AssistQuestionnaireScreen extends StatefulWidget {
  const AssistQuestionnaireScreen({Key? key}) : super(key: key);

  @override
  State<AssistQuestionnaireScreen> createState() => _AssistQuestionnaireScreenState();
}

class _AssistQuestionnaireScreenState extends State<AssistQuestionnaireScreen> {
  // Use explicit constructor instead of unnamed constructor
  final AssistQuestionnaire _questionnaire = AssistQuestionnaire(substances: []);
  int _currentStep = 0;
  bool _isLoading = false;
  final ApiDataService _apiService = ApiDataService();

  void _goToNextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _updateQuestionnaire(AssistQuestionnaire updatedQuestionnaire) {
    setState(() {
      _questionnaire.substances = updatedQuestionnaire.substances;
      _questionnaire.otherSubstanceSpecify = updatedQuestionnaire.otherSubstanceSpecify;
      _currentStep++;
    });
  }

  Future<void> _finishQuestionnaire() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the ApiDataService method to submit the questionnaire
      final success = await _apiService.finishQuestionnaire(
          _questionnaire,
          context,
              () {
            // Navigate to treatment plans on success
            if (mounted) {
              Navigator.pushNamed(
                context,
                AppRoutes.treatmentPlans,
                arguments: {
                  'onComplete': () {
                    // Go to dashboard and clear all previous screens
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.dashboard,
                          (route) => false,
                    );
                  },
                },
              );
            }
          }
      );

      if (!success) {
        // Handle failed submission (the ApiDataService will already show a SnackBar)
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error in _finishQuestionnaire: $e');
      setState(() {
        _isLoading = false;
      });

      // Show error message if not already shown by ApiDataService
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error submitting assessment. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getProgressText() {
    return 'Step ${_currentStep + 1} of 10';
  }

  double _getProgressValue() {
    return (_currentStep + 1) / 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          children: [
            Text(
              'ASSIST Questionnaire',
              style: TextStyle(
                color: AppColors.assessmentAccent,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getProgressText(),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: _currentStep > 0
            ? IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.assessmentAccent,
          ),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            } else {
              Navigator.pop(context);
            }
          },
        )
            : IconButton(
          icon: const Icon(
            Icons.close,
            color: AppColors.assessmentAccent,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: LinearProgressIndicator(
            value: _getProgressValue(),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.assessmentAccent),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.assessmentAccent,
        ),
      )
          : _buildCurrentStep(),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return IntroScreen(
          onNextPressed: _goToNextStep,
        );
      case 1:
        return LifetimeUseScreen(
          questionnaire: _questionnaire,
          onNext: _updateQuestionnaire,
        );
      case 2:
      // Check if there are any substances used in lifetime
        if (_questionnaire.getUsedSubstances().isEmpty) {
          // No substances used, skip to results
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _currentStep = 8; // Jump to results
            });
          });
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.assessmentAccent,
            ),
          );
        }
        return FrequencyScreen(
          questionnaire: _questionnaire,
          onNext: _updateQuestionnaire,
        );
      case 3:
      // Check if there are any substances used in last 3 months
        if (_questionnaire.getUsedLast3Months().isEmpty) {
          // No substances used in last 3 months, skip to Q6
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _currentStep = 6; // Jump to Q6
            });
          });
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.assessmentAccent,
            ),
          );
        }
        return UrgeToUseScreen(
          questionnaire: _questionnaire,
          onNext: _updateQuestionnaire,
        );
      case 4:
        return ProblemsScreen(
          questionnaire: _questionnaire,
          onNext: _updateQuestionnaire,
        );
      case 5:
        return FailedResponsibilitiesScreen(
          questionnaire: _questionnaire,
          onNext: _updateQuestionnaire,
        );
      case 6:
        return ConcernScreen(
          questionnaire: _questionnaire,
          onNext: _updateQuestionnaire,
        );
      case 7:
        return CutDownScreen(
          questionnaire: _questionnaire,
          onNext: _updateQuestionnaire,
        );
      case 8:
        return InjectionScreen(
          questionnaire: _questionnaire,
          onNext: _updateQuestionnaire,
        );
      case 9:
        return ResultsScreen(
          questionnaire: _questionnaire,
          onFinish: _finishQuestionnaire,
        );
      default:
        return IntroScreen(
          onNextPressed: () {
            setState(() {
              _currentStep = 0;
            });
          },
        );
    }
  }
}