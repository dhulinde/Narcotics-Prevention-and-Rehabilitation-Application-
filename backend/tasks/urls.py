# tasks/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import TaskViewSet, create_sample_tasks

router = DefaultRouter()
router.register(r'', TaskViewSet, basename='task')

# Define category-specific URL patterns explicitly
category_patterns = [
    path('daily/', TaskViewSet.as_view({'get': 'list_by_category'}), {'category': 'daily'}, name='daily-tasks'),
    path('exercise/', TaskViewSet.as_view({'get': 'list_by_category'}), {'category': 'exercise'}, name='exercise-tasks'),
    path('wellness/', TaskViewSet.as_view({'get': 'list_by_category'}), {'category': 'wellness'}, name='wellness-tasks'),
    path('medication/', TaskViewSet.as_view({'get': 'list_by_category'}), {'category': 'medication'}, name='medication-tasks'),
    path('social/', TaskViewSet.as_view({'get': 'list_by_category'}), {'category': 'social'}, name='social-tasks'),
    path('update/', TaskViewSet.as_view({'post': 'update_completion'}), name='update-task'),
    path('create-samples/', TaskViewSet.as_view({'post': 'create_samples'}), name='create-sample-tasks'),
    path('create-samples-direct/', create_sample_tasks, name='create-samples-direct'),

]

urlpatterns = category_patterns + router.urls