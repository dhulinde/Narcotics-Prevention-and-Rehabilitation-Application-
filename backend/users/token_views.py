from rest_framework_simplejwt.views import TokenRefreshView
from rest_framework.response import Response
from rest_framework import status

class CustomTokenRefreshView(TokenRefreshView):
    """
    Very minimal token refresh view - using the default implementation
    """
    pass