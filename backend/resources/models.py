from django.db import models
from users.models import User
from djongo.models import ObjectIdField

class ResourceType(models.TextChoices):
    BOOK = 'book', 'Book'
    ARTICLE = 'article', 'Article'
    VIDEO = 'video', 'Video'
    PODCAST = 'podcast', 'Podcast'
    WEBSITE = 'website', 'Website'

class Resource(models.Model):
    _id = ObjectIdField()
    title = models.CharField(max_length=255)
    description = models.TextField()
    type = models.CharField(max_length=20, choices=ResourceType.choices)
    thumbnail_url = models.URLField()
    author = models.CharField(max_length=100)
    date = models.CharField(max_length=50)
    url = models.URLField()
    tags = models.TextField(blank=True, default="")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} ({self.type})"

    def get_tags(self):
        return [tag.strip() for tag in self.tags.split(',')] if self.tags else []

    def set_tags(self, tags_list):
        self.tags = ','.join(tags_list) if tags_list else ""

class FavoriteResource(models.Model):
    _id = ObjectIdField()
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='favorite_resources')
    resource = models.ForeignKey(Resource, on_delete=models.CASCADE)
    date_added = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-date_added']
        unique_together = ('user', 'resource')

    def __str__(self):
        return f"{self.user.username}'s favorite: {self.resource.title}"