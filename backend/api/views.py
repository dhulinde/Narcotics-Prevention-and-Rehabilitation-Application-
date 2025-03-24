from django.http import JsonResponse
from utils.mongodb_check import check_mongodb_connection

def healthcheck(request):
    """API healthcheck endpoint that verifies MongoDB Atlas connection and key APIs"""
    mongo_connected, mongo_message = check_mongodb_connection()

    # Check if key collections exist and have data
    system_status = {
        'mongodb': {
            'connected': mongo_connected,
            'message': mongo_message
        },
        'endpoints': {}
    }

    # Check tasks collection
    from tasks.models import Task
    system_status['endpoints']['tasks'] = {
        'total_count': Task.objects.count(),
        'daily_count': Task.objects.filter(category='daily').count(),
        'social_count': Task.objects.filter(category='social').count(),
        'exercise_count': Task.objects.filter(category='exercise').count(),
        'wellness_count': Task.objects.filter(category='wellness').count(),
        'medication_count': Task.objects.filter(category='medication').count()
    }

    # Check mood collection
    from mood_tracking.models import MoodEntry, JournalEntry
    system_status['endpoints']['mood'] = {
        'mood_entries_count': MoodEntry.objects.count(),
        'journal_entries_count': JournalEntry.objects.count()
    }

    # Check chat collection
    from chat.models import ChatMessage
    system_status['endpoints']['chat'] = {
        'messages_count': ChatMessage.objects.count()
    }

    status_code = 200 if mongo_connected else 500

    return JsonResponse({
        'status': 'healthy' if mongo_connected else 'unhealthy',
        'system': system_status
    }, status=status_code)