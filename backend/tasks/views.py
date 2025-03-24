# tasks/views.py
from bson import ObjectId
from rest_framework import viewsets, permissions, status, filters
from rest_framework.decorators import action
from django_filters.rest_framework import DjangoFilterBackend
from django.shortcuts import get_object_or_404
from .models import TaskCategory
from .serializers import TaskCreateSerializer, TaskCompletionSerializer
from .ml_integration import MLTaskGenerator
from api.mixins import UserOwnershipMixin
from django.db import connection
import logging
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .models import Task
from .serializers import TaskSerializer
from datetime import datetime

logger = logging.getLogger(__name__)

@action(detail=False, methods=['post'])
def create_samples_direct(self, request):
    """Create sample tasks directly in MongoDB"""
    from pymongo import MongoClient
    import os
    from django.conf import settings
    from bson import ObjectId
    import datetime

    # Connect to MongoDB
    mongo_uri = os.getenv('MONGO_URI', settings.DATABASES['default']['CLIENT']['host'])
    client = MongoClient(mongo_uri)
    db_name = os.getenv('MONGO_DB_NAME', settings.DATABASES['default']['NAME'])
    db = client[db_name]

    # Try both collection naming styles
    collections_to_try = ['tasks', 'tasks_task']
    tasks_collection = None

    for collection_name in collections_to_try:
        if collection_name in db.list_collection_names():
            tasks_collection = db[collection_name]
            break

    if not tasks_collection:
        # Create tasks collection if it doesn't exist
        tasks_collection = db.tasks

    # Get user ID
    user_id = request.user._id if hasattr(request.user, '_id') else None

    if not user_id:
        return Response({"detail": "User ID not found"}, status=status.HTTP_400_BAD_REQUEST)

    # Create sample tasks
    now = datetime.datetime.now()
    categories = ['daily', 'exercise', 'wellness', 'medication', 'social']

    sample_tasks = []
    for category in categories:
        for i in range(2):
            sample_tasks.append({
                "user": user_id,
                "title": f"Sample {category} task {i + 1}",
                "category": category,
                "is_completed": i % 2 == 0,  # Alternate completed status
                "created_at": now,
                "updated_at": now
            })

    # Insert tasks
    result = tasks_collection.insert_many(sample_tasks)
    inserted_count = len(result.inserted_ids)

    return Response({
        "detail": f"Created {inserted_count} sample tasks in collection {tasks_collection.name}",
        "collection": tasks_collection.name,
        "task_count": inserted_count
    }, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_sample_tasks(request):
    """Create sample tasks for the current user as a standalone view"""
    try:
        # Define sample tasks for each category with more meaningful examples
        sample_tasks = {
            "daily": [
                {"title": "Morning meditation", "note": "5-10 minutes of mindfulness meditation",
                 "is_completed": False},
                {"title": "Journaling", "note": "Write down thoughts and reflections", "is_completed": False},
                {"title": "Take vitamins", "note": "Daily supplements as recommended", "is_completed": True},
                {"title": "Drink 8 glasses of water", "note": "Stay hydrated throughout the day",
                 "is_completed": False},
                {"title": "Evening reflection", "note": "Review your day and set intentions for tomorrow",
                 "is_completed": False}
            ],
            "exercise": [
                {"title": "30-minute walk", "note": "Moderate pace in fresh air", "is_completed": False},
                {"title": "Stretching routine", "note": "Focus on flexibility and mobility", "is_completed": False},
                {"title": "Strength training", "note": "Basic bodyweight exercises", "is_completed": True},
                {"title": "Yoga session", "note": "15-minute gentle yoga flow", "is_completed": False},
                {"title": "Balance exercises", "note": "Improve stability and core strength", "is_completed": False}
            ],
            "wellness": [
                {"title": "Deep breathing exercises", "note": "3 sets of 10 deep breaths", "is_completed": False},
                {"title": "Healthy meal planning", "note": "Plan balanced meals for tomorrow", "is_completed": False},
                {"title": "Reading time", "note": "20 minutes of reading for relaxation", "is_completed": True},
                {"title": "Nature time", "note": "Spend 15 minutes outside in nature", "is_completed": False},
                {"title": "Practice gratitude", "note": "Write down three things you're grateful for",
                 "is_completed": False}
            ],
            "medication": [
                {"title": "Morning medication", "note": "Take with breakfast", "is_completed": False,
                 "reminder_time": "08:00"},
                {"title": "Afternoon medication", "note": "Take with lunch", "is_completed": False,
                 "reminder_time": "13:00"},
                {"title": "Evening medication", "note": "Take before bed", "is_completed": True,
                 "reminder_time": "21:00"},
                {"title": "Check medication supply", "note": "Ensure you have enough for the week",
                 "is_completed": False},
                {"title": "Log medication effects", "note": "Note any side effects or changes in your journal",
                 "is_completed": False}
            ],
            "social": [
                {"title": "Call support person", "note": "Check in with sponsor or counselor", "is_completed": False},
                {"title": "Attend recovery meeting", "note": "In-person or virtual support group",
                 "is_completed": False},
                {"title": "Connect with a friend", "note": "Brief check-in with someone supportive",
                 "is_completed": True},
                {"title": "Set healthy boundaries", "note": "Practice assertive communication", "is_completed": False},
                {"title": "Join a hobby group", "note": "Find a community with shared interests", "is_completed": False}
            ]
        }

        tasks_created = []
        for category, tasks in sample_tasks.items():
            for task_data in tasks:
                # Convert reminder_time string to TimeField if present
                reminder_time = None
                if 'reminder_time' in task_data:
                    time_obj = datetime.strptime(task_data['reminder_time'], '%H:%M').time()
                    reminder_time = time_obj

                # Create the task
                task = Task.objects.create(
                    user=request.user,
                    title=task_data['title'],
                    category=category,
                    is_completed=task_data['is_completed'],
                    note=task_data.get('note', ''),
                    reminder_time=reminder_time
                )
                tasks_created.append(TaskSerializer(task).data)

        return Response({
            "success": True,
            "message": f"Created {len(tasks_created)} sample tasks",
            "tasks": tasks_created
        }, status=status.HTTP_201_CREATED)
    except Exception as e:
        return Response({
            "success": False,
            "error": str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

# Inside your TaskViewSet class in tasks/views.py
@action(detail=False, methods=['post'])
def create_samples(self, request):
    """Create sample tasks for the current user"""
    try:
        # Define sample tasks for each category with more meaningful examples
        sample_tasks = {
            "daily": [
                {"title": "Morning meditation", "note": "5-10 minutes of mindfulness meditation",
                 "is_completed": False},
                {"title": "Journaling", "note": "Write down thoughts and reflections", "is_completed": False},
                {"title": "Take vitamins", "note": "Daily supplements as recommended", "is_completed": True}
            ],
            "exercise": [
                {"title": "30-minute walk", "note": "Moderate pace in fresh air", "is_completed": False},
                {"title": "Stretching routine", "note": "Focus on flexibility and mobility", "is_completed": False},
                {"title": "Strength training", "note": "Basic bodyweight exercises", "is_completed": True}
            ],
            "wellness": [
                {"title": "Deep breathing exercises", "note": "3 sets of 10 deep breaths", "is_completed": False},
                {"title": "Healthy meal planning", "note": "Plan balanced meals for tomorrow", "is_completed": False},
                {"title": "Reading time", "note": "20 minutes of reading for relaxation", "is_completed": True}
            ],
            "medication": [
                {"title": "Morning medication", "note": "Take with breakfast", "is_completed": False,
                 "reminder_time": "08:00"},
                {"title": "Evening medication", "note": "Take before bed", "is_completed": False,
                 "reminder_time": "21:00"},
                {"title": "Check medication supply", "note": "Ensure you have enough for the week",
                 "is_completed": True}
            ],
            "social": [
                {"title": "Call support person", "note": "Check in with sponsor or counselor", "is_completed": False},
                {"title": "Attend recovery meeting", "note": "In-person or virtual support group",
                 "is_completed": False},
                {"title": "Connect with a friend", "note": "Brief check-in with someone supportive",
                 "is_completed": True}
            ]
        }

        tasks_created = []
        for category, tasks in sample_tasks.items():
            for task_data in tasks:
                # Convert reminder_time string to TimeField if present
                reminder_time = None
                if 'reminder_time' in task_data:
                    from datetime import datetime
                    time_obj = datetime.strptime(task_data['reminder_time'], '%H:%M').time()
                    reminder_time = time_obj

                # Create the task
                task = Task.objects.create(
                    user=request.user,
                    title=task_data['title'],
                    category=category,
                    is_completed=task_data['is_completed'],
                    note=task_data.get('note', ''),
                    reminder_time=reminder_time
                )
                tasks_created.append(TaskSerializer(task).data)

        return Response({
            "success": True,
            "message": f"Created {len(tasks_created)} sample tasks",
            "tasks": tasks_created
        }, status=status.HTTP_201_CREATED)
    except Exception as e:
        return Response({
            "success": False,
            "error": str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@action(detail=False, methods=['get'])
def debug(self, request):
    """Debug endpoint to check task counts"""
    from .models import Task

    # Get all tasks
    all_tasks = Task.objects.all()
    task_count = all_tasks.count()

    # Count by category
    daily_count = Task.objects.filter(category='daily').count()
    exercise_count = Task.objects.filter(category='exercise').count()
    wellness_count = Task.objects.filter(category='wellness').count()
    medication_count = Task.objects.filter(category='medication').count()
    social_count = Task.objects.filter(category='social').count()

    # Get raw SQL for debugging
    raw_count = len(list(Task.objects.raw('SELECT * FROM tasks_task')))

    # Check collection in MongoDB directly
    from pymongo import MongoClient
    import os
    from django.conf import settings

    mongo_uri = os.getenv('MONGO_URI', settings.DATABASES['default']['CLIENT']['host'])
    client = MongoClient(mongo_uri)
    db_name = os.getenv('MONGO_DB_NAME', settings.DATABASES['default']['NAME'])
    db = client[db_name]
    mongo_count = db.tasks_task.count_documents({})

    logger.info(f"Task counts - Total: {task_count}, Daily: {daily_count}, Exercise: {exercise_count}")
    logger.info(f"MongoDB task count: {mongo_count}")

    return Response({
        'total_count': task_count,
        'daily_count': daily_count,
        'exercise_count': exercise_count,
        'wellness_count': wellness_count,
        'medication_count': medication_count,
        'social_count': social_count,
        'raw_count': raw_count,
        'mongo_count': mongo_count
    })

class TaskViewSet(UserOwnershipMixin, viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['category', 'is_completed']
    ordering_fields = ['created_at', 'title']
    ordering = ['category', 'created_at']

    # Add this line to fix the missing queryset attribute
    queryset = Task.objects.all()

    def get_serializer_class(self):
        if self.action == 'create':
            return TaskCreateSerializer
        return TaskSerializer

    # Make sure this method is properly implemented
    def get_queryset(self):
        # Use the parent's get_queryset method from UserOwnershipMixin
        # which filters by the current user
        return super().get_queryset()

    # Add this method to TaskViewSet
    def list(self, request, *args, **kwargs):
        """List tasks, optionally filtered by category"""
        category = kwargs.get('category')
        if category:
            queryset = self.get_queryset().filter(category=category)
            serializer = self.get_serializer(queryset, many=True)
            return Response(serializer.data)
        return super().list(request, *args, **kwargs)

    def list_by_category(self, request, category=None, *args, **kwargs):
        """
        Get tasks by category from the URL path or kwargs
        This is a convenience method for direct category URLs
        """
        # Get category from kwargs if not explicitly provided
        if not category:
            category = self.kwargs.get('category')

        if not category:
            return Response({"detail": "Category not specified"}, status=status.HTTP_400_BAD_REQUEST)

        print(f"Looking for tasks with category: {category}")  # Add for debugging

        # Filter tasks by the category
        try:
            tasks = self.get_queryset().filter(category=category)
            serializer = self.get_serializer(tasks, many=True)
            return Response(serializer.data)
        except Exception as e:
            return Response(
                {"detail": f"Error fetching tasks: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    def get_object(self):
        """
        Override get_object to handle MongoDB ObjectIds in the URL
        """
        queryset = self.filter_queryset(self.get_queryset())

        # Get the lookup value from the URL
        lookup_url_kwarg = self.lookup_url_kwarg or self.lookup_field
        lookup_value = self.kwargs[lookup_url_kwarg]

        # Try to convert to ObjectId if it's a string
        if isinstance(lookup_value, str) and len(lookup_value) == 24:
            try:
                lookup_value = ObjectId(lookup_value)
            except:
                pass

        filter_kwargs = {self.lookup_field: lookup_value}
        obj = get_object_or_404(queryset, **filter_kwargs)

        # Check permissions
        self.check_object_permissions(self.request, obj)

        return obj

    @action(detail=True, methods=['patch'])
    def complete(self, request, pk=None):
        try:
            task = self.get_object()
            serializer = TaskCompletionSerializer(data=request.data)

            if serializer.is_valid():
                task.is_completed = serializer.validated_data['is_completed']
                task.save()
                return Response(TaskSerializer(task).data)
            else:
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response(
                {"detail": f"Error updating task: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @action(detail=False, methods=['get'])
    def by_category(self, request):
        """
        Get tasks by category from the URL path
        """
        # Determine the category from the URL path
        path = request.path
        category = path.split('/')[-2]  # Gets 'daily', 'exercise', etc.

        # Filter tasks by the category
        tasks = self.get_queryset().filter(category=category)
        serializer = self.get_serializer(tasks, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def stats(self, request):
        """Get task completion statistics by category"""
        # Get all tasks for the user
        all_tasks = self.get_queryset()

        # Create stats dictionary
        stats = {}

        # Get completion stats for each category
        for category in TaskCategory.choices:
            category_code = category[0]

            # Filter tasks by category
            category_tasks = all_tasks.filter(category=category_code)
            total = category_tasks.count()
            completed = category_tasks.filter(is_completed=True).count()

            # Calculate completion percentage
            completion_percentage = 0
            if total > 0:
                completion_percentage = (completed / total) * 100

            stats[category_code] = {
                'total': total,
                'completed': completed,
                'completion_percentage': completion_percentage
            }

        # Calculate overall stats
        total_tasks = all_tasks.count()
        completed_tasks = all_tasks.filter(is_completed=True).count()

        # Calculate overall percentage
        overall_percentage = 0
        if total_tasks > 0:
            overall_percentage = (completed_tasks / total_tasks) * 100

        stats['overall'] = {
            'total': total_tasks,
            'completed': completed_tasks,
            'completion_percentage': overall_percentage
        }

        return Response(stats)

    @action(detail=False, methods=['post'])
    def generate(self, request):
        category = request.data.get('category')

        # Validate category if provided
        if category and category not in [choice[0] for choice in TaskCategory.choices]:
            return Response(
                {"detail": f"Invalid category. Options: {[choice[0] for choice in TaskCategory.choices]}"},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            # Track which AI service is used
            provider = 'rule-based'
            if hasattr(settings, 'GEMINI_API_KEY') and settings.GEMINI_API_KEY:
                provider = 'gemini'
            elif hasattr(settings, 'OPENAI_API_KEY') and settings.OPENAI_API_KEY:
                provider = 'openai'

            # Generate tasks using ML integration
            generated_tasks = MLTaskGenerator.generate_tasks(request.user, category)

            # Save the generated tasks
            tasks = []
            for task_data in generated_tasks:
                # Convert string time to TimeField
                reminder_time = None
                if 'reminder_time' in task_data and task_data['reminder_time']:
                    if isinstance(task_data['reminder_time'], str):
                        # Parse the time string
                        try:
                            from datetime import datetime
                            time_obj = datetime.strptime(task_data['reminder_time'], '%H:%M:%S').time()
                            reminder_time = time_obj
                        except ValueError:
                            try:
                                time_obj = datetime.strptime(task_data['reminder_time'], '%H:%M').time()
                                reminder_time = time_obj
                            except ValueError:
                                pass

                # Create the task
                task = Task.objects.create(
                    user=request.user,
                    title=task_data['title'],
                    category=task_data['category'],
                    reminder_time=reminder_time,
                    note=task_data.get('note'),
                )
                tasks.append(task)

            serializer = TaskSerializer(tasks, many=True)
            return Response({
                'success': True,
                'data': serializer.data,
                'provider': provider,
                'count': len(tasks)
            }, status=status.HTTP_201_CREATED)
        except Exception as e:
            # Handle the error gracefully
            return Response({
                'success': False,
                'detail': "Error generating tasks. Using default tasks instead.",
                'error': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    @action(detail=False, methods=['delete'])
    def clear_completed(self, request):
        """Delete all completed tasks"""
        # Get all completed tasks for the user
        completed_tasks = self.get_queryset().filter(is_completed=True)

        # Get count before deletion
        deleted_count = completed_tasks.count()

        # Delete the tasks
        completed_tasks.delete()

        return Response({"deleted_count": deleted_count}, status=status.HTTP_200_OK)

    @action(detail=False, methods=['post'], url_path='update-completion')
    def update_completion(self, request):
        """Update task completion status - compatibility endpoint for frontend"""
        # Get data from request
        task_id = request.data.get('id')
        is_completed = request.data.get('isCompleted')

        # If task_id is not provided, try to use category and index as fallback
        if not task_id:
            category = request.data.get('category')
            index = request.data.get('index')

            if category is not None and index is not None:
                # Get tasks by category
                tasks = self.get_queryset().filter(category=category)

                if index >= 0 and index < tasks.count():
                    task = tasks[index]
                    task.is_completed = is_completed
                    task.save()
                    return Response(TaskSerializer(task).data)

                return Response({"detail": "Task not found"}, status=status.HTTP_404_NOT_FOUND)
        else:
            # Use task_id to find and update the task
            try:
                task = self.get_queryset().get(_id=ObjectId(task_id))
                task.is_completed = is_completed
                task.save()
                return Response(TaskSerializer(task).data)
            except Task.DoesNotExist:
                return Response({"detail": "Task not found"}, status=status.HTTP_404_NOT_FOUND)

        return Response({"detail": "Invalid request data"}, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'])
    def daily_summary(self, request):
        """Get a summary of today's tasks"""
        from django.utils import timezone
        today = timezone.now().date()

        # Get tasks created today
        today_tasks = self.get_queryset().filter(created_at__date=today)

        # Count tasks by category and completion status
        summary = {}

        for category in TaskCategory.choices:
            category_code = category[0]

            # Filter today's tasks by category
            category_tasks = today_tasks.filter(category=category_code)
            total = category_tasks.count()
            completed = category_tasks.filter(is_completed=True).count()

            summary[category_code] = {
                'total': total,
                'completed': completed,
                'remaining': total - completed
            }

        # Overall summary
        total = today_tasks.count()
        completed = today_tasks.filter(is_completed=True).count()

        summary['overall'] = {
            'total': total,
            'completed': completed,
            'remaining': total - completed,
            'completion_percentage': (completed / total * 100) if total > 0 else 0
        }

        return Response(summary)