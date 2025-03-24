# treatment_plans/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import TreatmentPlanViewSet, UserTreatmentPlanViewSet

router = DefaultRouter()
router.register(r'plans', TreatmentPlanViewSet, basename='treatment-plan')
router.register(r'user-plans', UserTreatmentPlanViewSet, basename='user-treatment-plan')

urlpatterns = [
    path('', include(router.urls)),
    # Change this to include a trailing slash
    path('select/', UserTreatmentPlanViewSet.as_view({'post': 'select'}), name='select-plan'),
    path('current/', UserTreatmentPlanViewSet.as_view({'get': 'current'}), name='current-plan'),
    path('status/', UserTreatmentPlanViewSet.as_view({'get': 'status'}), name='plan-status'),
]