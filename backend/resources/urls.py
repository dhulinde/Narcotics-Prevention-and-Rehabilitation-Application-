from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ResourceViewSet

router = DefaultRouter()
router.register(r'', ResourceViewSet, basename='resource')

urlpatterns = [
    path('', include(router.urls)),
    path('category/<str:type>/', ResourceViewSet.as_view({'get': 'category'}), name='resource-category'),
    path('toggle-favorite/<str:pk>/', ResourceViewSet.as_view({'post': 'favorite'}), name='toggle-favorite'),
]