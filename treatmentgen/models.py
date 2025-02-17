from django.db import models
from django.contrib.auth.models import User
from django.core.validators import MinValueValidator, MaxValueValidator

class Assessment(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    
    # Scores from the screening test
    score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)]
    )
    
    @property
    def determine_risk_level(self):
        if self.score >= 80:
            return 'high'
        elif self.score >= 50:
            return 'moderate'
        else:
            return 'low'
    
    def __str__(self):
        return f"Assessment for {self.user.username} - Score: {self.score}"

class TreatmentPlan(models.Model):
    RISK_LEVELS = [
        ('low', 'Low Risk'),
        ('moderate', 'Moderate Risk'),
        ('high', 'High Risk')
    ]
    
    risk_level = models.CharField(max_length=10, choices=RISK_LEVELS)
    title = models.CharField(max_length=200)
    description = models.TextField()
    
    # Structured treatment components
    morning_routine = models.JSONField()
    daily_activities = models.JSONField()
    evening_routine = models.JSONField()
    weekly_activities = models.JSONField()
    support_meetings = models.JSONField()
    created_at = models.DateTimeField(auto_now_add=True)
    
    @classmethod
    def create_from_assessment(cls, assessment):
        risk_level = assessment.determine_risk_level()
        
        # Default plans based on risk level
        plans = {
            'low': {
                'title': 'Prevention-Focused Plan',
                'description': 'A light-touch plan focused on awareness and prevention',
                'morning_routine': [
                    '10-minute meditation',
                    'Light stretching',
                    'Healthy breakfast'
                ],
                'daily_activities': [
                    '30-minute walk',
                    'Journaling session',
                    'Mindfulness practice'
                ],
                'evening_routine': [
                    'Relaxation exercises',
                    'Reflection time',
                    'Sleep hygiene routine'
                ],
                'weekly_activities': [
                    'Support group meeting',
                    'Counseling session',
                    'Wellness activity'
                ],
                'support_meetings': [
                    'Weekly check-in',
                    'Monthly progress review'
                ]
            },
            'moderate': {
                'title': 'Balanced Recovery Plan',
                'description': 'A comprehensive plan balancing treatment and daily life',
                'morning_routine': [
                    '20-minute meditation',
                    'Exercise routine',
                    'Structured breakfast',
                    'Medication check'
                ],
                'daily_activities': [
                    'Therapy exercises',
                    'Stress management',
                    'Physical activity',
                    'Support group contact'
                ],
                'evening_routine': [
                    'Trigger review',
                    'Coping skills practice',
                    'Evening check-in',
                    'Relaxation routine'
                ],
                'weekly_activities': [
                    'Two support meetings',
                    'Therapy session',
                    'Family counseling',
                    'Skills workshop'
                ],
                'support_meetings': [
                    'Bi-weekly counseling',
                    'Weekly group therapy',
                    'Family support session'
                ]
            },
            'high': {
                'title': 'Intensive Recovery Program',
                'description': 'An intensive plan with comprehensive support and monitoring',
                'morning_routine': [
                    '30-minute meditation',
                    'Exercise program',
                    'Structured meal plan',
                    'Medication management',
                    'Morning check-in'
                ],
                'daily_activities': [
                    'Multiple therapy sessions',
                    'Crisis prevention exercises',
                    'Structured activities',
                    'Regular support contact',
                    'Skills practice'
                ],
                'evening_routine': [
                    'Detailed day review',
                    'Group support session',
                    'Coping skills review',
                    'Structured wind-down',
                    'Support contact'
                ],
                'weekly_activities': [
                    'Daily support meetings',
                    'Intensive therapy',
                    'Family sessions',
                    'Medical check-ups',
                    'Progress evaluation'
                ],
                'support_meetings': [
                    'Daily group therapy',
                    'Twice-weekly counseling',
                    'Weekly family therapy',
                    'Crisis support access'
                ]
            }
        }
        
        plan_data = plans[risk_level]
        return cls.objects.create(
            risk_level=risk_level,
            **plan_data
        )

class PatientTreatment(models.Model):
    patient = models.ForeignKey(User, on_delete=models.CASCADE)
    treatment_plan = models.ForeignKey(TreatmentPlan, on_delete=models.CASCADE)
    assigned_at = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)
    notes = models.TextField(blank=True, null=True)
    
    class Meta:
        ordering = ['-assigned_at']

    def __str__(self):
        return f"{self.patient.username}'s {self.treatment_plan.title}"