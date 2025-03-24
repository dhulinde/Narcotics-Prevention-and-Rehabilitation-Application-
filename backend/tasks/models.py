from django.db import models
from users.models import User
from djongo.models import ObjectIdField

class TaskCategory(models.TextChoices):
    DAILY = 'daily', 'Daily Tasks'
    EXERCISE = 'exercise', 'Exercise'
    WELLNESS = 'wellness', 'Wellness'
    MEDICATION = 'medication', 'Medication'
    SOCIAL = 'social', 'Social'

class Task(models.Model):
    _id = ObjectIdField()
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='tasks')
    title = models.CharField(max_length=255)
    category = models.CharField(max_length=20, choices=TaskCategory.choices)
    is_completed = models.BooleanField(default=False)
    reminder_time = models.TimeField(blank=True, null=True)
    note = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['category', 'created_at']

    def __str__(self):
        return f"{self.title} ({self.category}) - {self.user.username}"