from django.db import models
from users.models import User
from djongo.models import ObjectIdField

class MoodType(models.TextChoices):
    VERY_SAD = 'very_sad', 'Very Sad'
    SAD = 'sad', 'Sad'
    NEUTRAL = 'neutral', 'Neutral'
    HAPPY = 'happy', 'Happy'
    VERY_HAPPY = 'very_happy', 'Very Happy'

class MoodEntry(models.Model):
    _id = ObjectIdField()
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='mood_entries')
    date = models.DateTimeField(auto_now_add=True)
    mood = models.CharField(max_length=10, choices=MoodType.choices)
    note = models.TextField()

    class Meta:
        ordering = ['-date']
        verbose_name_plural = 'Mood entries'

    def __str__(self):
        return f"{self.user.username}'s mood on {self.date.strftime('%Y-%m-%d %H:%M')}"

class JournalEntry(models.Model):
    _id = ObjectIdField()
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='journal_entries')
    date = models.DateTimeField(auto_now_add=True)
    text = models.TextField()

    class Meta:
        ordering = ['-date']
        verbose_name_plural = 'Journal entries'

    def __str__(self):
        return f"{self.user.username}'s journal on {self.date.strftime('%Y-%m-%d %H:%M')}"