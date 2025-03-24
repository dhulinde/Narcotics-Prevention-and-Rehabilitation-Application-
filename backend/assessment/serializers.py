from rest_framework import serializers
from bson import ObjectId
from django.core.exceptions import ValidationError as DjangoValidationError
from .models import Substance, SubstanceResponse, AssistQuestionnaire


class ObjectIdField(serializers.Field):
    """Field that can handle MongoDB ObjectIds with robust validation"""

    def to_representation(self, value):
        return str(value)

    def to_internal_value(self, data):
        if data is None:
            return None

        # If it's already an ObjectId, return it
        if isinstance(data, ObjectId):
            return data

        # If it's a string, try multiple approaches
        if isinstance(data, str):
            # First, try direct ObjectId conversion if it looks like a valid hex
            if len(data) == 24 and all(c in '0123456789abcdefABCDEF' for c in data):
                try:
                    return ObjectId(data)
                except:
                    pass

            # If not a valid hex, try to find the substance by name
            try:
                substance = Substance.objects.get(name__iexact=data)
                return substance._id
            except Substance.DoesNotExist:
                pass

        # If all else fails, raise a validation error
        raise serializers.ValidationError(f"Invalid ObjectId or substance name: {data}")


class SubstanceSerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='_id', read_only=True)

    class Meta:
        model = Substance
        fields = ['id', 'name', 'description']


class SubstanceResponseSerializer(serializers.ModelSerializer):
    substance_name = serializers.ReadOnlyField(source='substance.name')
    substance_description = serializers.ReadOnlyField(source='substance.description')
    id = serializers.CharField(source='_id', read_only=True)
    substance = ObjectIdField()  # Use our more robust custom field here

    class Meta:
        model = SubstanceResponse
        fields = [
            'id', 'substance', 'substance_name', 'substance_description', 'used_in_lifetime',
            'frequency_last_3_months', 'urge_to_use', 'health_social_problems',
            'failed_responsibilities', 'concern_from_others', 'tried_to_control',
            'injected', 'injection_frequency', 'calculated_score', 'risk_level'
        ]
        read_only_fields = ['calculated_score', 'risk_level']


class AssistQuestionnaireSerializer(serializers.ModelSerializer):
    substance_responses = SubstanceResponseSerializer(many=True, read_only=True)
    id = serializers.CharField(source='_id', read_only=True)

    class Meta:
        model = AssistQuestionnaire
        fields = ['id', 'user', 'date_completed', 'overall_risk_level', 'highest_score',
                  'other_substance_specify', 'substance_responses']
        read_only_fields = ['user', 'date_completed', 'overall_risk_level', 'highest_score']


class AssistQuestionnaireSubmitSerializer(serializers.ModelSerializer):
    substance_responses = serializers.ListField(required=True)
    other_substance_specify = serializers.CharField(required=False, allow_blank=True, allow_null=True)

    class Meta:
        model = AssistQuestionnaire
        fields = ['other_substance_specify', 'substance_responses']

    def create(self, validated_data):
        substance_responses_data = validated_data.pop('substance_responses')
        user = self.context['request'].user

        # Debug the incoming data
        print("Substance responses data:", substance_responses_data)

        # Calculate highest score
        highest_score = 0
        processed_responses_data = []

        for response_data in substance_responses_data:
            # Print the full response data to debug
            print("Response data:", response_data)

            # Handle substance identification
            substance_identifier = response_data.get('substance')

            # If substance is None, try to find alternatives
            if substance_identifier is None:
                # Try to get substance by name if available
                substance_name = response_data.get('substance_name')
                if substance_name:
                    try:
                        substance = Substance.objects.get(name__iexact=substance_name)
                    except Substance.DoesNotExist:
                        # If not found by name, get the first substance as fallback
                        # This is just a temporary workaround
                        try:
                            substance = Substance.objects.first()
                            if not substance:
                                raise Substance.DoesNotExist("No substances available")
                        except Substance.DoesNotExist:
                            raise serializers.ValidationError("No substances found in the database")
                else:
                    # If no name, try to find by other fields
                    try:
                        # Get the first substance as fallback
                        substance = Substance.objects.first()
                        if not substance:
                            raise Substance.DoesNotExist("No substances available")
                    except Substance.DoesNotExist:
                        raise serializers.ValidationError("No substances found in the database")
            else:
                # Try to get the substance by ID
                try:
                    substance = Substance.objects.get(_id=ObjectId(substance_identifier))
                except (Substance.DoesNotExist, ValueError, TypeError):
                    # If failed, try to get the first substance as fallback
                    try:
                        substance = Substance.objects.first()
                        if not substance:
                            raise Substance.DoesNotExist("No substances available")
                    except Substance.DoesNotExist:
                        raise serializers.ValidationError(
                            f"Substance with identifier {substance_identifier} not found and no fallback available")

            # Create standardized field names (convert camelCase to snake_case)
            field_mapping = {
                # Frontend (camelCase) -> Backend (snake_case)
                'usedInLifetime': 'used_in_lifetime',
                'frequencyLast3Months': 'frequency_last_3_months',
                'urgeToUse': 'urge_to_use',
                'healthSocialProblems': 'health_social_problems',
                'failedResponsibilities': 'failed_responsibilities',
                'concernFromOthers': 'concern_from_others',
                'triedToControl': 'tried_to_control',
                'injected': 'injected',
                'injectionFrequency': 'injection_frequency'
            }

            normalized_data = {}

            # Map frontend fields to backend fields
            for frontend_key, backend_key in field_mapping.items():
                if frontend_key in response_data:
                    normalized_data[backend_key] = response_data[frontend_key]
                elif backend_key in response_data:
                    normalized_data[backend_key] = response_data[backend_key]

            # Ensure we have default values for missing fields
            required_fields = {
                'used_in_lifetime': False,
                'frequency_last_3_months': 0,
                'urge_to_use': 0,
                'health_social_problems': 0,
                'failed_responsibilities': 0,
                'concern_from_others': 0,
                'tried_to_control': 0,
                'injected': False,
                'injection_frequency': 0
            }

            for field, default_value in required_fields.items():
                if field not in normalized_data:
                    normalized_data[field] = default_value

            # Create a temporary SubstanceResponse to calculate score
            temp_response = SubstanceResponse(
                substance=substance,
                **normalized_data
            )

            # Calculate and set the score
            calculated_score = temp_response.calculate_score()
            normalized_data['calculated_score'] = calculated_score
            normalized_data['risk_level'] = temp_response.determine_risk_level()
            normalized_data['substance'] = substance

            # Update highest score
            if calculated_score > highest_score:
                highest_score = calculated_score

            processed_responses_data.append(normalized_data)

        # Determine overall risk level
        overall_risk_level = 'low'
        if highest_score >= 27:
            overall_risk_level = 'high'
        elif highest_score >= 4:
            overall_risk_level = 'moderate'

        # Create questionnaire
        questionnaire = AssistQuestionnaire.objects.create(
            user=user,
            highest_score=highest_score,
            overall_risk_level=overall_risk_level,
            **validated_data
        )

        # Create substance responses with pre-calculated scores
        for response_data in processed_responses_data:
            substance = response_data.pop('substance')
            SubstanceResponse.objects.create(
                questionnaire=questionnaire,
                substance=substance,
                **response_data
            )

        return questionnaire


class AssessmentAnalysisSerializer(serializers.Serializer):
    features = serializers.DictField()
    recommendations = serializers.ListField(child=serializers.DictField())
    followup_schedule = serializers.DictField()


class TreatmentPlanRecommendationSerializer(serializers.Serializer):
    recommended_plan = serializers.CharField()
    confidence = serializers.FloatField()
    reasons = serializers.ListField(child=serializers.CharField())