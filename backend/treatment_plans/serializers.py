# treatment_plans/serializers.py
from rest_framework import serializers
from bson import ObjectId
from .models import TreatmentPlan, PlanActivity, UserTreatmentPlan


class PlanActivitySerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='_id', read_only=True)

    class Meta:
        model = PlanActivity
        fields = ['id', 'title', 'description', 'icon']


class TreatmentPlanSerializer(serializers.ModelSerializer):
    activities = PlanActivitySerializer(many=True, read_only=True)
    id = serializers.CharField(source='_id', read_only=True)

    class Meta:
        model = TreatmentPlan
        fields = ['id', 'name', 'description', 'duration', 'intensity', 'color', 'icon', 'activities']


class UserTreatmentPlanSerializer(serializers.ModelSerializer):
    plan = TreatmentPlanSerializer(read_only=True)
    plan_id = serializers.CharField(write_only=True, required=False)
    id = serializers.CharField(source='_id', read_only=True)
    start_date = serializers.DateTimeField(read_only=True)

    class Meta:
        model = UserTreatmentPlan
        fields = ['id', 'user', 'plan', 'plan_id', 'start_date']
        read_only_fields = ['user', 'start_date']

    def create(self, validated_data):
        user = self.context['request'].user
        plan_id = validated_data.pop('plan_id')

        # Try to get plan, handling ObjectId conversion
        try:
            plan = TreatmentPlan.objects.get(_id=ObjectId(plan_id))
        except:
            # If conversion fails, try with the string
            plan = TreatmentPlan.objects.get(_id=plan_id)

        # Check if user already has a treatment plan
        if UserTreatmentPlan.objects.filter(user=user).exists():
            raise serializers.ValidationError("User already has a treatment plan.")

        return UserTreatmentPlan.objects.create(user=user, plan=plan)