// core/models/assist_questionnaire_model.dart
import '../models/substance_data_model.dart';

class AssistQuestionnaire {
  List<SubstanceData> substances;
  String? otherSubstanceSpecify;

  // Modified constructor with default substances
  AssistQuestionnaire({required this.substances, this.otherSubstanceSpecify}) {
    // If substances list is empty, initialize with default substances
    if (substances.isEmpty) {
      substances = [
        SubstanceData(
          id: 'tobacco',
          name: 'Tobacco Products',
          description: '(cigarettes, chewing tobacco, cigars, etc.)',
          usedInLifetime: false,
        ),
        SubstanceData(
          id: 'alcohol',
          name: 'Alcoholic Beverages',
          description: '(beer, wine, spirits, etc.)',
          usedInLifetime: false,
        ),
        SubstanceData(
          id: 'cannabis',
          name: 'Cannabis',
          description: '(marijuana, pot, grass, hash, etc.)',
          usedInLifetime: false,
        ),
        SubstanceData(
          id: 'cocaine',
          name: 'Cocaine',
          description: '(coke, crack, etc.)',
          usedInLifetime: false,
        ),
        SubstanceData(
          id: 'amphetamine',
          name: 'Amphetamine Type Stimulants',
          description: '(speed, meth, ecstasy, etc.)',
          usedInLifetime: false,
        ),
        SubstanceData(
          id: 'inhalants',
          name: 'Inhalants',
          description: '(nitrous, glue, petrol, paint thinner, etc.)',
          usedInLifetime: false,
        ),
        SubstanceData(
          id: 'sedatives',
          name: 'Sedatives or Sleeping Pills',
          description: '(Valium, Serepax, etc.)',
          usedInLifetime: false,
        ),
        SubstanceData(
          id: 'hallucinogens',
          name: 'Hallucinogens',
          description: '(LSD, acid, mushrooms, PCP, etc.)',
          usedInLifetime: false,
        ),
        SubstanceData(
          id: 'opioids',
          name: 'Opioids',
          description: '(heroin, morphine, methadone, codeine, etc.)',
          usedInLifetime: false,
        ),
        SubstanceData(
          id: 'other',
          name: 'Other',
          description: '',
          usedInLifetime: false,
        ),
      ];
    }
  }

  // Get substances that have been used in lifetime
  List<SubstanceData> getUsedSubstances() {
    return substances.where((substance) => substance.usedInLifetime).toList();
  }

  // Get substances that have been used in last 3 months
  List<SubstanceData> getUsedLast3Months() {
    return substances.where((substance) =>
    substance.usedInLifetime && substance.frequencyLast3Months > 0
    ).toList();
  }

  // Calculate scores for each substance
  Map<String, int> calculateRiskScores() {
    Map<String, int> scores = {};

    for (var substance in substances) {
      if (substance.usedInLifetime) {
        // Calculate score based on ASSIST scoring algorithm
        int score = 0;

        // Q2: Frequency in last 3 months (0-6)
        score += substance.frequencyLast3Months;

        // Q3: Urge to use (0-6)
        score += substance.urgeToUse;

        // Q4: Problems (0-7)
        score += substance.problemsFromUse;

        // Q5: Failed responsibilities (0-7)
        score += substance.failedResponsibilities;

        // Q6: Concern from others (0, 3, or 6)
        score += substance.concernFromOthers;

        // Q7: Tried to control use (0, 3, or 6)
        score += substance.triedToControl;

        // Store score
        scores[substance.id] = score;
      }
    }

    return scores;
  }

  // NEW METHOD: Calculate highest score across all substances
  int calculateHighestScore() {
    Map<String, int> scores = calculateRiskScores();
    if (scores.isEmpty) return 0;

    return scores.values.reduce((max, score) => score > max ? score : max);
  }

  // Determine risk levels for each substance
  Map<String, String> getRiskLevels() {
    Map<String, String> riskLevels = {};
    Map<String, int> scores = calculateRiskScores();

    scores.forEach((substanceId, score) {
      // Risk level thresholds based on ASSIST guidelines
      if (substanceId == 'alcohol') {
        if (score >= 27) {
          riskLevels[substanceId] = 'High';
        } else if (score >= 11) {
          riskLevels[substanceId] = 'Moderate';
        } else {
          riskLevels[substanceId] = 'Low';
        }
      } else {
        // For all other substances
        if (score >= 27) {
          riskLevels[substanceId] = 'High';
        } else if (score >= 4) {
          riskLevels[substanceId] = 'Moderate';
        } else {
          riskLevels[substanceId] = 'Low';
        }
      }
    });

    return riskLevels;
  }

  // NEW METHOD: Get overall risk level based on highest risk substance
  String getOverallRiskLevel() {
    int highestScore = calculateHighestScore();

    // Using standard ASSIST risk thresholds
    if (highestScore >= 27) {
      return 'High';
    } else if (highestScore >= 11) {
      return 'Moderate';
    } else if (highestScore >= 4) {
      return 'Low';
    } else {
      return 'None';
    }
  }

  // Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'substances': substances.map((s) => s.toJson()).toList(),
      'otherSubstanceSpecify': otherSubstanceSpecify,
      'riskScores': calculateRiskScores(),
      'riskLevels': getRiskLevels(),
      'highestScore': calculateHighestScore(),
      'overallRiskLevel': getOverallRiskLevel(),
      'hasInjected': substances.any((s) => s.injected),
      'injectionFrequency': substances.any((s) => s.injectionFrequency > 0) ?
      substances.firstWhere((s) => s.injectionFrequency > 0, orElse: () => substances.first).injectionFrequency : 0,
    };
  }

  // Create from JSON response
  factory AssistQuestionnaire.fromJson(Map<String, dynamic> json) {
    return AssistQuestionnaire(
      substances: (json['substances'] as List)
          .map((s) => SubstanceData.fromJson(s))
          .toList(),
      otherSubstanceSpecify: json['otherSubstanceSpecify'],
    );
  }
}