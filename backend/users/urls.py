from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .token_views import CustomTokenRefreshView
from .views import UserViewSet

router = DefaultRouter()
router.register(r'', UserViewSet, basename='user')

urlpatterns = [
    path('', include(router.urls)),
    path('token/refresh/', CustomTokenRefreshView.as_view(), name='token_refresh'),
    # Add additional path for profile to match the Flutter endpoint
    path('profile/', UserViewSet.as_view({'get': 'profile'}), name='user-profile'),
    path('status/', UserViewSet.as_view({'get': 'status'}), name='user-status'),

]