from django.db import models
from users.models import User
from djongo.models import ObjectIdField

class TreatmentPlan(models.Model):
    _id = ObjectIdField()
    name = models.CharField(max_length=100)
    description = models.TextField()
    duration = models.CharField(max_length=50)
    intensity = models.CharField(max_length=50, default='Moderate')
    color = models.CharField(max_length=7, blank=True, null=True)  # HEX color code
    icon = models.CharField(max_length=50, blank=True, null=True)

    def __str__(self):
        return self.name

class PlanActivity(models.Model):
    _id = ObjectIdField()
    plan = models.ForeignKey(TreatmentPlan, on_delete=models.CASCADE, related_name='activities')
    title = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    icon = models.CharField(max_length=50, blank=True, null=True)

    def __str__(self):
        return f"{self.title} - {self.plan.name}"

class UserTreatmentPlan(models.Model):
    _id = ObjectIdField()
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='treatment_plan')
    plan = models.ForeignKey(TreatmentPlan, on_delete=models.CASCADE)
    start_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username}'s treatment plan - {self.plan.name}"