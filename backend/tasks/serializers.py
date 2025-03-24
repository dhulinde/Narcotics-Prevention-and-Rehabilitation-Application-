from rest_framework import serializers
from .models import Task, TaskCategory


class TaskSerializer(serializers.ModelSerializer):
    category_label = serializers.CharField(source='get_category_display', read_only=True)
    reminderTime = serializers.TimeField(source='reminder_time', format='%H:%M', required=False, allow_null=True)
    isCompleted = serializers.BooleanField(source='is_completed', read_only=False)
    id = serializers.CharField(source='_id', read_only=True)

    class Meta:
        model = Task
        fields = [
            'id', 'title', 'category', 'category_label', 'isCompleted',
            'reminderTime', 'note', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

class TaskCreateSerializer(serializers.ModelSerializer):
    reminder_time = serializers.TimeField(format='%H:%M', required=False, allow_null=True)

    class Meta:
        model = Task
        fields = ['title', 'category', 'is_completed', 'reminder_time', 'note']

    def validate_category(self, value):
        if value not in [choice[0] for choice in TaskCategory.choices]:
            raise serializers.ValidationError(f"Invalid category. Choose from {[choice[0] for choice in TaskCategory.choices]}")
        return value

    def create(self, validated_data):
        # The user is already being added in perform_create()
        # So we don't need to handle it here
        return Task.objects.create(**validated_data)

class TaskCompletionSerializer(serializers.Serializer):
    is_completed = serializers.BooleanField(required=True)