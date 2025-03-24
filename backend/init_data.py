import os
import django
import random
from datetime import datetime, timedelta

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'nara.settings')
django.setup()

from django.contrib.auth import get_user_model
from assessment.models import Substance, AssistQuestionnaire, SubstanceResponse
from treatment_plans.models import TreatmentPlan, PlanActivity
from resources.models import Resource

User = get_user_model()

def create_substances():
    substances = [
        {'name': 'Tobacco products', 'description': '(cigarettes, chewing tobacco, cigars, etc.)'},
        {'name': 'Alcoholic beverages', 'description': '(beer, wine, spirits, etc.)'},
        {'name': 'Cannabis', 'description': '(marijuana, pot, grass, hash, etc.)'},
        {'name': 'Cocaine', 'description': '(coke, crack, etc.)'},
        {'name': 'Amphetamine-type stimulants', 'description': '(speed, meth, ecstasy, etc.)'},
        {'name': 'Inhalants', 'description': '(nitrous, glue, petrol, paint thinner, etc.)'},
        {'name': 'Sedatives or sleeping pills', 'description': '(diazepam, alprazolam, flunitrazepam, midazolam, etc.)'},
        {'name': 'Hallucinogens', 'description': '(LSD, acid, mushrooms, trips, ketamine, etc.)'},
        {'name': 'Opioids', 'description': '(heroin, morphine, methadone, buprenorphine, codeine, etc.)'},
        {'name': 'Other', 'description': ''},
    ]

    for substance_data in substances:
        Substance.objects.get_or_create(
            name=substance_data['name'],
            description=substance_data['description']
        )

    print(f"Created {len(substances)} substances.")

def create_treatment_plans():
    plans = [
        {
            'name': 'Fresh Start',
            'description': 'A new day, a fresh start. This plan helps you build stability with small, mindful steps. One choice at a time—you\'re not alone.',
            'duration': '10-15 mins daily',
            'intensity': 'Gentle',
            'color': '#10B981',  # Emerald green
            'icon': 'sunrise',
            'activities': [
                {
                    'title': 'Self-check-in, gratitude journaling',
                    'description': 'Begin and end each day with mindful reflection',
                    'icon': 'journal',
                },
                {
                    'title': 'Hydration, balanced meals',
                    'description': 'Focus on nourishing your body properly',
                    'icon': 'nutrition',
                },
                {
                    'title': 'Gentle stretching, short walks',
                    'description': 'Light movement to reconnect with your body',
                    'icon': 'exercise',
                },
                {
                    'title': 'Support groups, meaningful conversations',
                    'description': 'Building your support network is essential',
                    'icon': 'support',
                },
            ]
        },
        {
            'name': 'Strong Everyday',
            'description': 'Show up daily, build strength & balance, and take control of your recovery.',
            'duration': '20-30 mins daily',
            'intensity': 'Moderate',
            'color': '#3B82F6',  # Blue
            'icon': 'mountain',
            'activities': [
                {
                    'title': 'Walking, light strength training',
                    'description': 'Build physical strength and resilience',
                    'icon': 'fitness',
                },
                {
                    'title': 'Affirmations, deep breathing',
                    'description': 'Mental and emotional techniques for stability',
                    'icon': 'mindfulness',
                },
                {
                    'title': 'Triggers & coping strategies',
                    'description': 'Learning to identify and manage triggers',
                    'icon': 'strategy',
                },
            ]
        },
        {
            'name': 'Resilience',
            'description': 'Push forward with discipline. Your past doesn\'t define you—your actions do.',
            'duration': '30-45 mins daily',
            'intensity': 'Challenging',
            'color': '#8B5CF6',  # Purple
            'icon': 'shield',
            'activities': [
                {
                    'title': 'Strength training, endurance workouts',
                    'description': 'Challenge yourself physically to build mental strength',
                    'icon': 'strength',
                },
                {
                    'title': 'Journaling, reframing challenges',
                    'description': 'Transform your mindset and perspective',
                    'icon': 'transform',
                },
                {
                    'title': 'Screen-free relaxation, gratitude',
                    'description': 'Find peace in unplugged moments of appreciation',
                    'icon': 'relax',
                },
            ]
        },
        {
            'name': 'Unbreakable',
            'description': 'A holistic approach to emotional & physical recovery—you are unbreakable.',
            'duration': '20-30 mins daily',
            'intensity': 'Balanced',
            'color': '#F59E0B',  # Amber
            'icon': 'diamond',
            'activities': [
                {
                    'title': 'Meditation, emotional check-ins',
                    'description': 'Deep inner work to process feelings and build awareness',
                    'icon': 'meditation',
                },
                {
                    'title': 'Walks, swimming, stretching',
                    'description': 'Varied physical activities to strengthen body and mind',
                    'icon': 'activity',
                },
                {
                    'title': 'Support groups, meaningful conversations',
                    'description': 'Connection as the foundation of lasting recovery',
                    'icon': 'connection',
                },
            ]
        },
    ]

    for plan_data in plans:
        activities = plan_data.pop('activities')
        plan, created = TreatmentPlan.objects.get_or_create(**plan_data)

        for activity_data in activities:
            # Check if activity already exists to avoid ObjectId issues
            existing = PlanActivity.objects.filter(
                plan=plan,
                title=activity_data['title']
            ).first()

            if not existing:
                PlanActivity.objects.create(plan=plan, **activity_data)

    print(f"Created {len(plans)} treatment plans.")

def create_resources():
    resources = [
        {
            'title': 'Recovery Strategies for Substance Use',
            'description': 'A comprehensive guide on effective recovery methods and coping strategies for addiction. This book provides practical advice and evidence-based approaches to build a sustainable recovery path.',
            'type': 'book',
            'thumbnail_url': 'https://source.unsplash.com/random/300x200/?book',
            'author': 'Dr. Sarah Johnson',
            'date': '2023',
            'url': 'https://example.com/book1',
            'tags': ['recovery', 'strategies', 'substance-use'],
        },
        {
            'title': 'Mindfulness Meditation for Recovery',
            'description': 'Learn how mindfulness practices can support your recovery journey and promote wellness. This video tutorial guides you through simple, effective mindfulness techniques.',
            'type': 'video',
            'thumbnail_url': 'https://source.unsplash.com/random/300x200/?meditation',
            'author': 'Michael Chang',
            'date': '2024',
            'url': 'https://example.com/video1',
            'tags': ['mindfulness', 'meditation', 'wellness'],
        },
        {
            'title': 'Building a Support Network',
            'description': 'This article explains how to create and maintain a supportive community during recovery. It includes tips for identifying supportive relationships and navigating difficult conversations.',
            'type': 'article',
            'thumbnail_url': 'https://source.unsplash.com/random/300x200/?community',
            'author': 'Emma Wilson',
            'date': 'March 2024',
            'url': 'https://example.com/article1',
            'tags': ['support', 'community', 'relationships'],
        },
        {
            'title': 'Healthy Habits: Nutrition and Exercise in Recovery',
            'description': 'A guide to developing healthy physical habits that support sustained recovery. This comprehensive resource covers nutrition basics, meal planning, and exercise routines suitable for different stages of recovery.',
            'type': 'book',
            'thumbnail_url': 'https://source.unsplash.com/random/300x200/?nutrition',
            'author': 'Dr. Robert Chen',
            'date': '2022',
            'url': 'https://example.com/book2',
            'tags': ['nutrition', 'exercise', 'healthy-habits'],
        },
        {
            'title': 'Relapse Prevention Strategies',
            'description': 'Evidence-based techniques to identify triggers and prevent relapse. This article provides practical tools for developing a personalized relapse prevention plan.',
            'type': 'article',
            'thumbnail_url': 'https://source.unsplash.com/random/300x200/?strategy',
            'author': 'Jennifer Adams',
            'date': 'January 2024',
            'url': 'https://example.com/article2',
            'tags': ['relapse-prevention', 'triggers', 'planning'],
        },
        {
            'title': 'Understanding the Science of Addiction',
            'description': 'An informative podcast series exploring the neuroscience behind addiction and recovery. Each episode features expert interviews and the latest research findings.',
            'type': 'podcast',
            'thumbnail_url': 'https://source.unsplash.com/random/300x200/?science',
            'author': 'Dr. David Liu',
            'date': '2023',
            'url': 'https://example.com/podcast1',
            'tags': ['science', 'neuroscience', 'addiction'],
        },
        {
            'title': 'Recovery Journaling Techniques',
            'description': 'Learn how therapeutic writing can aid in processing emotions and tracking progress during recovery. Includes journal prompts and guided exercises.',
            'type': 'article',
            'thumbnail_url': 'https://source.unsplash.com/random/300x200/?journal',
            'author': 'Lisa Parker',
            'date': 'April 2024',
            'url': 'https://example.com/article3',
            'tags': ['journaling', 'reflection', 'emotional-processing'],
        },
        {
            'title': 'Coping with Cravings',
            'description': 'A practical video guide demonstrating effective techniques for managing cravings and urges. Features real-life examples and expert advice.',
            'type': 'video',
            'thumbnail_url': 'https://source.unsplash.com/random/300x200/?coping',
            'author': 'James Wilson',
            'date': '2023',
            'url': 'https://example.com/video2',
            'tags': ['cravings', 'coping-strategies', 'urges'],
        },
    ]

    for resource_data in resources:
        # Handle string conversion for tags field
        if isinstance(resource_data['tags'], list):
            resource_data['tags'] = ','.join(resource_data['tags'])

        # Check if resource exists by title
        existing = Resource.objects.filter(title=resource_data['title']).first()
        if not existing:
            Resource.objects.create(**resource_data)
        else:
            # Update existing resource (optional)
            for key, value in resource_data.items():
                setattr(existing, key, value)
            existing.save()

    print(f"Created {len(resources)} resources.")

def create_demo_user():
    # Create a demo user
    username = 'demo'
    password = 'password'

    user, created = User.objects.get_or_create(
        username=username,
        defaults={
            'email': 'demo@example.com',
            'security_question': 'What was your first pet\'s name?',
            'security_answer': 'demo',
            'display_name': 'Demo User',
            'recovery_start_date': datetime.now() - timedelta(days=30),
        }
    )

    if created:
        user.set_password(password)
        user.save()
        print(f"Created demo user: {username}")
    else:
        print(f"Demo user already exists: {username}")

if __name__ == '__main__':
    print("Initializing database with default data...")
    create_substances()
    create_treatment_plans()
    create_resources()
    create_demo_user()
    print("Data initialization complete.")