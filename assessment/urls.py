from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import SubstanceViewSet, AssistQuestionnaireViewSet

router = DefaultRouter()
router.register(r'substances', SubstanceViewSet, basename='substance')
router.register(r'questionnaires', AssistQuestionnaireViewSet, basename='questionnaire')

urlpatterns = [
    path('', include(router.urls)),
]