from pymongo import MongoClient
from django.conf import settings
import os

class MongoDBService:
    """Service for interacting with MongoDB Atlas"""

    _client = None
    _db = None

    @classmethod
    def get_client(cls):
        """Get MongoDB client (singleton pattern)"""
        if cls._client is None:
            mongo_uri = os.getenv('MONGO_URI', settings.DATABASES['default']['CLIENT']['host'])
            cls._client = MongoClient(mongo_uri)
        return cls._client

    @classmethod
    def get_db(cls):
        """Get MongoDB database"""
        if cls._db is None:
            db_name = os.getenv('MONGO_DB_NAME', settings.DATABASES['default']['NAME'])
            cls._db = cls.get_client()[db_name]
        return cls._db

    @classmethod
    def get_collection(cls, collection_name):
        """Get MongoDB collection"""
        return cls.get_db()[collection_name]

    @classmethod
    def close_connection(cls):
        """Close MongoDB connection"""
        if cls._client is not None:
            cls._client.close()
            cls._client = None
            cls._db = None