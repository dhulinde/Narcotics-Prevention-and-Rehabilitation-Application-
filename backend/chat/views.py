from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import ChatMessage
from .serializers import ChatMessageSerializer, ChatRequestSerializer
from .openai_integration import OpenAIService
from .services import ChatAnalysisService
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from django.core.exceptions import ObjectDoesNotExist
from bson.errors import InvalidId
from django.http import Http404
from .gemini_integration import GeminiService
from django.conf import settings
import traceback
import logging

logger = logging.getLogger(__name__)

class ChatMessageViewSet(viewsets.ModelViewSet):
    serializer_class = ChatMessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    queryset = ChatMessage.objects.all()

    def get_queryset(self):
        return ChatMessage.objects.filter(user=self.request.user)

    @action(detail=False, methods=['post'])
    def send(self, request):
        try:
            serializer = ChatRequestSerializer(data=request.data)
            if not serializer.is_valid():
                return Response({
                    'success': False,
                    'message': 'Invalid data provided',
                    'errors': serializer.errors
                }, status=status.HTTP_400_BAD_REQUEST)

            user_message_text = serializer.validated_data['message']

            # Analyze user message - use OpenAI or Gemini based on available API key
            if settings.GEMINI_API_KEY:
                analysis = GeminiService.analyze_message(user_message_text)
            else:
                analysis = OpenAIService.analyze_message(user_message_text)

            # Save user message to database
            user_message = ChatMessage.objects.create(
                user=request.user,
                text=user_message_text,
                is_user_message=True,
                sentiment=analysis.get('sentiment'),
                emotions=analysis.get('emotions'),
                triggers=analysis.get('triggers'),
                topics=analysis.get('topics')
            )

            # Check for crisis indicators
            crisis_assessment = ChatAnalysisService.get_crisis_level(user_message)
            crisis_response = None

            if crisis_assessment['crisis_level'] != 'none':
                # Generate crisis response
                crisis_response = crisis_assessment['recommendation']['message']

                # If immediate action needed and it's high crisis, potentially notify admin/support
                if crisis_assessment['crisis_level'] == 'high' and crisis_assessment['recommendation'][
                    'immediate_action']:
                    # In a real system, you might trigger a notification here
                    pass

            # Get chat history
            chat_history = self.get_queryset().order_by('-timestamp')[:20]  # Get last 20 messages
            chat_history = list(reversed(chat_history))  # Reverse to get chronological order

            # Get response from AI (OpenAI or Gemini based on available API key)
            if crisis_response:
                # Add crisis resources to response
                resources = crisis_assessment['recommendation']['resources']
                resource_text = "\n\n" + "\n".join(resources) if resources else ""
                bot_response = crisis_response + resource_text
            else:
                # Get normal response
                if settings.GEMINI_API_KEY:
                    bot_response = GeminiService.get_chat_response(user_message_text, chat_history)
                else:
                    bot_response = OpenAIService.get_chat_response(user_message_text, chat_history)

            # Save bot response to database
            bot_message = ChatMessage.objects.create(
                user=request.user,
                text=bot_response,
                is_user_message=False
            )

            # Return both messages
            return Response({
                'success': True,
                'user_message': ChatMessageSerializer(user_message).data,
                'bot_response': ChatMessageSerializer(bot_message).data,
                'crisis_assessment': crisis_assessment,
                'provider': 'gemini' if settings.GEMINI_API_KEY else 'openai'
                # Indicate which service provided the response
            })
        except Exception as e:
            logger.error(f"Error in send chat: {str(e)}\n{traceback.format_exc()}")
            return Response({
                'success': False,
                'message': f'An error occurred while processing your message: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    @action(detail=False, methods=['get'])
    def history(self, request):
        try:
            limit = int(request.query_params.get('limit', 50))
            messages = self.get_queryset().order_by('timestamp')[:limit]
            serializer = self.get_serializer(messages, many=True)
            return Response({
                'success': True,
                'data': serializer.data
            })
        except Exception as e:
            logger.error(f"Error fetching chat history: {str(e)}\n{traceback.format_exc()}")
            return Response({
                'success': False,
                'message': f'Error fetching chat history: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    @action(detail=False, methods=['get'])
    def analysis(self, request):
        """Get analysis of conversation trends"""
        try:
            messages = self.get_queryset().order_by('timestamp')
            analysis = ChatAnalysisService.analyze_conversation_trends(messages, request.user)
            return Response({
                'success': True,
                'data': analysis
            })
        except Exception as e:
            logger.error(f"Error analyzing conversations: {str(e)}\n{traceback.format_exc()}")
            return Response({
                'success': False,
                'message': f'Error analyzing conversations: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    @action(detail=False, methods=['post'])
    def analyze(self, request):
        """Analyze a user message without saving it"""
        message = request.data.get('message')
        if not message:
            return Response({
                'success': False,
                'message': 'Message is required'
            }, status=status.HTTP_400_BAD_REQUEST)

        # Use the appropriate AI service to analyze the message
        if settings.GEMINI_API_KEY:
            analysis = GeminiService.analyze_message(message)
        else:
            analysis = OpenAIService.analyze_message(message)

        return Response({
            'success': True,
            'sentiment': analysis.get('sentiment', 'neutral'),
            'emotions': analysis.get('emotions', []),
            'triggers': analysis.get('triggers', []),
            'topics': analysis.get('topics', []),
            'provider': 'gemini' if settings.GEMINI_API_KEY else 'openai'
        })

    @action(detail=False, methods=['get'])
    def suggested_messages(self, request):
        """Return a list of suggested messages based on user's history and status"""
        try:
            # Get recent messages and analyze trends
            recent_messages = self.get_queryset().order_by('-timestamp')[:20]

            if recent_messages:
                analysis = ChatAnalysisService.analyze_conversation_trends(recent_messages, request.user)

                # Customize suggestions based on common topics and emotions
                custom_suggestions = []

                # Add topic-based suggestions
                topics = analysis.get('common_topics', [])
                if topics and 'cravings' in topics:
                    custom_suggestions.append("I'm having cravings right now")

                if topics and 'sleep' in topics:
                    custom_suggestions.append("I'm struggling with sleep")

                # Add emotion-based suggestions
                emotions = analysis.get('common_emotions', [])
                if emotions and 'anxiety' in emotions:
                    custom_suggestions.append("I'm feeling anxious today")

                if emotions and 'loneliness' in emotions:
                    custom_suggestions.append("I'm feeling isolated")

                # If we have custom suggestions, use them
                if custom_suggestions:
                    # Add some default suggestions
                    default_suggestions = [
                        "What coping strategies would you recommend?",
                        "How can I stay motivated in recovery?"
                    ]

                    # Combine and limit to 5 suggestions
                    suggestions = custom_suggestions + default_suggestions
                    return Response({
                        'success': True,
                        'data': suggestions[:5]
                    })

            # Default suggestions if no customization is possible
            suggestions = [
                "I'm feeling anxious",
                "I'm having cravings",
                "Need help with sleep",
                "Looking for coping strategies",
                "Help with triggers"
            ]

            return Response({
                'success': True,
                'data': suggestions
            })
        except Exception as e:
            logger.error(f"Error getting suggested messages: {str(e)}\n{traceback.format_exc()}")
            return Response({
                'success': False,
                'message': f'Error getting suggested messages: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)