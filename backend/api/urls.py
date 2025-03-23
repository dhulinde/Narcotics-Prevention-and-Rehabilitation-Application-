from django.urls import path, include
from .views import healthcheck

urlpatterns = [
    path('healthcheck/', healthcheck, name='healthcheck'),
    path('users/', include('users.urls')),
    path('assessment/', include('assessment.urls')),
    path('treatment-plans/', include('treatment_plans.urls')),
    path('tasks/', include('tasks.urls')),
    path('mood/', include('mood_tracking.urls')),
    path('chat/', include('chat.urls')),
    path('resources/', include('resources.urls')),
]