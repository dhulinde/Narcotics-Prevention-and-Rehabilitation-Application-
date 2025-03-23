import os
import requests
import json
from datetime import datetime, time
from django.conf import settings
from openai import OpenAI
from .models import Task, TaskCategory
import logging

logger = logging.getLogger(__name__)


class MLTaskGenerator:
    """
    Class to handle the ML integration for task generation.
    This uses the OpenAI API or Gemini API to generate personalized tasks.
    """

    @staticmethod
    def generate_tasks(user, category=None):
        """
        Generate tasks for a user based on their profile and assessment data.

        Args:
            user: User object
            category: Optional category to generate tasks for

        Returns:
            List of task dictionaries to be created
        """
        # Get user data that would be useful for task generation
        user_data = {
            'username': user.username,
            'recovery_start_date': user.recovery_start_date.isoformat() if user.recovery_start_date else None,
        }

        # Get latest ASSIST questionnaire data
        from assessment.models import AssistQuestionnaire
        latest_questionnaire = AssistQuestionnaire.objects.filter(
            user=user
        ).order_by('-date_completed').first()

        questionnaire_data = None
        if latest_questionnaire:
            substance_responses = latest_questionnaire.substance_responses.all()
            questionnaire_data = {
                'overall_risk_level': latest_questionnaire.overall_risk_level,
                'highest_score': latest_questionnaire.highest_score,
                'substances': [
                    {
                        'name': response.substance.name,
                        'score': response.calculated_score,
                        'risk_level': response.risk_level,
                        'used_in_lifetime': response.used_in_lifetime,
                        'frequency_last_3_months': response.frequency_last_3_months
                    }
                    for response in substance_responses
                ]
            }

        # Get current treatment plan
        from treatment_plans.models import UserTreatmentPlan
        user_treatment_plan = None
        try:
            user_plan = UserTreatmentPlan.objects.get(user=user)
            if user_plan and user_plan.plan:
                user_treatment_plan = {
                    'name': user_plan.plan.name,
                    'intensity': user_plan.plan.intensity,
                }
        except UserTreatmentPlan.DoesNotExist:
            pass

        # Get mood data for additional context
        from mood_tracking.models import MoodEntry
        mood_entries = MoodEntry.objects.filter(user=user).order_by('-date')[:7]
        mood_data = []
        if mood_entries:
            mood_data = [
                {
                    'date': entry.date.isoformat(),
                    'mood': entry.mood,
                    'note': entry.note
                }
                for entry in mood_entries
            ]

        # Get chat messages for context
        from chat.models import ChatMessage
        chat_messages = ChatMessage.objects.filter(user=user).order_by('-timestamp')[:10]
        chat_data = []
        if chat_messages:
            chat_data = [
                {
                    'text': msg.text,
                    'is_user_message': msg.is_user_message,
                    'sentiment': msg.sentiment,
                    'emotions': msg.emotions,
                    'triggers': msg.triggers,
                    'topics': msg.topics
                }
                for msg in chat_messages
            ]

        # Try generating tasks with Gemini first if available
        if hasattr(settings, 'GEMINI_API_KEY') and settings.GEMINI_API_KEY:
            try:
                # Import here to avoid potential circular imports
                from .gemini_integration import GeminiTaskGenerator

                # Generate tasks with Gemini
                tasks = GeminiTaskGenerator.generate_tasks(
                    user_data,
                    questionnaire_data,
                    user_treatment_plan,
                    mood_data,
                    chat_data,
                    category
                )

                # If Gemini successfully generated tasks, return them
                if tasks:
                    logger.info("Tasks generated using Gemini API")
                    return tasks

                # Otherwise fall back to OpenAI
                logger.info("Gemini API returned no tasks, falling back to OpenAI")
            except Exception as e:
                logger.error(f"Error with Gemini task generation: {str(e)}")
                # Continue to OpenAI on error

        # Generate personalized tasks using OpenAI if available
        if settings.OPENAI_API_KEY:
            tasks = MLTaskGenerator._generate_tasks_with_openai(
                user_data,
                questionnaire_data,
                user_treatment_plan,
                mood_data,
                chat_data,
                category
            )
            if tasks:
                logger.info("Tasks generated using OpenAI API")
                return tasks

        # Fall back to rule-based generation if both APIs fail
        logger.info("Using rule-based task generation as fallback")
        return MLTaskGenerator._get_rule_based_tasks(category, questionnaire_data, user_treatment_plan, mood_data)

    @staticmethod
    def _generate_tasks_with_openai(user_data, questionnaire_data, treatment_plan, mood_data, chat_data, category=None):
        """
        Generate tasks using OpenAI API based on user data
        """
        if not settings.OPENAI_API_KEY:
            # Fall back to rule-based generation if OpenAI API is not available
            return None

        try:
            # Initialize OpenAI client
            client = OpenAI(api_key=settings.OPENAI_API_KEY)

            # Create a prompt for OpenAI based on user data
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
    """

            # Call OpenAI API
            response = client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system",
                     "content": "You are an AI specialized in addiction recovery and mental health. Your task is to generate personalized recovery tasks for users based on their profile data."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=1000,
                response_format={"type": "json_object"}
            )

            # Extract and parse the response
            response_text = response.choices[0].message.content.strip()
            try:
                tasks_data = json.loads(response_text)
                if 'tasks' in tasks_data:
                    return tasks_data['tasks']
                else:
                    return list(tasks_data)  # Assume the entire response is the tasks array
            except json.JSONDecodeError:
                logger.error(f"Error parsing OpenAI response: {response_text}")
                return None

        except Exception as e:
            logger.error(f"Error generating tasks with OpenAI: {e}")
            return None

    @staticmethod
    def _get_rule_based_tasks(category=None, questionnaire_data=None, treatment_plan=None, mood_data=None):
        """
        Get default tasks based on category and user data.
        This is a fallback when the AI approaches are not available.
        """
        try:
            risk_level = 'low'
            if questionnaire_data and 'overall_risk_level' in questionnaire_data:
                risk_level = questionnaire_data['overall_risk_level']

            intensity = 'moderate'
            if treatment_plan and 'intensity' in treatment_plan:
                intensity = treatment_plan['intensity'].lower()

            # Task templates with more comprehensive and specific tasks
            task_templates = {
                'daily': [
                    {'title': 'Morning self-reflection', 'reminder_time': '08:00:00', 'category': 'daily',
                     'note': 'Take 10 minutes to journal your thoughts and intentions for the day'},
                    {'title': 'Hydration and nutrition tracking', 'category': 'daily',
                     'note': 'Log your water intake and plan balanced meals'},
                    {'title': 'Medication adherence check', 'reminder_time': '09:00:00', 'category': 'daily',
                     'note': 'Take prescribed medications at scheduled time'},
                    {'title': 'Evening gratitude practice', 'reminder_time': '21:00:00', 'category': 'daily',
                     'note': 'Write down 3 things you are grateful for today'},
                ],
                'exercise': [
                    {'title': 'Morning stretching routine', 'category': 'exercise',
                     'note': '15-minute gentle stretching to improve flexibility and reduce stress'},
                    {'title': 'Walk or light cardio', 'category': 'exercise',
                     'note': 'Aim for 30 minutes of moderate activity'},
                    {'title': 'Strength training', 'category': 'exercise',
                     'note': 'Body weight exercises or light weights, focus on form'},
                ],
                'wellness': [
                    {'title': 'Mindfulness meditation', 'category': 'wellness',
                     'note': '10-minute guided meditation focusing on breath and present moment'},
                    {'title': 'Nature connection', 'category': 'wellness',
                     'note': 'Spend time outdoors, even if just 15 minutes'},
                    {'title': 'Self-care activity', 'category': 'wellness',
                     'note': 'Do something that brings you joy and relaxation'},
                ],
                'medication': [
                    {'title': 'Morning medication', 'reminder_time': '08:00:00', 'category': 'medication',
                     'note': 'Take medications as prescribed, track dosage'},
                    {'title': 'Evening medication', 'reminder_time': '20:00:00', 'category': 'medication',
                     'note': 'Take evening medications, review any side effects'},
                    {'title': 'Medication review', 'category': 'medication',
                     'note': 'Check medication inventory, schedule refills if needed'},
                ],
                'social': [
                    {'title': 'Support group check-in', 'category': 'social',
                     'note': 'Attend or connect with recovery support group'},
                    {'title': 'Meaningful connection', 'category': 'social',
                     'note': 'Reach out to a supportive friend or family member'},
                    {'title': 'Healthy boundary practice', 'category': 'social',
                     'note': 'Reflect on and reinforce personal boundaries'},
                ]
            }

            # Modify tasks based on risk level and intensity
            if risk_level == 'high':
                task_templates['daily'].extend([
                    {'title': 'Trigger management', 'category': 'daily',
                     'note': 'Identify potential triggers and plan coping strategies'},
                    {'title': 'Safety check-in', 'category': 'daily',
                     'note': 'Contact sponsor or support person if feeling vulnerable'}
                ])
            task_templates['wellness'].extend([
                {'title': 'Stress reduction techniques', 'category': 'wellness',
                 'note': 'Practice deep breathing or progressive muscle relaxation'}
            ])

            if intensity == 'challenging':
                task_templates['exercise'].extend([
                    {'title': 'Advanced workout', 'category': 'exercise',
                     'note': 'High-intensity interval training or strength training'}
                ])
            task_templates['wellness'].extend([
                {'title': 'Extended meditation', 'category': 'wellness',
                 'note': '20-minute advanced meditation practice'}
            ])

            # Filter tasks by category if specified
            if category:
                return [
                    {
                        'title': task['title'],
                        'category': category,
                        'reminder_time': task.get('reminder_time'),
                        'note': task.get('note'),
                    }
                    for task in task_templates.get(category, [])
                ]

            # Combine tasks from all categories if no specific category
            all_tasks = []
            for cat_tasks in task_templates.values():
                all_tasks.extend(cat_tasks)

            return all_tasks

        except Exception as e:
            logger.error(f"Error in rule-based task generation: {e}")

            # Fallback to minimal task generation
            default_tasks = [
                {"title": "Morning meditation", "category": "wellness", "reminder_time": "08:00",
                 "note": "Focus on breathing for 5 minutes"},
                {"title": "Take medications", "category": "medication", "reminder_time": "09:00"},
                {"title": "Call a friend", "category": "social"},
                {"title": "10-minute walk", "category": "exercise"},
                {"title": "Journal", "category": "daily", "reminder_time": "21:00"}
            ]

            if category:
                return [task for task in default_tasks if task['category'] == category]
            return default_tasks