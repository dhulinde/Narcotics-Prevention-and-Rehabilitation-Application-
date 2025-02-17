# from rest_framework import serializers
# from .models import TreatmentPlan, PatientTreatment, ProgressReport, Substance

# class SubstanceSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = Substance
#         fields = '__all__'

# class ProgressReportSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = ProgressReport
#         fields = '__all__'

# class TreatmentPlanSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = TreatmentPlan
#         fields = '__all__'

#     def validate(self, data):
#         # Ensure all required components are present
#         required_fields = ['daily_exercises', 'weekly_exercises', 'coping_strategies']
#         for field in required_fields:
#             if field not in data:
#                 raise serializers.ValidationError(f"{field} is required")
#         return data

# class PatientTreatmentSerializer(serializers.ModelSerializer):
#     progress_reports = ProgressReportSerializer(many=True, read_only=True)
    
#     class Meta:
#         model = PatientTreatment
#         fields = '__all__'


from rest_framework import serializers
#from models import Assessment, PatientTreatment, TreatmentPlan
from models import *

class AssessmentSerializer(serializers.ModelSerializer):
    risk_level = serializers.CharField(source='determine_risk_level', read_only=True)
    
    class Meta:
        model = Assessment
        fields = ['id', 'user', 'score', 'risk_level', 'created_at']

class TreatmentPlanSerializer(serializers.ModelSerializer):
    class Meta:
        model = TreatmentPlan
        fields = '__all__'
    
class PatientTreatmentSerializer(serializers.ModelSerializer):
    treatment_plan = TreatmentPlanSerializer(read_only=True)
    patient_username = serializers.CharField(source='patient.username', read_only=True)

    class Meta:
        model = PatientTreatment
        fields = ['id', 'patient', 'patient_username', 'treatment_plan', 
                 'assigned_at', 'is_active', 'notes']