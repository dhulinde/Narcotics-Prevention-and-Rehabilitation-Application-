from rest_framework import serializers
from .models import ChatMessage

class ChatMessageSerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='_id', read_only=True)
    timestamp = serializers.DateTimeField(read_only=True, format='%Y-%m-%d %H:%M:%S')

    class Meta:
        model = ChatMessage
        fields = [
            'id', 'text', 'is_user_message', 'timestamp',
            'sentiment', 'emotions', 'triggers', 'topics'
        ]
        read_only_fields = [
            'id', 'timestamp', 'sentiment', 'emotions',
            'triggers', 'topics'
        ]

class ChatRequestSerializer(serializers.Serializer):
    message = serializers.CharField(required=True)