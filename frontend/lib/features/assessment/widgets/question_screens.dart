// features/assessment/widgets/question_screens.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/models/assist_questionnaire_model.dart';
import '../../../config/constants.dart';
import '../../../core/models/substance_data_model.dart';
import '../../../shared/widgets/custom_button.dart';

/// Intro Screen - Frequency Legend
class IntroScreen extends StatelessWidget {
  final VoidCallback onNextPressed;

  const IntroScreen({
    Key? key,
    required this.onNextPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.assessmentAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.assessmentAccent,
                    size: 40,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'About This Questionnaire',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.assessmentAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This questionnaire will ask about your experience with various substances. Your honest answers will help us provide personalized support for your recovery journey.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Frequency Reference Guide',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'When asked about frequency of substance use, please use the following guide:',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Frequency legend
            _buildFrequencyItem('Never', 'Not used in the last 3 months', '1'),
            _buildFrequencyItem('Once or twice', '1 to 2 times in the last 3 months', '2'),
            _buildFrequencyItem('Monthly', 'Average of 1 to 3 times per month', '3'),
            _buildFrequencyItem('Weekly', '1 to 4 times per week', '4'),
            _buildFrequencyItem('Daily or almost daily', '5 to 7 days per week', '5'),

            const SizedBox(height: 40),

            CustomButton(
              text: 'Next',
              onPressed: onNextPressed,
              variant: ButtonVariant.gradient,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyItem(String title, String description, String number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.assessmentAccent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Question 1: Lifetime substance use
class LifetimeUseScreen extends StatefulWidget {
  final AssistQuestionnaire questionnaire;
  final Function(AssistQuestionnaire) onNext;

  const LifetimeUseScreen({
    Key? key,
    required this.questionnaire,
    required this.onNext,
  }) : super(key: key);

  @override
  State<LifetimeUseScreen> createState() => _LifetimeUseScreenState();
}

class _LifetimeUseScreenState extends State<LifetimeUseScreen> {
  final TextEditingController _otherController = TextEditingController();
  bool isOtherSelected = false;

  @override
  void initState() {
    super.initState();

    // Check if substances list is not empty before accessing last element
    if (widget.questionnaire.substances.isNotEmpty) {
      isOtherSelected = widget.questionnaire.substances.last.usedInLifetime;
      _otherController.text = widget.questionnaire.otherSubstanceSpecify ?? '';
    } else {
      // If the substances list is empty, set default values
      isOtherSelected = false;
      _otherController.text = '';
    }
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Question card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.assessmentAccent.withOpacity(0.8),
                    AppColors.assessmentAccent,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.assessmentAccent.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text(
                    'In your life, which of the following substances have you ever used?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '(Non-medical use only)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Substances list
            // Check if substances list is empty
            widget.questionnaire.substances.isEmpty
                ? _buildEmptySubstancesMessage()
                : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: widget.questionnaire.substances.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final substance = widget.questionnaire.substances[index];
                  final isOther = index ==
                      widget.questionnaire.substances.length - 1;

                  return Column(
                    children: [
                      CheckboxListTile(
                        title: Text(
                          '${substance.name} ${substance.description}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: substance.usedInLifetime,
                        activeColor: AppColors.assessmentAccent,
                        checkColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onChanged: (value) {
                          setState(() {
                            substance.usedInLifetime = value ?? false;
                            if (isOther) {
                              isOtherSelected = value ?? false;
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      if (isOther && isOtherSelected)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 8.0,
                          ),
                          child: TextField(
                            controller: _otherController,
                            decoration: InputDecoration(
                              hintText: 'Please specify',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.assessmentAccent,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onChanged: (value) {
                              widget.questionnaire.otherSubstanceSpecify =
                                  value;
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Next button
            CustomButton(
              text: 'Next',
              onPressed: () {
                if (isOtherSelected) {
                  widget.questionnaire.otherSubstanceSpecify =
                      _otherController.text;
                }
                widget.onNext(widget.questionnaire);
              },
              variant: ButtonVariant.gradient,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildEmptySubstancesMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: Colors.orange[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No substances found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'There seems to be an issue loading the substances list. Please try again later or contact support.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Question 2: Frequency in last 3 months
class FrequencyScreen extends StatefulWidget {
  final AssistQuestionnaire questionnaire;
  final Function(AssistQuestionnaire) onNext;

  const FrequencyScreen({
    Key? key,
    required this.questionnaire,
    required this.onNext,
  }) : super(key: key);

  @override
  State<FrequencyScreen> createState() => _FrequencyScreenState();
}

class _FrequencyScreenState extends State<FrequencyScreen> {
  final Map<int, String> frequencyLabels = {
    0: 'Never',
    2: 'Once or twice',
    3: 'Monthly',
    4: 'Weekly',
    6: 'Daily or almost daily',
  };

  final Map<int, int> frequencyScores = {
    1: 0, // Never
    2: 2, // Once or twice
    3: 3, // Monthly
    4: 4, // Weekly
    5: 6, // Daily or almost daily
  };

  @override
  Widget build(BuildContext context) {
    final usedSubstances = widget.questionnaire.getUsedSubstances();

    return SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(24.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Question card
    Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
    AppColors.assessmentAccent.withOpacity(0.8),
    AppColors.assessmentAccent,
    ],
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
    BoxShadow(
    color: AppColors.assessmentAccent.withOpacity(0.3),
    blurRadius: 10,
    offset: const Offset(0, 4),
    ),
    ],
    ),
    child: const Column(
    children: [
    Text(
    'In the past three months, how often have you used the substances you mentioned?',
    textAlign: TextAlign.center,
      // Previous content continued...
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.4,
      ),
    ),
    ],
    ),
    ),

      const SizedBox(height: 24),

      // Substances frequency
      ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: usedSubstances.length,
        itemBuilder: (context, index) {
          final substance = usedSubstances[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.assessmentAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${substance.name} ${substance.description}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              // Frequency buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(5, (i) {
                    final buttonNumber = i + 1;
                    final score = frequencyScores[buttonNumber]!;
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              substance.frequencyLast3Months = score;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: substance.frequencyLast3Months == score
                                  ? AppColors.assessmentAccent
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.assessmentAccent,
                                width: 2,
                              ),
                              boxShadow: substance.frequencyLast3Months == score
                                  ? [
                                BoxShadow(
                                  color: AppColors.assessmentAccent.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              buttonNumber.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: substance.frequencyLast3Months == score
                                    ? Colors.white
                                    : AppColors.assessmentAccent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          frequencyLabels[score]!.split(' ')[0],
                          style: TextStyle(
                            fontSize: 12,
                            color: substance.frequencyLast3Months == score
                                ? AppColors.assessmentAccent
                                : AppColors.textSecondary,
                            fontWeight: substance.frequencyLast3Months == score
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),

      const SizedBox(height: 16),

      // Next button
      CustomButton(
        text: 'Next',
        onPressed: () {
          widget.onNext(widget.questionnaire);
        },
        variant: ButtonVariant.gradient,
      ),

      const SizedBox(height: 32),
    ],
    ),
        ),
    );
  }
}

/// Question 3: Urge to Use
class UrgeToUseScreen extends StatefulWidget {
  final AssistQuestionnaire questionnaire;
  final Function(AssistQuestionnaire) onNext;

  const UrgeToUseScreen({
    Key? key,
    required this.questionnaire,
    required this.onNext,
  }) : super(key: key);

  @override
  State<UrgeToUseScreen> createState() => _UrgeToUseScreenState();
}

class _UrgeToUseScreenState extends State<UrgeToUseScreen> {
  final Map<int, int> urgeScores = {
    1: 0, // Never
    2: 3, // Once or twice
    3: 4, // Monthly
    4: 5, // Weekly
    5: 6, // Daily or almost daily
  };

  final Map<int, String> frequencyLabels = {
    0: 'Never',
    3: 'Once or twice',
    4: 'Monthly',
    5: 'Weekly',
    6: 'Daily or almost daily',
  };

  @override
  Widget build(BuildContext context) {
    final usedSubstancesLast3Months = widget.questionnaire.getUsedLast3Months();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.assessmentAccent.withOpacity(0.8),
                    AppColors.assessmentAccent,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.assessmentAccent.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text(
                    'During the past three months, how often have you had a strong desire or urge to use these substances?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Substances urge to use
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: usedSubstancesLast3Months.length,
              itemBuilder: (context, index) {
                final substance = usedSubstancesLast3Months[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.assessmentAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${substance.name} ${substance.description}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    // Frequency buttons for urge to use
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(5, (i) {
                          final buttonNumber = i + 1;
                          final score = urgeScores[buttonNumber]!;
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    substance.urgeToUse = score;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: substance.urgeToUse == score
                                        ? AppColors.assessmentAccent
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.assessmentAccent,
                                      width: 2,
                                    ),
                                    boxShadow: substance.urgeToUse == score
                                        ? [
                                      BoxShadow(
                                        color: AppColors.assessmentAccent.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    buttonNumber.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: substance.urgeToUse == score
                                          ? Colors.white
                                          : AppColors.assessmentAccent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                frequencyLabels[score]!.split(' ')[0],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: substance.urgeToUse == score
                                      ? AppColors.assessmentAccent
                                      : AppColors.textSecondary,
                                  fontWeight: substance.urgeToUse == score
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Next button
            CustomButton(
              text: 'Next',
              onPressed: () {
                widget.onNext(widget.questionnaire);
              },
              variant: ButtonVariant.gradient,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Question 4: Health, Social, Legal, Financial Problems
class ProblemsScreen extends StatefulWidget {
  final AssistQuestionnaire questionnaire;
  final Function(AssistQuestionnaire) onNext;

  const ProblemsScreen({
    Key? key,
    required this.questionnaire,
    required this.onNext,
  }) : super(key: key);

  @override
  State<ProblemsScreen> createState() => _ProblemsScreenState();
}

class _ProblemsScreenState extends State<ProblemsScreen> {
  final Map<int, int> problemScores = {
    1: 0, // Never
    2: 4, // Once or twice
    3: 5, // Monthly
    4: 6, // Weekly
    5: 7, // Daily or almost daily
  };

  final Map<int, String> frequencyLabels = {
    0: 'Never',
    4: 'Once or twice',
    5: 'Monthly',
    6: 'Weekly',
    7: 'Daily or almost daily',
  };

  @override
  Widget build(BuildContext context) {
    final usedSubstancesLast3Months = widget.questionnaire.getUsedLast3Months();

    return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // Question card
          Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.assessmentAccent.withOpacity(0.8),
                AppColors.assessmentAccent,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.assessmentAccent.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Column(
            children: [
              Text(
                'During the past three months, how often has your use of these substances led to health, social, legal or financial problems?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Substances problems
        ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: usedSubstancesLast3Months.length,
    itemBuilder: (context, index) {
    final substance = usedSubstancesLast3Months[index];
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: AppColors.assessmentAccent.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
    '${substance.name} ${substance.description}',
    style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    ),
    ),
    ),

    // Frequency buttons for problems
    Padding(
    padding: const EdgeInsets.only(bottom: 24.0),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: List.generate(5, (i) {
    final buttonNumber = i + 1;
    final score = problemScores[buttonNumber]!;
    return Column(
    children: [
    InkWell(
    onTap: () {
    setState(() {
    substance.problemsFromUse = score;
    });
    },
    borderRadius: BorderRadius.circular(8),
    child: Container(
    width: 50,
    height: 50,
    decoration:
    BoxDecoration(
      color: substance.problemsFromUse == score
          ? AppColors.assessmentAccent
          : Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: AppColors.assessmentAccent,
        width: 2,
      ),
      boxShadow: substance.problemsFromUse == score
          ? [
        BoxShadow(
          color: AppColors.assessmentAccent.withOpacity(0.3),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ]
          : null,
    ),
      alignment: Alignment.center,
      child: Text(
        buttonNumber.toString(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: substance.problemsFromUse == score
              ? Colors.white
              : AppColors.assessmentAccent,
        ),
      ),
    ),
    ),
      const SizedBox(height: 4),
      Text(
        frequencyLabels[score]!.split(' ')[0],
        style: TextStyle(
          fontSize: 12,
          color: substance.problemsFromUse == score
              ? AppColors.assessmentAccent
              : AppColors.textSecondary,
          fontWeight: substance.problemsFromUse == score
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    ],
    );
    }),
    ),
    ),
    ],
    );
    },
        ),

                const SizedBox(height: 16),

                // Next button
                CustomButton(
                  text: 'Next',
                  onPressed: () {
                    widget.onNext(widget.questionnaire);
                  },
                  variant: ButtonVariant.gradient,
                ),

                const SizedBox(height: 32),
              ],
          ),
        ),
    );
  }
}

/// Question 5: Failed Responsibilities
class FailedResponsibilitiesScreen extends StatefulWidget {
  final AssistQuestionnaire questionnaire;
  final Function(AssistQuestionnaire) onNext;

  const FailedResponsibilitiesScreen({
    Key? key,
    required this.questionnaire,
    required this.onNext,
  }) : super(key: key);

  @override
  State<FailedResponsibilitiesScreen> createState() => _FailedResponsibilitiesScreenState();
}

class _FailedResponsibilitiesScreenState extends State<FailedResponsibilitiesScreen> {
  final Map<int, int> failedScores = {
    1: 0, // Never
    2: 5, // Once or twice
    3: 6, // Monthly
    4: 7, // Weekly
    5: 8, // Daily or almost daily
  };

  final Map<int, String> frequencyLabels = {
    0: 'Never',
    5: 'Once or twice',
    6: 'Monthly',
    7: 'Weekly',
    8: 'Daily or almost daily',
  };

  @override
  Widget build(BuildContext context) {
    final usedSubstancesLast3Months = widget.questionnaire.getUsedLast3Months();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.assessmentAccent.withOpacity(0.8),
                    AppColors.assessmentAccent,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.assessmentAccent.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text(
                    'During the past three months, how often have you failed to do what was normally expected of you because of your use of these substances?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Substances failed responsibilities
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: usedSubstancesLast3Months.length,
              itemBuilder: (context, index) {
                final substance = usedSubstancesLast3Months[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.assessmentAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${substance.name} ${substance.description}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    // Frequency buttons for failed responsibilities
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(5, (i) {
                          final buttonNumber = i + 1;
                          final score = failedScores[buttonNumber]!;
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    substance.failedResponsibilities = score;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: substance.failedResponsibilities == score
                                        ? AppColors.assessmentAccent
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.assessmentAccent,
                                      width: 2,
                                    ),
                                    boxShadow: substance.failedResponsibilities == score
                                        ? [
                                      BoxShadow(
                                        color: AppColors.assessmentAccent.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    buttonNumber.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: substance.failedResponsibilities == score
                                          ? Colors.white
                                          : AppColors.assessmentAccent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                frequencyLabels[score]!.split(' ')[0],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: substance.failedResponsibilities == score
                                      ? AppColors.assessmentAccent
                                      : AppColors.textSecondary,
                                  fontWeight: substance.failedResponsibilities == score
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Next button
            CustomButton(
              text: 'Next',
              onPressed: () {
                widget.onNext(widget.questionnaire);
              },
              variant: ButtonVariant.gradient,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
/// Question 6: Concern from Others
class ConcernScreen extends StatefulWidget {
  final AssistQuestionnaire questionnaire;
  final Function(AssistQuestionnaire) onNext;

  const ConcernScreen({
    Key? key,
    required this.questionnaire,
    required this.onNext,
  }) : super(key: key);

  @override
  State<ConcernScreen> createState() => _ConcernScreenState();
}

class _ConcernScreenState extends State<ConcernScreen> {
  @override
  Widget build(BuildContext context) {
    final usedSubstances = widget.questionnaire.getUsedSubstances();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.assessmentAccent.withOpacity(0.8),
                    AppColors.assessmentAccent,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.assessmentAccent.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text(
                    'Has a friend or relative or anyone else ever expressed concern about your use of these substances?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Substances concern
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: usedSubstances.length,
              itemBuilder: (context, index) {
                final substance = usedSubstances[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.assessmentAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${substance.name} ${substance.description}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Radio button options
                          _buildConcernOption(
                            substance,
                            0,
                            'No, never',
                            context,
                          ),

                          const SizedBox(height: 8),

                          _buildConcernOption(
                            substance,
                            6,
                            'Yes, in the past 3 months',
                            context,
                          ),

                          const SizedBox(height: 8),

                          _buildConcernOption(
                            substance,
                            3,
                            'Yes, but not in the past 3 months',
                            context,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Next button
            CustomButton(
              text: 'Next',
              onPressed: () {
                widget.onNext(widget.questionnaire);
              },
              variant: ButtonVariant.gradient,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildConcernOption(
      SubstanceData substance,
      int value,
      String label,
      BuildContext context,
      ) {
    final bool isSelected = substance.concernFromOthers == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          substance.concernFromOthers = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.assessmentAccent : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.assessmentAccent : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.assessmentAccent.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? Colors.white : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Question 7: Attempted to Cut Down
class CutDownScreen extends StatefulWidget {
  final AssistQuestionnaire questionnaire;
  final Function(AssistQuestionnaire) onNext;

  const CutDownScreen({
    Key? key,
    required this.questionnaire,
    required this.onNext,
  }) : super(key: key);

  @override
  State<CutDownScreen> createState() => _CutDownScreenState();
}

class _CutDownScreenState extends State<CutDownScreen> {
  @override
  Widget build(BuildContext context) {
    final usedSubstances = widget.questionnaire.getUsedSubstances();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.assessmentAccent.withOpacity(0.8),
                    AppColors.assessmentAccent,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.assessmentAccent.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text(
                    'Have you ever tried to cut down on using these substances but failed?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Substances cut down
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: usedSubstances.length,
              itemBuilder: (context, index) {
                final substance = usedSubstances[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.assessmentAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${substance.name} ${substance.description}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Radio button options
                          _buildCutDownOption(
                            substance,
                            0,
                            'No, never',
                            context,
                          ),

                          const SizedBox(height: 8),

                          _buildCutDownOption(
                            substance,
                            6,
                            'Yes, in the past 3 months',
                            context,
                          ),

                          const SizedBox(height: 8),

                          _buildCutDownOption(
                            substance,
                            3,
                            'Yes, but not in the past 3 months',
                            context,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Next button
            CustomButton(
              text: 'Next',
              onPressed: () {
                widget.onNext(widget.questionnaire);
              },
              variant: ButtonVariant.gradient,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCutDownOption(
      SubstanceData substance,
      int value,
      String label,
      BuildContext context,
      ) {
    final bool isSelected = substance.triedToControl == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          substance.triedToControl = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.assessmentAccent : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.assessmentAccent : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.assessmentAccent.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? Colors.white : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/// Question 8: Injection Use
class InjectionScreen extends StatefulWidget {
  final AssistQuestionnaire questionnaire;
  final Function(AssistQuestionnaire) onNext;

  const InjectionScreen({
    Key? key,
    required this.questionnaire,
    required this.onNext,
  }) : super(key: key);

  @override
  State<InjectionScreen> createState() => _InjectionScreenState();
}

class _InjectionScreenState extends State<InjectionScreen> {
  int? selectedOption;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.assessmentAccent.withOpacity(0.8),
                    AppColors.assessmentAccent,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.assessmentAccent.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text(
                    'Have you ever used any drug by injection?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '(Non-medical use only)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Injection options
            _buildInjectionOption(
              0,
              'No, never',
              context,
            ),

            const SizedBox(height: 16),

            _buildInjectionOption(
              1,
              'Yes, in the past 3 months',
              context,
            ),

            const SizedBox(height: 16),

            _buildInjectionOption(
              2,
              'Yes, but not in the past 3 months',
              context,
            ),

            // Frequency follow-up if yes in past 3 months
            if (selectedOption == 1) ...[
              const SizedBox(height: 24),

              const Text(
                'If it was in the past 3 months, how often?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              _buildInjectionFrequencyOption(
                1,
                'Less than 4 days per month',
                context,
              ),

              const SizedBox(height: 12),

              _buildInjectionFrequencyOption(
                2,
                'More than 4 days per month',
                context,
              ),
            ],

            const SizedBox(height: 32),

            // Next button
            CustomButton(
              text: 'Next',
              onPressed: () {
                if (selectedOption != null) {
                  for (var substance in widget.questionnaire.substances) {
                    substance.injected = selectedOption! > 0;
                  }
                  widget.onNext(widget.questionnaire);
                } else {
                  // Show error or prompt
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select an option'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              variant: ButtonVariant.gradient,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInjectionOption(
      int value,
      String label,
      BuildContext context,
      ) {
    final bool isSelected = selectedOption == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = value;
          if (value != 1) {
            // Reset injection frequency if not "Yes, in past 3 months"
            widget.questionnaire.substances.first.injectionFrequency = 0;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.assessmentAccent : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.assessmentAccent : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.assessmentAccent.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? Colors.white : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInjectionFrequencyOption(
      int value,
      String label,
      BuildContext context,
      ) {
    final bool isSelected = widget.questionnaire.substances.first.injectionFrequency == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          widget.questionnaire.substances.first.injectionFrequency = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.assessmentAccent : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.assessmentAccent : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.assessmentAccent.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? Colors.white : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}