from django.db import models

class Questionnaire(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField()

    def __str__(self):
        return self.title


class Item(models.Model):
    questionnaire = models.ForeignKey(Questionnaire, on_delete=models.CASCADE, related_name='items')
    item_id = models.CharField(max_length=5)  # For example, "a", "b", "c", etc.
    text = models.CharField(max_length=255)

    def __str__(self):
        return self.text


class Question(models.Model):
    QUESTION_TYPES = [
        ('multi_select', 'Multi Select'),
        ('dropdown', 'Dropdown'),
    ]

    questionnaire = models.ForeignKey(Questionnaire, on_delete=models.CASCADE, related_name='questions')
    question_id = models.IntegerField()
    text = models.TextField()
    type = models.CharField(max_length=20, choices=QUESTION_TYPES, blank=True, null=True)
    options = models.JSONField()  # Store the options as a JSON array
    items_reference = models.ManyToManyField(Item, blank=True)  # Reference to items

    def __str__(self):
        return f"Q{self.question_id}: {self.text[:30]}..."
