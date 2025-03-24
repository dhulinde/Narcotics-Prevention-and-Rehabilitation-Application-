from decimal import Decimal
from uuid import UUID
from rest_framework.renderers import JSONRenderer
from bson import ObjectId
import json
from datetime import datetime, time


class MongoJSONEncoder(json.JSONEncoder):
    """
    Custom JSON encoder that handles MongoDB ObjectId and datetime objects
    """
    def default(self, obj):
        if isinstance(obj, ObjectId):
            return str(obj)  # Convert ObjectId to string
        if isinstance(obj, datetime):
            return obj.isoformat()  # Convert datetime to ISO format
        return super().default(obj)

    # Enhance the MongoJSONEncoder to handle more types if needed
    class MongoJSONEncoder(json.JSONEncoder):
        def default(self, obj):
            if isinstance(obj, ObjectId):
                return str(obj)  # Convert ObjectId to string
            if isinstance(obj, datetime):
                return obj.isoformat()  # Convert datetime to ISO format
            if isinstance(obj, time):
                return obj.isoformat()  # Handle time objects
            if isinstance(obj, (Decimal, UUID)):
                return str(obj)  # Handle other special types
            return super().default(obj)

class MongoJSONRenderer(JSONRenderer):
    """
    Custom JSON renderer that uses the MongoJSONEncoder
    """
    encoder_class = MongoJSONEncoder