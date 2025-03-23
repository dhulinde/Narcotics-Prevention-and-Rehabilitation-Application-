from django.contrib.auth.backends import ModelBackend
from django.contrib.auth import get_user_model
from pymongo import MongoClient
from django.conf import settings
import os

User = get_user_model()

class MongoDBAuthBackend(ModelBackend):
    """
    Custom authentication backend that checks MongoDB for user credentials
    """

    def authenticate(self, request, username=None, password=None, **kwargs):
        # First try the standard Django model authentication
        user = super().authenticate(request, username=username, password=password, **kwargs)
        if user:
            return user

        # If that fails, check MongoDB
        try:
            # Connect to MongoDB
            MONGO_URI = os.getenv('MONGO_URI', settings.DATABASES['default']['CLIENT']['host'])
            DB_NAME = os.getenv('MONGO_DB_NAME', settings.DATABASES['default']['NAME'])

            client = MongoClient(MONGO_URI)
            db = client[DB_NAME]

            # Find user in MongoDB
            user_data = db.users.find_one({"username": username})

            if user_data:
                # Get or create Django user
                try:
                    user = User.objects.get(username=username)
                    # Check if password matches
                    if user.check_password(password):
                        return user
                except User.DoesNotExist:
                    # Create new user from MongoDB data
                    user = User(
                        username=user_data['username'],
                        email=user_data.get('email', ''),
                    )
                    user.set_password(password)
                    user.save()
                    return user
        except Exception as e:
            print(f"MongoDB authentication error: {e}")

        return None