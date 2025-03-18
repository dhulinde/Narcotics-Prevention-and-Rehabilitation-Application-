from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ResourceViewSet, FavoriteResourceViewSet

router = DefaultRouter()
router.register(r'all', ResourceViewSet, basename='resource')
router.register(r'favorites', FavoriteResourceViewSet, basename='favorite-resource')

urlpatterns = [
    path('', include(router.urls)),
]