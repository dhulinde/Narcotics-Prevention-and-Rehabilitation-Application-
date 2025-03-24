from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.exceptions import InvalidToken, AuthenticationFailed
from django.utils import timezone


class CustomJWTAuthentication(JWTAuthentication):
    def get_user(self, validated_token):
        """
        Attempt to find and return a user using the given validated token.
        Also checks if the user's refresh token is still valid.
        """
        user = super().get_user(validated_token)

        if user is None:
            raise AuthenticationFailed('User not found', code='user_not_found')

        # Check if token was issued before the user logged out
        if user.token_updated_at:
            token_iat = validated_token.get('iat')
            if token_iat:
                # Convert timestamp to datetime
                token_issued_at = timezone.datetime.fromtimestamp(token_iat, tz=timezone.utc)

                # If token was issued before the user updated their token (logged out)
                # and the user doesn't have a valid refresh token, reject it
                if token_issued_at < user.token_updated_at and user.refresh_token is None:
                    raise InvalidToken('Token is no longer valid', code='token_not_valid')

        # Deny access if account is inactive
        if not user.is_active:
            raise AuthenticationFailed('User is inactive', code='user_inactive')

        return user