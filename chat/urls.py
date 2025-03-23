from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ChatMessageViewSet

router = DefaultRouter()
router.register(r'', ChatMessageViewSet, basename='chat')

urlpatterns = [
    path('', include(router.urls)),
    # Explicitly add the analyze endpoint
    path('analyze/', ChatMessageViewSet.as_view({'post': 'analyze'}), name='analyze-chat'),
]