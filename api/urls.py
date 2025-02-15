from django.urls import path
from . import views

urlpatterns = [
    path('', views.getQuestionnaire),
    path('getQuestionById/<int:questionId>', views.getQuestionById )
]