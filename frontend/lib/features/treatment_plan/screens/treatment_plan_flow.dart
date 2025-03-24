// features/treatment_plan/screens/treatment_plan_flow.dart
import 'package:flutter/material.dart';
import '../../../core/models/treatment_plan_model.dart';
import '../../../core/services/api_data_service.dart';
import './plan_selection_screen.dart';
import './plan_detail_screen.dart';

class TreatmentPlanFlow extends StatefulWidget {
  final VoidCallback onComplete;

  const TreatmentPlanFlow({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<TreatmentPlanFlow> createState() => _TreatmentPlanFlowState();
}

class _TreatmentPlanFlowState extends State<TreatmentPlanFlow> {
  final ApiDataService _apiService = ApiDataService();
  bool _isLoading = false;

  void _selectPlan(TreatmentPlan plan) {
    setState(() {});

    // Navigate to plan detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanDetailScreen(
          plan: plan,
          onStartPlan: () {
            // Save plan to the backend
            _savePlanToDatabase(plan);
          },
        ),
      ),
    );
  }

  Future<void> _savePlanToDatabase(TreatmentPlan plan) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Save treatment plan using API service
      final success = await _apiService.selectTreatmentPlan(plan);

      if (!success) {
        throw Exception('Failed to save plan');
      }

      setState(() {
        _isLoading = false;
      });

      // Navigate to dashboard and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
            (route) => false,
        arguments: {
          'selectedPlan': plan,
          'startDate': DateTime.now(),
        },
      );

      // Call the onComplete callback
      widget.onComplete();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      print('Error saving treatment plan: $e');

      // Check if error message contains "already has a plan"
      if (e.toString().contains('already has a plan')) {
        // Show message that plan cannot be changed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You already have a selected treatment plan and cannot change it.'),
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate back
        Navigator.pop(context);
      } else {
        // Show general error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PlanSelectionScreen(
          onPlanSelected: _selectPlan,
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}