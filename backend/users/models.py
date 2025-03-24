from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.utils import timezone
from djongo.models import ObjectIdField

class UserManager(BaseUserManager):
    def create_user(self, username, email=None, password=None, **extra_fields):
        if not username:
            raise ValueError('The username field must be set')

        email = self.normalize_email(email) if email else None
        user = self.model(username=username, email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, username, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        return self.create_user(username, password=password, **extra_fields)

class User(AbstractBaseUser, PermissionsMixin):
    _id = ObjectIdField()
    username = models.CharField(max_length=150, unique=True)
    email = models.EmailField(blank=True, null=True)
    display_name = models.CharField(max_length=255, blank=True, null=True)
    profile_image = models.ImageField(upload_to='profile_images/', blank=True, null=True)
    date_of_birth = models.DateField(blank=True, null=True)
    recovery_start_date = models.DateTimeField(blank=True, null=True)

    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(default=timezone.now)

    # Security question for password recovery
    security_question = models.CharField(max_length=255, blank=True, null=True)
    security_answer = models.CharField(max_length=255, blank=True, null=True)

    # Token tracking
    last_login = models.DateTimeField(blank=True, null=True)
    refresh_token = models.TextField(blank=True, null=True)
    refresh_token_exp = models.DateTimeField(blank=True, null=True)
    token_updated_at = models.DateTimeField(blank=True, null=True)

    objects = UserManager()

    USERNAME_FIELD = 'username'

    @property
    def id(self):
        """Provide id property that returns _id for compatibility"""
        return self._id

    def __str__(self):
        return self.username

class UserPreference(models.Model):
    _id = ObjectIdField()
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='preferences')
    dark_mode = models.BooleanField(default=False)
    notifications_enabled = models.BooleanField(default=True)
    theme_color = models.CharField(max_length=7, default="#6366F1")  # HEX color

    def __str__(self):
        return f"{self.user.username}'s preferences"