// assessment_provider.dart
import 'package:flutter/foundation.dart';
import '../models/substance_response.dart';

class AssessmentProvider extends ChangeNotifier {
  final Map<String, SubstanceResponse> _responses = {};
  int _injectionUseStatus = 0;

  AssessmentProvider() {
    final substances = [
      "Tobacco products (cigarettes, chewing tobacco, cigars, etc.)",
      "Alcoholic beverages (beer, wine, spirits, etc.)",
      "Cannabis (marijuana, pot, grass, hash, etc.)",
      "Cocaine (coke, crack, etc.)",
      "Amphetamine-type stimulants (speed, meth, ecstasy, etc.)",
      "Inhalants (nitrous, glue, petrol, paint thinner, etc.)",
      "Sedatives or sleeping pills (diazepam, alprazolam, flunitrazepam, midazolam, etc.)",
      "Hallucinogens (LSD, acid, mushrooms, trips, ketamine, etc.)",
      "Opioids (heroin, morphine, methadone, buprenorphine, codeine, etc.)",
    ];

    for (var substance in substances) {
      _responses[substance] = SubstanceResponse(substanceName: substance);
    }
  }

  List<String> get substances => _responses.keys.toList();
  Map<String, SubstanceResponse> get responses => _responses;
  int get injectionUseStatus => _injectionUseStatus;

  bool get hasAnySubstanceEverUsed =>
      _responses.values.any((response) => response.everUsed);

  bool get hasRecentUse =>
      _responses.values.any((response) => response.usedInPastThreeMonths);

  void updateEverUsed(String substance, bool value) {
    if (_responses.containsKey(substance)) {
      _responses[substance]!.everUsed = value;
      notifyListeners();
    }
  }

  void updateFrequency(String substance, int value) {
    if (_responses.containsKey(substance)) {
      _responses[substance]!.frequency = value;
      notifyListeners();
    }
  }

  void updateDesire(String substance, int value) {
    if (_responses.containsKey(substance)) {
      _responses[substance]!.desire = value;
      notifyListeners();
    }
  }

  void updateProblems(String substance, int value) {
    if (_responses.containsKey(substance)) {
      _responses[substance]!.problems = value;
      notifyListeners();
    }
  }

  void updateFailedResponsibilities(String substance, int value) {
    if (_responses.containsKey(substance)) {
      _responses[substance]!.failed = value;
      notifyListeners();
    }
  }

  void updateConcern(String substance, int value) {
    if (_responses.containsKey(substance)) {
      _responses[substance]!.concern = value;
      notifyListeners();
    }
  }

  void updateReduceAttempts(String substance, int value) {
    if (_responses.containsKey(substance)) {
      _responses[substance]!.reduceFailed = value;
      notifyListeners();
    }
  }

  void updateInjectionUseStatus(int value) {
    _injectionUseStatus = value;
    notifyListeners();
  }

  int calculateTotalScore() {
    int total = 0;
    for (var response in _responses.values) {
      total += response.calculateScore();
    }
    total += _injectionUseStatus;
    return total;
  }

  String getRiskLevel() {
    final score = calculateTotalScore();
    if (score < 30) return "low";
    if (score < 70) return "moderate";
    return "high";
  }
}
