from rest_framework import serializers
from .models import MoodEntry, JournalEntry, MoodType

class MoodEntrySerializer(serializers.ModelSerializer):
    mood_display = serializers.CharField(source='get_mood_display', read_only=True)
    date = serializers.DateTimeField(read_only=True)
    id = serializers.CharField(source='_id', read_only=True)

    class Meta:
        model = MoodEntry
        fields = ['id', 'date', 'mood', 'mood_display', 'note']
        read_only_fields = ['id', 'date']

    def validate_mood(self, value):
        if value not in [choice[0] for choice in MoodType.choices]:
            raise serializers.ValidationError(f"Invalid mood. Choose from {[choice[0] for choice in MoodType.choices]}")
        return value

class JournalEntrySerializer(serializers.ModelSerializer):
    date = serializers.DateTimeField(read_only=True)
    id = serializers.CharField(source='_id', read_only=True)

    class Meta:
        model = JournalEntry
        fields = ['id', 'date', 'text']
        read_only_fields = ['id', 'date']

class MoodStatsSerializer(serializers.Serializer):
    average_mood = serializers.ChoiceField(choices=MoodType.choices)
    best_day = MoodEntrySerializer(allow_null=True)
    worst_day = MoodEntrySerializer(allow_null=True)
    mood_distribution = serializers.DictField(
        child=serializers.IntegerField(),
        help_text="Distribution of moods in the specified time period."
    )