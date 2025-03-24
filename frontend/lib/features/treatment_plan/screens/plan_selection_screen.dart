// features/treatment_plan/screens/plan_selection_screen.dart
import 'package:flutter/material.dart';
import '../../../core/models/treatment_plan_model.dart';
import '../widgets/plan_button.dart';

class PlanSelectionScreen extends StatelessWidget {
  final Function(TreatmentPlan) onPlanSelected;

  const PlanSelectionScreen({
    Key? key,
    required this.onPlanSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final plans = TreatmentPlanService.getPlans();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Choose Your Plan',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Select the plan that best suits your recovery journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.separated(
                  itemCount: plans.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return PlanButton(
                      plan: plan,
                      onTap: () => onPlanSelected(plan),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}