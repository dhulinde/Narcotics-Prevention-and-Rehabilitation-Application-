# users/authentication.py
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.exceptions import InvalidToken, AuthenticationFailed
from django.utils import timezone
from pymongo import MongoClient
from django.conf import settings
from bson import ObjectId
import os


class CustomJWTAuthentication(JWTAuthentication):
    # Explicitly define the user_id_claim attribute
    user_id_claim = 'user_id'

    def get_user(self, validated_token):
        """
        Attempt to find and return a user using the given validated token.
        Also checks if the user's refresh token is still valid.
        """
        try:
            user_id = validated_token[self.user_id_claim]

            # Try to get user by string ID first
            try:
                user = self.user_model.objects.get(pk=user_id)
            except self.user_model.DoesNotExist:
                # If not found, try converting to ObjectId
                try:
                    user = self.user_model.objects.get(_id=ObjectId(user_id))
                except:
                    raise self.user_model.DoesNotExist()

            if user is None:
                raise AuthenticationFailed('User not found', code='user_not_found')

            # Check if token was issued before the user logged out
            if user.token_updated_at:
                token_iat = validated_token.get('iat')
                if token_iat:
                    # Convert timestamp to timezone-aware datetime
                    token_issued_at = timezone.datetime.fromtimestamp(token_iat, tz=timezone.utc)

                    # Ensure user.token_updated_at is timezone-aware
                    if timezone.is_naive(user.token_updated_at):
                        user_token_updated = timezone.make_aware(user.token_updated_at)
                    else:
                        user_token_updated = user.token_updated_at

                    # If token was issued before the user updated their token (logged out)
                    # and the user doesn't have a valid refresh token, reject it
                    if token_issued_at < user_token_updated and user.refresh_token is None:
                        raise InvalidToken('Token is no longer valid', code='token_not_valid')

            # Verify token against MongoDB storage (additional security check)
            try:
                # Get MongoDB connection
                MONGO_URI = os.getenv('MONGO_URI', settings.DATABASES['default']['CLIENT']['host'])
                DB_NAME = os.getenv('MONGO_DB_NAME', settings.DATABASES['default']['NAME'])
                client = MongoClient(MONGO_URI)
                db = client[DB_NAME]

                # Check if user exists in MongoDB
                user_doc = db.users.find_one({"username": user.username})

                # If user has token_updated_at in MongoDB, check if the token was issued before it
                if user_doc and 'token_updated_at' in user_doc:
                    mongo_token_updated = user_doc['token_updated_at']
                    if token_iat and mongo_token_updated:
                        # Convert timestamp to timezone-aware datetime if needed
                        token_issued_at = timezone.datetime.fromtimestamp(token_iat, tz=timezone.utc)

                        # Ensure mongo_token_updated is timezone-aware
                        if timezone.is_naive(mongo_token_updated):
                            mongo_token_updated = timezone.make_aware(mongo_token_updated)

                        # Now compare
                        if token_issued_at < mongo_token_updated:
                            # Token was issued before the last token update (logout)
                            raise InvalidToken('Token has been revoked', code='token_revoked')

            except Exception as e:
                print(f"MongoDB token validation error: {e}")
                # Continue authentication process even if MongoDB check fails
                # This prevents authentication failures due to MongoDB connection issues

            # Deny access if account is inactive
            if not user.is_active:
                raise AuthenticationFailed('User is inactive', code='user_inactive')

            return user
        except (self.user_model.DoesNotExist, KeyError):
            raise AuthenticationFailed('User not found', code='user_not_found')

    def authenticate(self, request):
        """
        Override authenticate to add better error handling and logging
        """
        try:
            return super().authenticate(request)
        except InvalidToken as e:
            print(f"Invalid token error: {str(e)}")
            raise
        except AuthenticationFailed as e:
            print(f"Authentication failed: {str(e)}")
            raise
        except Exception as e:
            print(f"Unexpected authentication error: {str(e)}")
            raise AuthenticationFailed(f"Authentication error: {str(e)}")