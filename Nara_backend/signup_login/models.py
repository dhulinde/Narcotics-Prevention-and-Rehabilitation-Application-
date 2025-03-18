from django.db import models

class User(models.Model):
    _id = models.ObjectIdField()
    username = models.CharField(max_length=150, unique=True)
    email = models.EmailField(null=True, blank=True)
    password = models.CharField(max_length=255)
    security_question = models.TextField()
    security_answer = models.CharField(max_length=255)
    display_name = models.CharField(max_length=150)
    date_of_birth = models.DateField(null=True)
    recovery_start_date = models.DateField(null=True)

    def __str__(self):
        return self.username
