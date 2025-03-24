from django.db import models
from users.models import User
from djongo.models import ObjectIdField


class Substance(models.Model):
    _id = ObjectIdField()
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.name


class AssistQuestionnaire(models.Model):
    RISK_LEVELS = (
        ('low', 'Low Risk'),
        ('moderate', 'Moderate Risk'),
        ('high', 'High Risk'),
    )

    _id = ObjectIdField()
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='questionnaires')
    date_completed = models.DateTimeField(auto_now_add=True)
    overall_risk_level = models.CharField(max_length=10, choices=RISK_LEVELS)
    highest_score = models.IntegerField()
    other_substance_specify = models.CharField(max_length=100, blank=True, null=True)

    def __str__(self):
        return f"{self.user.username}'s ASSIST - {self.date_completed.strftime('%Y-%m-%d')}"


class SubstanceResponse(models.Model):
    _id = ObjectIdField()
    questionnaire = models.ForeignKey(AssistQuestionnaire, on_delete=models.CASCADE, related_name='substance_responses')
    substance = models.ForeignKey(Substance, on_delete=models.CASCADE)
    used_in_lifetime = models.BooleanField(default=False)
    frequency_last_3_months = models.IntegerField(default=0)
    urge_to_use = models.IntegerField(default=0)
    health_social_problems = models.IntegerField(default=0)
    failed_responsibilities = models.IntegerField(default=0)
    concern_from_others = models.IntegerField(default=0)
    tried_to_control = models.IntegerField(default=0)
    injected = models.BooleanField(default=False)
    injection_frequency = models.IntegerField(default=0)
    calculated_score = models.IntegerField(default=0)
    risk_level = models.CharField(max_length=10, choices=AssistQuestionnaire.RISK_LEVELS)

    def calculate_score(self):
        # Skip Q5 (failed_responsibilities) for tobacco
        if 'Tobacco' in self.substance.name:
            score = (self.frequency_last_3_months +
                     self.urge_to_use +
                     self.health_social_problems +
                     self.concern_from_others +
                     self.tried_to_control)
        else:
            score = (self.frequency_last_3_months +
                     self.urge_to_use +
                     self.health_social_problems +
                     self.failed_responsibilities +
                     self.concern_from_others +
                     self.tried_to_control)

        return score

    def determine_risk_level(self):
        score = self.calculate_score()

        if 'Alcohol' in self.substance.name:
            if score >= 0 and score <= 10:
                return 'low'
            elif score >= 11 and score <= 26:
                return 'moderate'
            else:  # score >= 27
                return 'high'
        else:
            if score >= 0 and score <= 3:
                return 'low'
            elif score >= 4 and score <= 26:
                return 'moderate'
            else:  # score >= 27
                return 'high'

    def __str__(self):
        return f"{self.substance.name} - {self.questionnaire.user.username}"