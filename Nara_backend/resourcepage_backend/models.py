from django.db import models
#from users.models import User 

#Import User model once it's defined

class ResourceType(models.TextChoices):
    BOOK = 'book', 'Book'
    ARTICLE = 'article', 'Article'
    VIDEO = 'video', 'Video'
    PODCAST = 'podcast', 'Podcast'
    WEBSITE = 'website', 'Website'

class Resource(models.Model):
    # # _id = ObjectIdField()
    title = models.CharField(max_length=255)
    description = models.TextField()
    type = models.CharField(max_length=20, choices=ResourceType.choices)
    thumbnail_url = models.URLField()
    author = models.CharField(max_length=100)
    date = models.CharField(max_length=50)  # Could be a year or a specific date
    url = models.URLField()
    tags = models.TextField(blank=True, default="")  # Comma-separated tags
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    # Optional external source data
    source = models.CharField(max_length=100, blank=True, null=True)  # e.g., "PubMed", "YouTube"
    external_id = models.CharField(max_length=255, blank=True, null=True)  # ID from external source

    class Meta:
        ordering = ['-created_at']
        # MongoDB doesn't use traditional indexes, so we'll use MongoDB-compatible indexing
        indexes = [
            models.Index(fields=['type']),
            models.Index(fields=['title']),
            models.Index(fields=['created_at']),
        ]

    def __str__(self):
        return f"{self.title} ({self.type})"

    def get_tags(self):
        """Convert stored tags string to list"""
        if not self.tags:
            return []
        return [tag.strip() for tag in self.tags.split(',')]

    def set_tags(self, tags_list):
        """Convert list to string for storage"""
        if isinstance(tags_list, list):
            self.tags = ','.join(tags_list)

class FavoriteResource(models.Model):
    # # _id = ObjectIdField()
    user = models.ForeignKey("User", on_delete=models.CASCADE, related_name='favorite_resources') # User model is not defined in this file so I use a string, will change it once user models is defined. (Remove the "" to fix)
    resource = models.ForeignKey(Resource, on_delete=models.CASCADE)
    date_added = models.DateTimeField(auto_now_add=True)

    class Meta:
        # MongoDB doesn't support unique_together in the traditional sense
        # This will need to be enforced at the application level or using MongoDB-specific indexing
        ordering = ['-date_added']

    def __str__(self):
        return f"{self.user.username}'s favorite: {self.resource.title}"