// substance_response.dart
class SubstanceResponse {
  final String substanceName;

  bool everUsed;

  int frequency;
  int desire;
  int problems;
  int failed;
  int concern;
  int reduceFailed;

  String? otherSpecification;

  SubstanceResponse({
    required this.substanceName,
    this.everUsed = false,
    this.frequency = 0,
    this.desire = 0,
    this.problems = 0,
    this.failed = 0,
    this.concern = 0,
    this.reduceFailed = 0,
    this.otherSpecification,
  });

  bool get usedInPastThreeMonths => frequency > 0;
  int calculateScore() {
    if (!everUsed) return 0;
    int score = 0;
    score += frequency;
    if (usedInPastThreeMonths) {
      score += desire;
      score += problems;
      score += failed;
    }
    score += concern;
    score += reduceFailed;
    return score;
  }

  void reset() {
    everUsed = false;
    frequency = 0;
    desire = 0;
    problems = 0;
    failed = 0;
    concern = 0;
    reduceFailed = 0;
    otherSpecification = null;
  }

  SubstanceResponse copy() {
    return SubstanceResponse(
      substanceName: substanceName,
      everUsed: everUsed,
      frequency: frequency,
      desire: desire,
      problems: problems,
      failed: failed,
      concern: concern,
      reduceFailed: reduceFailed,
      otherSpecification: otherSpecification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'substanceName': substanceName,
      'everUsed': everUsed,
      'frequency': frequency,
      'desire': desire,
      'problems': problems,
      'failed': failed,
      'concern': concern,
      'reduceFailed': reduceFailed,
      'otherSpecification': otherSpecification,
    };
  }

  factory SubstanceResponse.fromMap(Map<String, dynamic> map) {
    return SubstanceResponse(
      substanceName: map['substanceName'] as String,
      everUsed: map['everUsed'] as bool,
      frequency: map['frequency'] as int,
      desire: map['desire'] as int,
      problems: map['problems'] as int,
      failed: map['failed'] as int,
      concern: map['concern'] as int,
      reduceFailed: map['reduceFailed'] as int,
      otherSpecification: map['otherSpecification'] as String?,
    );
  }

  @override
  String toString() {
    return 'SubstanceResponse{substanceName: $substanceName, everUsed: $everUsed, frequency: $frequency, '
        'desire: $desire, problems: $problems, failed: $failed, concern: $concern, '
        'reduceFailed: $reduceFailed, otherSpecification: $otherSpecification}';
  }
}
