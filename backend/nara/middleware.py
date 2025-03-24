from django.utils.deprecation import MiddlewareMixin
from django.conf import settings
from pymongo import MongoClient
import os
import threading

# Thread-local storage for MongoDB connections
_thread_locals = threading.local()

class MongoDBConnectionMiddleware(MiddlewareMixin):
    """
    Middleware that adds MongoDB connection to each request
    """

    def process_request(self, request):
        # Get MongoDB connection settings
        MONGO_URI = os.getenv('MONGO_URI', settings.DATABASES['default']['CLIENT']['host'])
        DB_NAME = os.getenv('MONGO_DB_NAME', settings.DATABASES['default']['NAME'])

        # Create or get MongoDB client
        if not hasattr(_thread_locals, 'mongo_client'):
            _thread_locals.mongo_client = MongoClient(MONGO_URI)

        # Add MongoDB client and database to request
        request.mongo_client = _thread_locals.mongo_client
        request.mongo_db = _thread_locals.mongo_client[DB_NAME]

        return None

    def process_response(self, request, response):
        # Connection is kept open for performance, will be closed when app shuts down
        return response