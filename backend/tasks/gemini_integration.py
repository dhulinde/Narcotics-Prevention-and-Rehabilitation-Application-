import os
import json
import logging
from datetime import datetime, time
from django.conf import settings
import traceback

logger = logging.getLogger(__name__)

# Create client instance only if API key is available
client = None
if hasattr(settings, 'GEMINI_API_KEY') and settings.GEMINI_API_KEY:
    try:
        import google.generativeai as genai

        genai.configure(api_key=settings.GEMINI_API_KEY)
        client = genai
    except ImportError:
        logger.error("Google Generative AI library not installed. Use pip install google-generativeai")
    except Exception as e:
        logger.error(f"Error initializing Gemini client: {str(e)}")


class GeminiTaskGenerator:
    """
    Class to handle the Gemini AI integration for task generation.
    """

    @staticmethod
    def generate_tasks(user_data, questionnaire_data, treatment_plan, mood_data, chat_data, category=None):
        """
        Generate tasks using Gemini AI based on user data

        Args:
            user_data: Basic user profile information
            questionnaire_data: Assessment data from ASSIST questionnaire
            treatment_plan: User's treatment plan details
            mood_data: Recent mood tracking entries
            chat_data: Recent chat messages
            category: Optional category to filter tasks

        Returns:
            List of task dictionaries to be created
        """
        if not hasattr(settings, 'GEMINI_API_KEY') or not settings.GEMINI_API_KEY or not client:
            # Return None to allow fallback to OpenAI or rule-based generation
            return None

        try:
            # Create prompt for Gemini based on user data
            prompt = f"""Generate personalized recovery tasks for a user with the following profile:

    User information:
    - Recovery start date: {user_data.get('recovery_start_date', 'Not specified')}

    """

            if questionnaire_data:
                prompt += f"""Assessment data:
    - Overall risk level: {questionnaire_data.get('overall_risk_level', 'Not specified')}
    - Highest score: {questionnaire_data.get('highest_score', 'Not specified')}
    - Substances of concern: {', '.join([s['name'] for s in questionnaire_data.get('substances', []) if s['risk_level'] in ['moderate', 'high']])}

    """

            if treatment_plan:
                prompt += f"""Treatment plan:
    - Plan name: {treatment_plan.get('name', 'Not specified')}
    - Intensity: {treatment_plan.get('intensity', 'Not specified')}

    """

            if mood_data:
                recent_moods = [entry['mood'] for entry in mood_data[:3]]
                prompt += f"""Recent mood data:
    - Recent moods: {', '.join(recent_moods)}
    - Notes: {mood_data[0].get('note', 'None') if mood_data else 'None'}

    """

            prompt += f"""
    I need you to generate 5-8 personalized recovery tasks for this user.
    """

            if category:
                prompt += f" Focus only on the '{category}' category."

            prompt += """
    For each task, provide:
    1. A title (short and actionable)
    2. A category (must be one of: daily, exercise, wellness, medication, social)
    3. An optional note with more details or guidance
    4. An optional reminder time in 24-hour format (e.g., "08:00")

    Return the tasks as a JSON array. Example:
    [
      {
        "title": "Morning meditation",
        "category": "wellness",
        "note": "Focus on breathing for 5 minutes",
        "reminder_time": "08:00"
      },
      {
        "title": "Take medication",
        "category": "medication", 
        "reminder_time": "09:00"
      }
    ]

    Do not include any text or explanation outside the JSON array.
    """

            # Use Gemini model to generate content
            model = client.GenerativeModel('gemini-1.5-flash')
            response = model.generate_content(prompt)

            # Extract and parse the response
            response_text = response.text.strip()

            try:
                # Clean up the response to ensure it's valid JSON
                # Remove markdown code blocks if present
                if response_text.startswith("```json"):
                    response_text = response_text.replace("```json", "", 1)
                    if response_text.endswith("```"):
                        response_text = response_text[:-3]

                elif response_text.startswith("```"):
                    response_text = response_text.replace("```", "", 1)
                    if response_text.endswith("```"):
                        response_text = response_text[:-3]

                response_text = response_text.strip()

                # Parse the JSON response
                tasks_data = json.loads(response_text)

                # Check if it's a dict with a 'tasks' key or already a list
                if isinstance(tasks_data, dict) and 'tasks' in tasks_data:
                    return tasks_data['tasks']
                else:
                    return list(tasks_data)  # Ensure we return a list

            except json.JSONDecodeError as e:
                logger.error(f"Error parsing Gemini response: {response_text}\nError: {str(e)}")
                return None  # Return None to allow fallback

        except Exception as e:
            logger.error(f"Error generating tasks with Gemini: {str(e)}\n{traceback.format_exc()}")
            return None  # Return None to allow fallback