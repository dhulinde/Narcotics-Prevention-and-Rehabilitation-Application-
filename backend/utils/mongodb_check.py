import os
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, ServerSelectionTimeoutError

def check_mongodb_connection():
    """
    Utility to check MongoDB Atlas connection
    Returns tuple of (is_connected, error_message)
    """
    mongo_uri = os.getenv('MONGO_URI')

    if not mongo_uri:
        return False, "MongoDB URI not found in environment variables"

    try:
        # Try to connect to MongoDB Atlas
        client = MongoClient(mongo_uri, serverSelectionTimeoutMS=5000)
        # The ismaster command is cheap and does not require auth
        client.admin.command('ismaster')
        return True, "Connected to MongoDB Atlas"
    except ConnectionFailure as e:
        return False, f"MongoDB Atlas connection failed: {e}"
    except ServerSelectionTimeoutError as e:
        return False, f"MongoDB Atlas server selection timeout: {e}"
    except Exception as e:
        return False, f"Error connecting to MongoDB Atlas: {e}"