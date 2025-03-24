from django.db import models
from users.models import User
from djongo.models import ObjectIdField

class ChatMessage(models.Model):
    _id = ObjectIdField()
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='chat_messages')
    text = models.TextField()
    is_user_message = models.BooleanField(default=True)
    timestamp = models.DateTimeField(auto_now_add=True)

    # Fields for message analysis
    sentiment = models.CharField(max_length=20, blank=True, null=True)
    emotions = models.JSONField(blank=True, null=True)
    triggers = models.JSONField(blank=True, null=True)
    topics = models.JSONField(blank=True, null=True)

    class Meta:
        ordering = ['timestamp']

    def __str__(self):
        sender = "User" if self.is_user_message else "Bot"
        return f"{sender} message ({self.timestamp.strftime('%Y-%m-%d %H:%M')}): {self.text[:50]}"