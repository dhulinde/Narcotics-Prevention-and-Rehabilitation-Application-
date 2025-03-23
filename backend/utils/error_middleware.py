import json
import logging
import traceback
from django.http import JsonResponse
from django.utils.deprecation import MiddlewareMixin
from rest_framework import status
from bson.errors import InvalidId
from django.core.exceptions import ObjectDoesNotExist
from django.http import Http404

logger = logging.getLogger(__name__)

class StandardizedErrorMiddleware(MiddlewareMixin):
    """
    Middleware to standardize error handling across the application
    """

    def process_exception(self, request, exception):
        """
        Process exceptions that occur during request handling
        """
        # Log the exception
        logger.error(f"Unhandled exception: {str(exception)}\n{traceback.format_exc()}")

        # Map common exceptions to appropriate status codes and messages
        if isinstance(exception, ObjectDoesNotExist) or isinstance(exception, Http404):
            status_code = status.HTTP_404_NOT_FOUND
            error_message = "Resource not found"
        elif isinstance(exception, InvalidId):
            status_code = status.HTTP_400_BAD_REQUEST
            error_message = "Invalid ID format"
        elif isinstance(exception, json.JSONDecodeError):
            status_code = status.HTTP_400_BAD_REQUEST
            error_message = "Invalid JSON format"
        elif isinstance(exception, PermissionError):
            status_code = status.HTTP_403_FORBIDDEN
            error_message = "Permission denied"
        elif isinstance(exception, ValueError):
            status_code = status.HTTP_400_BAD_REQUEST
            error_message = str(exception)
        else:
            # Default to 500 for unexpected errors
            status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
            error_message = "An unexpected error occurred"

        # Return standardized error response
        return JsonResponse({
            'success': False,
            'message': error_message,
            'error': str(exception)
        }, status=status_code)