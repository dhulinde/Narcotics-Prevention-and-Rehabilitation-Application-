# mood_tracking/views.py
from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from django.db.models import Count, Case, When, Value, CharField
from django.utils import timezone
from datetime import timedelta
from .models import MoodEntry, JournalEntry, MoodType
from .serializers import MoodEntrySerializer, JournalEntrySerializer, MoodStatsSerializer
from api.mixins import UserOwnershipMixin


class MoodEntryViewSet(UserOwnershipMixin, viewsets.ModelViewSet):
    serializer_class = MoodEntrySerializer
    permission_classes = [permissions.IsAuthenticated]

    # Add this line to fix the missing queryset attribute
    queryset = MoodEntry.objects.all()

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    @action(detail=False, methods=['get'])
    def stats(self, request):
        # Get mood entries from the last 7 days
        now = timezone.now()
        week_ago = now - timedelta(days=7)

        recent_entries = self.get_queryset().filter(date__gte=week_ago, date__lte=now)

        if not recent_entries.exists():
            return Response({
                'average_mood': MoodType.NEUTRAL,
                'best_day': None,
                'worst_day': None,
                'mood_distribution': {mood[0]: 0 for mood in MoodType.choices}
            })

        # Calculate mood distribution
        distribution = {mood[0]: 0 for mood in MoodType.choices}
        mood_values = {mood[0]: idx for idx, mood in enumerate(MoodType.choices)}

        total_value = 0
        best_day = None
        worst_day = None

        for entry in recent_entries:
            distribution[entry.mood] += 1

            # Track best and worst days
            if best_day is None or mood_values[entry.mood] > mood_values[best_day.mood]:
                best_day = entry

            if worst_day is None or mood_values[entry.mood] < mood_values[worst_day.mood]:
                worst_day = entry

            total_value += mood_values[entry.mood]

        # Calculate average mood
        avg_value = total_value / recent_entries.count()
        avg_mood = MoodType.choices[round(avg_value)][0]

        response_data = {
            'average_mood': avg_mood,
            'best_day': MoodEntrySerializer(best_day).data if best_day else None,
            'worst_day': MoodEntrySerializer(worst_day).data if worst_day else None,
            'mood_distribution': distribution
        }

        return Response(response_data)

    @action(detail=False, methods=['get'])
    def timeline(self, request):
        # Get entries for the specified time period (default: last 30 days)
        days = int(request.query_params.get('days', 30))
        now = timezone.now()
        start_date = now - timedelta(days=days)

        entries = self.get_queryset().filter(date__gte=start_date).order_by('date')

        serializer = MoodEntrySerializer(entries, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def history(self, request):
        """Get mood history"""
        limit = int(request.query_params.get('limit', 7))
        entries = self.get_queryset()[:limit]
        serializer = self.get_serializer(entries, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['post'])
    def save(self, request):
        """Save new mood entry"""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(user=request.user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    @action(detail=False, methods=['get'])
    def trends(self, request):
        """Analyze mood trends over time"""
        # Get entries for the last 90 days
        now = timezone.now()
        ninety_days_ago = now - timedelta(days=90)

        entries = self.get_queryset().filter(date__gte=ninety_days_ago)

        # Count occurrences of each mood
        mood_counts = entries.values('mood').annotate(count=Count('mood'))
        mood_counts_list = [{'mood': item['mood'], 'count': item['count']} for item in mood_counts]

        # Group by week and calculate average mood
        weekly_data = []

        for i in range(13):  # 13 weeks = ~90 days
            week_start = now - timedelta(days=i * 7 + 7)
            week_end = now - timedelta(days=i * 7)

            # Filter entries for this week
            week_entries = entries.filter(date__gte=week_start, date__lt=week_end)

            if week_entries.exists():
                # Map mood values to numeric values for averaging
                mood_values = {
                    'very_sad': 0,
                    'sad': 1,
                    'neutral': 2,
                    'happy': 3,
                    'very_happy': 4
                }

                # Calculate average mood value for this week
                week_moods = list(week_entries.values_list('mood', flat=True))
                mood_ints = [mood_values.get(mood, 2) for mood in week_moods]
                avg = sum(mood_ints) / len(mood_ints)

                # Map back to mood string
                mood_mapping = {0: 'very_sad', 1: 'sad', 2: 'neutral', 3: 'happy', 4: 'very_happy'}
                avg_mood = mood_mapping[round(avg)]

                weekly_data.append({
                    'week_start': week_start.date().isoformat(),
                    'week_end': week_end.date().isoformat(),
                    'average_mood': avg_mood,
                    'count': week_entries.count()
                })

        return Response({
            'mood_distribution': mood_counts_list,
            'weekly_trends': weekly_data
        })


class JournalEntryViewSet(UserOwnershipMixin, viewsets.ModelViewSet):
    serializer_class = JournalEntrySerializer
    permission_classes = [permissions.IsAuthenticated]

    # Add this line to fix the missing queryset attribute
    queryset = JournalEntry.objects.all()

    # Ensure this method is properly implemented
    def get_queryset(self):
        return super().get_queryset()

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    @action(detail=False, methods=['get'])
    def recent(self, request):
        # Get recent journal entries
        limit = int(request.query_params.get('limit', 5))
        entries = self.get_queryset().order_by('-date')[:limit]

        serializer = self.get_serializer(entries, many=True)
        return Response(serializer.data)