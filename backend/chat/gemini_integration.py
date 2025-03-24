import os
import json
import logging
from django.conf import settings
import google.generativeai as genai
import traceback

logger = logging.getLogger(__name__)

# Create client instance only if API key is available
client = None
if settings.GEMINI_API_KEY:
    try:
        genai.configure(api_key=settings.GEMINI_API_KEY)
        client = genai
    except Exception as e:
        logger.error(f"Error initializing Gemini client: {str(e)}")


class GeminiService:
    @staticmethod
    def get_chat_response(message, chat_history=None):
        """
        Get a response from Google's Gemini API based on the user's message and chat history.
        Falls back to rule-based responses if API fails.
        """
        if not settings.GEMINI_API_KEY or not client:
            return GeminiService.get_fallback_response(message)

        try:
            # Format chat history for Gemini API
            formatted_history = []

            # Add system prompt
            system_prompt = """You are a recovery assistant for addiction.
            Provide supportive, empathetic responses. Never encourage harmful behavior.
            Focus on evidence-based approaches. Be concise and specific.

            Always focus on providing psychological first aid principles:
            1. Create a sense of safety and calm
            2. Promote self-efficacy and empowerment
            3. Connect people to support networks
            4. Instill hope while being realistic

            Always encourage seeking professional help when appropriate.
            """

            # Add chat history if available
            if chat_history:
                for msg in chat_history[-10:]:  # Limit to last 10 messages for context
                    role = "user" if msg.is_user_message else "model"
                    formatted_history.append({"role": role, "parts": [msg.text]})

            # Initialize Gemini model
            model = client.GenerativeModel('gemini-1.5-flash')

            # Create a chat session
            chat = model.start_chat(history=formatted_history)

            # Get response from Gemini
            response = chat.send_message(message)

            return response.text

        except Exception as e:
            logger.error(f"Gemini API error: {str(e)}\n{traceback.format_exc()}")
            # Always fall back to rule-based responses on any error
            return GeminiService.get_fallback_response(message)

    @staticmethod
    def analyze_message(message):
        """
        Analyze the user's message to extract sentiment, emotions, triggers, and topics.

        Args:
            message (str): User's message

        Returns:
            dict: Analysis results
        """
        if not settings.GEMINI_API_KEY or not client:
            return {
                'sentiment': 'neutral',
                'emotions': [],
                'triggers': [],
                'topics': []
            }

        try:
            # Create the analysis prompt
            analysis_prompt = f"""Analyze the following user message and extract:
            - sentiment (positive, negative, neutral)
            - emotions detected (list of emotions)
            - any triggers mentioned related to addiction (list of triggers)
            - relevant topics related to recovery (list of topics)

            Return ONLY a JSON object with these fields. No additional text.

            User message: "{message}"
            """

            # Initialize the model
            model = client.GenerativeModel('gemini-1.5-flash')

            # Get response
            response = model.generate_content(analysis_prompt)

            analysis_text = response.text.strip()

            try:
                # Parse the JSON response
                analysis_json = json.loads(analysis_text)

                # Ensure all expected fields are present
                default_analysis = {
                    'sentiment': 'neutral',
                    'emotions': [],
                    'triggers': [],
                    'topics': []
                }

                for key in default_analysis:
                    if key not in analysis_json:
                        analysis_json[key] = default_analysis[key]

                return analysis_json
            except json.JSONDecodeError as e:
                logger.error(f"Error parsing analysis: {analysis_text}\nError: {str(e)}")
                return {
                    'sentiment': 'neutral',
                    'emotions': [],
                    'triggers': [],
                    'topics': []
                }

        except Exception as e:
            logger.error(f"Gemini Analysis API error: {str(e)}\n{traceback.format_exc()}")
            return {
                'sentiment': 'neutral',
                'emotions': [],
                'triggers': [],
                'topics': []
            }

    @staticmethod
    def get_fallback_response(message):
        """
        Provide fallback responses when Gemini API is unavailable.
        """
        message = message.lower()

        if 'help' in message or 'support' in message:
            return "If you're struggling, remember to use your coping strategies. Would you like some suggestions?"
        elif 'craving' in message or 'urge' in message:
            return "Cravings typically last 15-30 minutes. Try deep breathing, calling a friend, or going for a walk."
        elif 'stress' in message or 'anxious' in message or 'anxiety' in message:
            return "Stress management is important in recovery. Have you tried the mindfulness exercises in your plan?"
        elif 'hello' in message or 'hi' in message:
            return "Hello! How are you feeling today?"
        elif 'thank' in message:
            return "You're welcome! I'm here to support your recovery journey."
        elif 'trigger' in message or 'relapse' in message:
            return "Identifying triggers is a key part of preventing relapse. Can you share what triggers you've noticed?"
        elif 'lonely' in message or 'alone' in message:
            return "Feeling isolated can be challenging during recovery. Have you considered joining a support group or reaching out to your support network?"
        elif 'sleep' in message or 'insomnia' in message:
            return "Sleep problems are common in recovery. Establishing a regular sleep schedule and bedtime routine can help. Would you like more sleep tips?"
        elif 'exercise' in message or 'workout' in message:
            return "Exercise can be a powerful tool in recovery. It reduces stress, improves mood, and helps rebuild physical health. What activities do you enjoy?"
        else:
            return "I'm here to help with your recovery. Can you tell me more about what you're experiencing?"