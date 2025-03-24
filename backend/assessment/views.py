from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework import viewsets
from django.shortcuts import get_object_or_404
from bson import ObjectId
from .models import Substance, AssistQuestionnaire
from .serializers import (
    SubstanceSerializer, AssistQuestionnaireSerializer,
    AssistQuestionnaireSubmitSerializer, AssessmentAnalysisSerializer,
    TreatmentPlanRecommendationSerializer
)
from .ml_integration import AssessmentMLService


class SubstanceViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Substance.objects.all()
    serializer_class = SubstanceSerializer
    permission_classes = [permissions.IsAuthenticated]


class AssistQuestionnaireViewSet(viewsets.ModelViewSet):
    serializer_class = AssistQuestionnaireSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return AssistQuestionnaire.objects.filter(user=self.request.user).order_by('-date_completed')

    def get_serializer_class(self):
        if self.action in ['create', 'submit']:
            return AssistQuestionnaireSubmitSerializer
        return AssistQuestionnaireSerializer

    def get_object(self):
        """
        Override get_object to handle MongoDB ObjectIds in the URL
        """
        queryset = self.filter_queryset(self.get_queryset())

        # Get the lookup value from the URL
        lookup_url_kwarg = self.lookup_url_kwarg or self.lookup_field
        lookup_value = self.kwargs[lookup_url_kwarg]

        # Try to convert to ObjectId if it's a string
        try:
            if isinstance(lookup_value, str) and len(lookup_value) == 24:
                lookup_value = ObjectId(lookup_value)
        except:
            pass

        filter_kwargs = {self.lookup_field: lookup_value}
        obj = get_object_or_404(queryset, **filter_kwargs)

        # Check permissions
        self.check_object_permissions(self.request, obj)

        return obj

    @action(detail=False, methods=['post'])
    def submit(self, request):
        """Submit a new ASSIST questionnaire"""
        try:
            serializer = self.get_serializer(data=request.data, context={'request': request})

            if not serializer.is_valid():
                print("Validation errors:", serializer.errors)
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

            questionnaire = serializer.save()

            # Mark screening as completed in user model
            user = request.user
            if not user.recovery_start_date:
                user.recovery_start_date = questionnaire.date_completed
                user.save()

            # Get ML-based assessment analysis
            analysis = AssessmentMLService.analyze_questionnaire(questionnaire)

            # Get treatment plan recommendation
            plan_recommendation = AssessmentMLService.predict_treatment_plan(
                questionnaire,
                {'user_id': str(user._id), 'username': user.username}
            )

            # Serialize the response data
            questionnaire_data = AssistQuestionnaireSerializer(questionnaire).data
            analysis_data = AssessmentAnalysisSerializer(analysis).data
            plan_data = plan_recommendation

            response_data = {
                'questionnaire': questionnaire_data,
                'analysis': analysis_data,
                'plan_recommendation': plan_data
            }

            return Response(response_data, status=status.HTTP_201_CREATED)
        except Exception as e:
            import traceback
            traceback.print_exc()
            return Response({"detail": str(e)}, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'])
    def latest(self, request):
        """Get the user's latest questionnaire with analysis"""
        questionnaire = self.get_queryset().first()
        if not questionnaire:
            return Response({"detail": "No questionnaire found."}, status=status.HTTP_404_NOT_FOUND)

        serializer = self.get_serializer(questionnaire)

        # Get ML-based assessment analysis
        analysis = AssessmentMLService.analyze_questionnaire(questionnaire)

        # Get treatment plan recommendation
        plan_recommendation = AssessmentMLService.predict_treatment_plan(
            questionnaire,
            {'user_id': str(request.user._id), 'username': request.user.username}
        )

        response_data = {
            'questionnaire': serializer.data,
            'analysis': analysis,
            'plan_recommendation': plan_recommendation
        }

        return Response(response_data)

    @action(detail=False, methods=['get'])
    def has_completed(self, request):
        """Check if the user has completed a questionnaire"""
        has_completed = self.get_queryset().exists()
        return Response({"has_completed": has_completed})

    @action(detail=True, methods=['get'])
    def analysis(self, request, pk=None):
        """Get detailed ML analysis for a specific questionnaire"""
        questionnaire = self.get_object()

        # Get ML-based assessment analysis
        analysis = AssessmentMLService.analyze_questionnaire(questionnaire)

        return Response(analysis)

    @action(detail=False, methods=['get'])
    def status(self, request):
        """Get user assessment status for app navigation"""
        has_completed = self.get_queryset().exists()

        return Response({
            "hasCompleted": has_completed,
            "totalCompletedCount": self.get_queryset().count()
        })