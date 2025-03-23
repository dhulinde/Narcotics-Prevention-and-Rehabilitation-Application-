// core/models/substance_data_model.dart

class SubstanceData {
  final String id;
  final String name;
  final String description;
  bool usedInLifetime;
  int frequencyLast3Months;
  int urgeToUse;
  int healthSocialProblems;
  int problemsFromUse;
  int failedResponsibilities;
  int concernFromOthers;
  int triedToControl;
  bool injected;
  int injectionFrequency;

  SubstanceData({
    required this.id,
    required this.name,
    required this.description,
    required this.usedInLifetime,
    this.frequencyLast3Months = 0,
    this.urgeToUse = 0,
    this.healthSocialProblems = 0,
    this.problemsFromUse = 0,
    this.failedResponsibilities = 0,
    this.concernFromOthers = 0,
    this.triedToControl = 0,
    this.injected = false,
    this.injectionFrequency = 0,
  });

  // Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'usedInLifetime': usedInLifetime,
      'frequencyLast3Months': frequencyLast3Months,
      'urgeToUse': urgeToUse,
      'healthSocialProblems': healthSocialProblems,
      'problemsFromUse': problemsFromUse,
      'failedResponsibilities': failedResponsibilities,
      'concernFromOthers': concernFromOthers,
      'triedToControl': triedToControl,
      'injected': injected,
      'injectionFrequency': injectionFrequency,
    };
  }

  // Create from JSON response
  factory SubstanceData.fromJson(Map<String, dynamic> json) {
    return SubstanceData(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      usedInLifetime: json['usedInLifetime'],
      frequencyLast3Months: json['frequencyLast3Months'] ?? 0,
      urgeToUse: json['urgeToUse'] ?? 0,
      healthSocialProblems:json['healthSocialProblems'] ?? 0,
      problemsFromUse: json['problemsFromUse'] ?? 0,
      failedResponsibilities: json['failedResponsibilities'] ?? 0,
      concernFromOthers: json['concernFromOthers'] ?? 0,
      triedToControl: json['triedToControl'] ?? 0,
      injected: json['injected'] ?? false,
      injectionFrequency: json['injectionFrequency'] ?? 0,
    );
  }

  // Clone method for creating copies
  SubstanceData clone() {
    return SubstanceData(
      id: id,
      name: name,
      description: description,
      usedInLifetime: usedInLifetime,
      frequencyLast3Months: frequencyLast3Months,
      urgeToUse: urgeToUse,
      healthSocialProblems: healthSocialProblems,
      problemsFromUse: problemsFromUse,
      failedResponsibilities: failedResponsibilities,
      concernFromOthers: concernFromOthers,
      triedToControl: triedToControl,
      injected: injected,
      injectionFrequency: injectionFrequency,
    );
  }
}