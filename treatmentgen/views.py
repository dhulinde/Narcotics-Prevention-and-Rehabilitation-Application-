# from django.shortcuts import render
# from django.shortcuts import get_object_or_404
# from django.db.models import Q
# from rest_framework import viewsets, permissions, status
# from rest_framework.decorators import action
# from rest_framework.response import Response
# from datetime import datetime, timedelta
# from .models import TreatmentPlan, PatientTreatment, ProgressReport, Substance
# from .serializers import (
#     TreatmentPlanSerializer, 
#     PatientTreatmentSerializer,
#     ProgressReportSerializer,
#     SubstanceSerializer
# )

# class TreatmentPlanViewSet(viewsets.ModelViewSet):
#     queryset = TreatmentPlan.objects.all()
#     serializer_class = TreatmentPlanSerializer
#     permission_classes = [permissions.IsAuthenticated]

#     @action(detail=False, methods=['post'])
#     def generate_plan(self, request):
#         risk_level = request.data.get('risk_level')
#         substance = request.data.get('substance')
        
#         if not risk_level or not substance:
#             return Response({
#                 'error': 'Risk level and substance are required'
#             }, status=400)
            
#         # Check for existing plan or create new one
#         plan = TreatmentPlan.objects.filter(
#             risk_level=risk_level,
#             primary_substance=substance
#         ).first()
        
#         if not plan:
#             plan = TreatmentPlan.create_default_plan(risk_level, substance)
            
#         return Response(TreatmentPlanSerializer(plan).data)

# class SubstanceViewSet(viewsets.ModelViewSet):
#     queryset = Substance.objects.all()
#     serializer_class = SubstanceSerializer
#     permission_classes = [permissions.IsAuthenticated]

# class ProgressReportViewSet(viewsets.ModelViewSet):
#     queryset = ProgressReport.objects.all()
#     serializer_class = ProgressReportSerializer
#     permission_classes = [permissions.IsAuthenticated]

#     def get_queryset(self):
#         return ProgressReport.objects.filter(
#             patient_treatment__patient=self.request.user
#         )

#     @action(detail=False, methods=['get'])
#     def weekly_summary(self, request):
#         last_week = datetime.now().date() - timedelta(days=7)
#         reports = self.get_queryset().filter(report_date__gte=last_week)
        
#         summary = {
#             'average_mood': sum(r.mood_rating for r in reports) / len(reports) if reports else 0,
#             'average_craving': sum(r.craving_intensity for r in reports) / len(reports) if reports else 0,
#             'completed_activities': sum(len(r.activities_completed) for r in reports),
#             'reports_submitted': len(reports)
#         }
        
#         return Response(summary)

# class TreatmentPlanViewSet(viewsets.ModelViewSet):
#     queryset = TreatmentPlan.objects.all()
#     serializer_class = TreatmentPlanSerializer
#     permission_classes = [permissions.IsAuthenticated]

#     @action(detail=True, methods=['patch'])
#     def modify_plan(self, request, pk=None):
#         plan = self.get_object()
#         if not request.user.is_staff:  # Only allow healthcare providers to modify
#             return Response(
#                 {'error': 'Only healthcare providers can modify plans'},
#                 status=status.HTTP_403_FORBIDDEN
#             )
            
#         serializer = TreatmentPlanSerializer(
#             plan,
#             data=request.data,
#             partial=True
#         )
#         if serializer.is_valid():
#             serializer.save()
#             return Response(serializer.data)
#         return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

#     @action(detail=False, methods=['post'])
#     def generate_customized_plan(self, request):
#         risk_level = request.data.get('risk_level')
#         substance_id = request.data.get('substance_id')
        
#         if not risk_level or not substance_id:
#             return Response({
#                 'error': 'Risk level and substance are required'
#             }, status=status.HTTP_400_BAD_REQUEST)
            
#         substance = get_object_or_404(Substance, id=substance_id)
        
#         # Create customized plan based on substance
#         custom_plan = TreatmentPlan.create_default_plan(
#             risk_level=risk_level,
#             substance=substance.name
#         )
        
#         # Customize plan based on substance specifics
#         custom_plan.daily_exercises.update(substance.recommended_activities)
#         custom_plan.save()
        
#         return Response(TreatmentPlanSerializer(custom_plan).data)

#adjusted to just test treatment generator

# from rest_framework import viewsets
# from rest_framework.decorators import action
# from rest_framework.response import Response
# from models import Assessment
# from models import TreatmentPlan
# from serializers import AssessmentSerializer

# class AssessmentViewSet(viewsets.ModelViewSet):
#     queryset = Assessment.objects.all()
#     serializer_class = AssessmentSerializer
    
#     @action(detail=True, methods=['post'])
#     def generate_treatment_plan(self, request, pk=None):
#         assessment = self.get_object()
#         treatment_plan = TreatmentPlan.create_from_assessment(assessment)
        
#         return Response({
#             'assessment_id': assessment.id,
#             'score': assessment.score,
#             'risk_level': assessment.determine_risk_level(),
#             'treatment_plan': TreatmentPlanSerializer(treatment_plan).data
#         })
    

from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from rest_framework.permissions import IsAuthenticated
from serializers import TreatmentPlanSerializer, AssessmentSerializer, PatientTreatmentSerializer
from models import TreatmentPlan, Assessment, PatientTreatment

class ScreeningTestViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    queryset = Assessment.objects.all()
    serializer_class = AssessmentSerializer

    @action(detail=False, methods=['post'])
    def submit_screening(self, request):
        try:
            # Get answers from request
            answers = request.data.get('answers', [])
            
            # Calculate score based on answers
            # Adjust the scoring logic based on your screening test
            score = self.calculate_screening_score(answers)
            
            # Create assessment record
            assessment = Assessment.objects.create(
                user=request.user,
                score=score
            )
            
            # Generate treatment plan automatically
            treatment_plan = TreatmentPlan.create_from_assessment(assessment)
            
            # Create patient treatment record
            patient_treatment = PatientTreatment.objects.create(
                patient=request.user,
                treatment_plan=treatment_plan
            )

            return Response({
                'assessment_id': assessment.id,
                'score': score,
                'risk_level': assessment.determine_risk_level(),
                'treatment_plan': {
                    'id': treatment_plan.id,
                    'title': treatment_plan.title,
                    'morning_routine': treatment_plan.morning_routine,
                    'daily_activities': treatment_plan.daily_activities,
                    'evening_routine': treatment_plan.evening_routine,
                    'weekly_activities': treatment_plan.weekly_activities,
                    'support_meetings': treatment_plan.support_meetings
                }
            }, status=status.HTTP_201_CREATED)

        except Exception as e:
            return Response({
                'error': str(e)
            }, status=status.HTTP_400_BAD_REQUEST)

    def calculate_screening_score(self, answers):
        """
        Calculate score based on screening test answers
        Adjust this logic based on your specific scoring criteria
        """
        # Example scoring logic
        total_questions = len(answers)
        if total_questions == 0:
            return 0
            
        # Convert answers to numerical values and calculate score
        score = sum(int(answer) for answer in answers) / total_questions * 100
        return min(100, max(0, round(score)))  # Ensure score is between 0-100

class TreatmentPlanViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    queryset = TreatmentPlan.objects.all()
    serializer_class = TreatmentPlanSerializer

    @action(detail=False, methods=['get'])
    def current_plan(self, request):
        """Get current user's active treatment plan"""
        try:
            patient_treatment = PatientTreatment.objects.filter(
                patient=request.user
            ).latest('assigned_at')
            
            treatment_plan = patient_treatment.treatment_plan
            
            return Response({
                'plan_id': treatment_plan.id,
                'title': treatment_plan.title,
                'risk_level': treatment_plan.risk_level,
                'morning_routine': treatment_plan.morning_routine,
                'daily_activities': treatment_plan.daily_activities,
                'evening_routine': treatment_plan.evening_routine,
                'weekly_activities': treatment_plan.weekly_activities,
                'support_meetings': treatment_plan.support_meetings
            })
            
        except PatientTreatment.DoesNotExist:
            return Response({
                'error': 'No active treatment plan found'
            }, status=status.HTTP_404_NOT_FOUND)

class PatientTreatmentViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = PatientTreatmentSerializer

    def get_queryset(self):
        # If user is staff, they can see all treatments
        if self.request.user.is_staff:
            return PatientTreatment.objects.all()
        # Regular users can only see their own treatments
        return PatientTreatment.objects.filter(patient=self.request.user)

    @action(detail=False, methods=['get'])
    def active_treatment(self, request):
        """Get user's active treatment plan"""
        treatment = PatientTreatment.objects.filter(
            patient=request.user,
            is_active=True
        ).first()
        
        if not treatment:
            return Response({
                'error': 'No active treatment found'
            }, status=status.HTTP_404_NOT_FOUND)
            
        serializer = self.get_serializer(treatment)
        return Response(serializer.data)

