from rest_framework.response import Response
from rest_framework import status


def success_response(data=None, message=None, status_code=status.HTTP_200_OK, **kwargs):
    """
    Standard success response format
    """
    response_data = {
        'success': True,
    }

    if data is not None:
        response_data['data'] = data

    if message:
        response_data['message'] = message

    # Add any additional kwargs to the response
    response_data.update(kwargs)

    return Response(response_data, status=status_code)


def error_response(message, errors=None, status_code=status.HTTP_400_BAD_REQUEST):
    """
    Standard error response format
    """
    response_data = {
        'success': False,
        'message': message,
    }

    if errors:
        response_data['errors'] = errors

    return Response(response_data, status=status_code)