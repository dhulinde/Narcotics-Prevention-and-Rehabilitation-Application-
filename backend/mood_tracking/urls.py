# mood_tracking/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import MoodEntryViewSet, JournalEntryViewSet

router = DefaultRouter()
router.register(r'entries', MoodEntryViewSet, basename='mood-entry')
router.register(r'journal', JournalEntryViewSet, basename='journal-entry')

urlpatterns = [
    path('', include(router.urls)),
    # Add direct endpoints that match frontend expectations
    path('history/', MoodEntryViewSet.as_view({'get': 'history'}), name='mood-history'),
    path('journal/history/', JournalEntryViewSet.as_view({'get': 'list'}), name='journal-history'),
    path('save/', MoodEntryViewSet.as_view({'post': 'create'}), name='save-mood'),
    path('journal/save/', JournalEntryViewSet.as_view({'post': 'create'}), name='save-journal'),
]