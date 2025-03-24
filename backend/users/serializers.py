from rest_framework import serializers
from .models import User, UserPreference
from bson import ObjectId


class ObjectIdField(serializers.Field):
    """Field for handling MongoDB ObjectIds"""

    def to_representation(self, value):
        return str(value)

    def to_internal_value(self, data):
        try:
            return ObjectId(data)
        except (TypeError, ValueError):
            raise serializers.ValidationError(f"Invalid ObjectId: {data}")


class UserPreferenceSerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='_id', read_only=True)

    class Meta:
        model = UserPreference
        fields = ['id', 'dark_mode', 'notifications_enabled', 'theme_color']


class UserSerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='_id', read_only=True)
    preferences = UserPreferenceSerializer(read_only=True)

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'display_name', 'profile_image',
            'date_of_birth', 'recovery_start_date', 'preferences'
        ]
        read_only_fields = ['id']


class UserCreateSerializer(serializers.ModelSerializer):
    password_confirm = serializers.CharField(write_only=True)
    security_question = serializers.CharField(required=True)
    security_answer = serializers.CharField(required=True, write_only=True)

    class Meta:
        model = User
        fields = [
            'username', 'email', 'password', 'password_confirm',
            'security_question', 'security_answer'
        ]
        extra_kwargs = {
            'password': {'write_only': True},
        }

    def validate(self, data):
        if data['password'] != data.pop('password_confirm'):
            raise serializers.ValidationError({"password_confirm": "Passwords do not match."})
        return data

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email'),
            password=validated_data['password'],
            security_question=validated_data['security_question'],
            security_answer=validated_data['security_answer'],
        )

        # Create user preferences
        UserPreference.objects.create(user=user)

        return user


class PasswordResetRequestSerializer(serializers.Serializer):
    username = serializers.CharField()


class SecurityAnswerVerifySerializer(serializers.Serializer):
    username = serializers.CharField()
    answer = serializers.CharField()


class PasswordResetSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
    password_confirm = serializers.CharField(write_only=True)

    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError({"password_confirm": "Passwords do not match."})
        return data


class UserProfileUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['display_name', 'profile_image', 'date_of_birth', 'email']


class TokenResponseSerializer(serializers.Serializer):
    access = serializers.CharField()
    refresh = serializers.CharField()
    user = UserSerializer()
    has_completed_assessment = serializers.BooleanField(default=False)
    has_treatment_plan = serializers.BooleanField(default=False)