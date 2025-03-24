from datetime import datetime, timedelta
from django.utils import timezone
from rest_framework import viewsets, status, permissions
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate
from bson import ObjectId
from django.shortcuts import get_object_or_404
from .models import User, UserPreference
from .serializers import (
    UserSerializer, UserCreateSerializer, PasswordResetRequestSerializer,
    SecurityAnswerVerifySerializer, PasswordResetSerializer, UserProfileUpdateSerializer,
    UserPreferenceSerializer, TokenResponseSerializer
)


class UserViewSet(viewsets.ModelViewSet):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return User.objects.all()

    def get_serializer_class(self):
        if self.action == 'create':
            return UserCreateSerializer
        elif self.action == 'profile_update':
            return UserProfileUpdateSerializer
        return UserSerializer

    def get_permissions(self):
        if self.action in ['create', 'check_username', 'login', 'reset_password_request',
                           'verify_security_answer', 'reset_password', 'logout']:
            return [permissions.AllowAny()]
        return super().get_permissions()

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
    def login(self, request):
        """Login endpoint to authenticate users and generate tokens"""
        username = request.data.get('username')
        password = request.data.get('password')

        if not username or not password:
            return Response({'error': 'Username and password are required'},
                            status=status.HTTP_400_BAD_REQUEST)

        user = authenticate(username=username, password=password)

        if user:
            # Generate tokens
            refresh = RefreshToken.for_user(user)

            # Update token info on user model
            user.last_login = timezone.now()
            user.refresh_token = str(refresh)
            user.refresh_token_exp = timezone.now() + timedelta(days=7)
            user.save()

            # Check if user has completed assessment
            from assessment.models import AssistQuestionnaire
            has_completed_assessment = AssistQuestionnaire.objects.filter(user=user).exists()

            # Check if user has selected a treatment plan
            from treatment_plans.models import UserTreatmentPlan
            has_treatment_plan = UserTreatmentPlan.objects.filter(user=user).exists()

            # Add these flags to the response
            response_data = {
                'access': str(refresh.access_token),
                'refresh': str(refresh),
                'user': UserSerializer(user).data,
                'has_completed_assessment': has_completed_assessment,
                'has_treatment_plan': has_treatment_plan
            }

            return Response(response_data)

        return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)

    @action(detail=False, methods=['post'])
    def logout(self, request):
        """
        Logout endpoint that invalidates the user's current refresh token
        """
        refresh_token = request.data.get('refresh')

        if not refresh_token:
            return Response({'error': 'Refresh token is required'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Get the user from the token
            token = RefreshToken(refresh_token)
            user_id = token.payload.get('user_id')

            # Invalidate the token by clearing it from the user record
            user = User.objects.get(_id=user_id)
            user.refresh_token = None
            user.refresh_token_exp = None
            user.token_updated_at = timezone.now()
            user.save()

            return Response({'detail': 'Successfully logged out'}, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['post'])
    def check_username(self, request):
        """Check if a username already exists"""
        username = request.data.get('username')
        if not username:
            return Response({'error': 'Username is required'}, status=status.HTTP_400_BAD_REQUEST)

        exists = User.objects.filter(username=username).exists()
        return Response({'exists': exists})

    @action(detail=False, methods=['post'])
    def reset_password_request(self, request):
        """Initiate password reset by retrieving security question"""
        serializer = PasswordResetRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            user = User.objects.get(username=serializer.validated_data['username'])
            return Response({
                'username': user.username,
                'security_question': user.security_question
            })
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=False, methods=['post'])
    def verify_security_answer(self, request):
        """Verify security answer for password reset"""
        serializer = SecurityAnswerVerifySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            user = User.objects.get(username=serializer.validated_data['username'])

            # Case-insensitive comparison of answers
            if user.security_answer.lower() == serializer.validated_data['answer'].lower():
                return Response({'verified': True})

            return Response({'verified': False}, status=status.HTTP_400_BAD_REQUEST)
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=False, methods=['post'])
    def reset_password(self, request):
        """Reset user password after security verification"""
        serializer = PasswordResetSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            user = User.objects.get(username=serializer.validated_data['username'])
            user.set_password(serializer.validated_data['password'])
            user.token_updated_at = timezone.now()  # Invalidate existing tokens
            user.save()

            return Response({'success': True})
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=False, methods=['get', 'patch'])
    def profile(self, request):
        """Get or update user profile"""
        user = request.user

        if request.method == 'GET':
            serializer = self.get_serializer(user)
            return Response(serializer.data)

        serializer = UserProfileUpdateSerializer(user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def get_by_username(self, request, pk=None):
        """Get user by username"""
        try:
            user = User.objects.get(username=pk)
            serializer = self.get_serializer(user)
            return Response(serializer.data)
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=False, methods=['get'])
    def status(self, request):
        """Get user's assessment and treatment plan status"""
        user = request.user

        # Check if user has completed assessment
        from assessment.models import AssistQuestionnaire
        has_completed_assessment = AssistQuestionnaire.objects.filter(user=user).exists()

        # Check if user has selected a treatment plan
        from treatment_plans.models import UserTreatmentPlan
        has_treatment_plan = UserTreatmentPlan.objects.filter(user=user).exists()

        return Response({
            'has_completed_assessment': has_completed_assessment,
            'has_treatment_plan': has_treatment_plan
        })

    @action(detail=False, methods=['get', 'put', 'patch'])
    def preferences(self, request):
        """Get or update user preferences"""
        user = request.user
        preference, created = UserPreference.objects.get_or_create(user=user)

        if request.method == 'GET':
            serializer = UserPreferenceSerializer(preference)
            return Response(serializer.data)

        serializer = UserPreferenceSerializer(preference, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response(serializer.data)