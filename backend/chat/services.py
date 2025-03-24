from .openai_integration import OpenAIService
from .gemini_integration import GeminiService
import re
import json
from collections import Counter
import logging
import traceback
from django.conf import settings

logger = logging.getLogger(__name__)

class ChatAnalysisService:
    """
    Service for analyzing chat messages and extracting insights
    """

    @staticmethod
    def analyze_conversation_trends(messages, user):
        """
        Analyze conversation trends over time

        Args:
            messages: List of ChatMessage objects
            user: User object

        Returns:
            dict with analysis results
        """
        try:
            if not messages:
                return {
                    'sentiment_trend': 'neutral',
                    'common_emotions': [],
                    'common_triggers': [],
                    'common_topics': [],
                    'engagement_level': 'low',
                    'recommendations': []
                }

            # Get only user messages
            user_messages = [msg for msg in messages if msg.is_user_message]

            # Analyze sentiment trends
            sentiments = [msg.sentiment for msg in user_messages if msg.sentiment]
            sentiment_counts = Counter(sentiments)
            sentiment_trend = sentiment_counts.most_common(1)[0][0] if sentiment_counts else 'neutral'

            # Analyze emotions
            all_emotions = []
            for msg in user_messages:
                if msg.emotions:
                    if isinstance(msg.emotions, str):
                        try:
                            emotions = json.loads(msg.emotions)
                            if isinstance(emotions, list):
                                all_emotions.extend(emotions)
                        except json.JSONDecodeError:
                            pass
                    elif isinstance(msg.emotions, list):
                        all_emotions.extend(msg.emotions)
                    elif isinstance(msg.emotions, dict):
                        all_emotions.extend(msg.emotions.keys())

            common_emotions = Counter(all_emotions).most_common(5)
            common_emotions = [emotion for emotion, count in common_emotions]

            # Analyze triggers
            all_triggers = []
            for msg in user_messages:
                if msg.triggers:
                    if isinstance(msg.triggers, str):
                        try:
                            triggers = json.loads(msg.triggers)
                            if isinstance(triggers, list):
                                all_triggers.extend(triggers)
                        except json.JSONDecodeError:
                            pass
                    elif isinstance(msg.triggers, list):
                        all_triggers.extend(msg.triggers)
                    elif isinstance(msg.triggers, dict):
                        all_triggers.extend(msg.triggers.keys())

            common_triggers = Counter(all_triggers).most_common(5)
            common_triggers = [trigger for trigger, count in common_triggers]

            # Analyze topics
            all_topics = []
            for msg in user_messages:
                if msg.topics:
                    if isinstance(msg.topics, str):
                        try:
                            topics = json.loads(msg.topics)
                            if isinstance(topics, list):
                                all_topics.extend(topics)
                        except json.JSONDecodeError:
                            pass
                    elif isinstance(msg.topics, list):
                        all_topics.extend(msg.topics)
                    elif isinstance(msg.topics, dict):
                        all_topics.extend(msg.topics.keys())

            common_topics = Counter(all_topics).most_common(5)
            common_topics = [topic for topic, count in common_topics]

            # Determine engagement level
            total_user_messages = len(user_messages)
            engagement_level = 'low'
            if total_user_messages > 20:
                engagement_level = 'high'
            elif total_user_messages > 10:
                engagement_level = 'medium'

            # Generate recommendations based on analysis
            recommendations = ChatAnalysisService._generate_recommendations(
                sentiment_trend, common_emotions, common_triggers, common_topics
            )

            return {
                'sentiment_trend': sentiment_trend,
                'common_emotions': common_emotions,
                'common_triggers': common_triggers,
                'common_topics': common_topics,
                'engagement_level': engagement_level,
                'total_messages': total_user_messages,
                'recommendations': recommendations
            }
        except Exception as e:
            logger.error(f"Error analyzing conversation trends: {str(e)}\n{traceback.format_exc()}")
            # Return a default response in case of error
            return {
                'sentiment_trend': 'neutral',
                'common_emotions': [],
                'common_triggers': [],
                'common_topics': [],
                'engagement_level': 'low',
                'recommendations': [],
                'error': str(e)
            }

    @staticmethod
    def _generate_recommendations(sentiment_trend, emotions, triggers, topics):
        """Generate recommendations based on conversation analysis"""
        try:
            recommendations = []

            # Sentiment-based recommendations
            if sentiment_trend == 'negative':
                recommendations.append({
                    'type': 'sentiment',
                    'text': 'Your messages show a negative trend. Consider focusing on positive aspects of your recovery journey.'
                })

            # Emotion-based recommendations
            if emotions and ('anxiety' in emotions or 'stress' in emotions or 'fear' in emotions):
                recommendations.append({
                    'type': 'emotion',
                    'text': 'Consider practicing stress-reduction techniques like deep breathing or meditation.'
                })

            if emotions and ('sadness' in emotions or 'depression' in emotions):
                recommendations.append({
                    'type': 'emotion',
                    'text': 'Reach out to your support network or consider speaking with a mental health professional.'
                })

            # Trigger-based recommendations
            if triggers and len(triggers) > 0:
                recommendations.append({
                    'type': 'trigger',
                    'text': f"You've mentioned triggers like {', '.join(triggers[:3])}. Consider developing specific coping strategies for these."
                })

            # Topic-based recommendations
            recovery_topics = ['recovery', 'sobriety', 'treatment', 'therapy', 'support']
            if topics and any(topic in topics for topic in recovery_topics):
                recommendations.append({
                    'type': 'topic',
                    'text': 'Continue engaging with recovery-focused resources and support.'
                })

            return recommendations
        except Exception as e:
            logger.error(f"Error generating recommendations: {str(e)}\n{traceback.format_exc()}")
            return []

    @staticmethod
    def get_crisis_level(message):
        """
        Determine if a message indicates a crisis situation that needs immediate attention

        Args:
            message: ChatMessage object

        Returns:
            dict with crisis assessment
        """
        try:
            # Keywords that might indicate crisis
            crisis_keywords = [
                'suicide', 'kill myself', 'want to die', 'end my life',
                'overdose', 'relapse', 'emergency', 'danger', 'hurt myself',
                'harm myself', 'giving up', 'can\'t go on'
            ]

            # Check if any crisis keywords are present
            message_text = message.text.lower()
            found_keywords = [word for word in crisis_keywords if word in message_text]

            crisis_level = 'none'
            if found_keywords:
                # Use AI for more nuanced analysis if available
                try:
                    # Choose service based on available API key
                    if settings.GEMINI_API_KEY:
                        analysis = GeminiService.analyze_message(message.text)
                    else:
                        analysis = OpenAIService.analyze_message(message.text)

                    # Extract sentiment and emotions
                    sentiment = analysis.get('sentiment', 'neutral')
                    emotions = analysis.get('emotions', [])

                    # Determine crisis level based on sentiment, emotions and keywords
                    if sentiment == 'negative' and (
                            'hopelessness' in emotions or
                            'despair' in emotions or
                            'suicidal' in emotions
                    ):
                        crisis_level = 'high'
                    elif sentiment == 'negative':
                        crisis_level = 'medium'
                    else:
                        crisis_level = 'low'
                except Exception as e:
                    logger.error(f"Error in AI analysis for crisis level: {str(e)}")
                    # Fallback to keyword-based assessment
                    if any(word in ['suicide', 'kill myself', 'want to die'] for word in found_keywords):
                        crisis_level = 'high'
                    else:
                        crisis_level = 'medium'

            response = {
                'crisis_level': crisis_level,
                'detected_keywords': found_keywords,
                'recommendation': ChatAnalysisService._get_crisis_recommendation(crisis_level)
            }

            return response
        except Exception as e:
            logger.error(f"Error getting crisis level: {str(e)}\n{traceback.format_exc()}")
            # Return a safe default in case of error
            return {
                'crisis_level': 'none',
                'detected_keywords': [],
                'recommendation': ChatAnalysisService._get_crisis_recommendation('none')
            }

    @staticmethod
    def _get_crisis_recommendation(crisis_level):
        """Get recommendation based on crisis level"""
        try:
            if crisis_level == 'high':
                return {
                    'message': "I've noticed some concerning language in your message. If you're in crisis, please contact emergency services or a crisis helpline immediately.",
                    'resources': [
                        "National Suicide Prevention Lifeline: 988 or 1-800-273-8255",
                        "Crisis Text Line: Text HOME to 741741"
                    ],
                    'immediate_action': True
                }
            elif crisis_level == 'medium':
                return {
                    'message': "It sounds like you're going through a difficult time. Please consider reaching out to a mental health professional or support group.",
                    'resources': [
                        "SAMHSA's National Helpline: 1-800-662-HELP (4357)",
                        "Crisis Text Line: Text HOME to 741741"
                    ],
                    'immediate_action': False
                }
            elif crisis_level == 'low':
                return {
                    'message': "I notice you mentioned some concerning topics. Remember that it's okay to ask for help when needed.",
                    'resources': [
                        "SAMHSA's National Helpline: 1-800-662-HELP (4357)"
                    ],
                    'immediate_action': False
                }
            else:  # 'none'
                return {
                    'message': "Remember that support is always available if you need it.",
                    'resources': [],
                    'immediate_action': False
                }
        except Exception as e:
            logger.error(f"Error getting crisis recommendation: {str(e)}\n{traceback.format_exc()}")
            # Return a safe default in case of error
            return {
                'message': "Remember that support is always available if you need it.",
                'resources': [],
                'immediate_action': False
            }