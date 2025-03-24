#!/usr/bin/env python
"""
MongoDB Atlas Connection & Initialization Script
- Verifies connection to MongoDB Atlas
- Creates necessary collections
- Sets up indexes for optimal performance
"""
import os
import sys
import django
import pymongo
import certifi
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, ServerSelectionTimeoutError
from dotenv import load_dotenv

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'nara.settings')
django.setup()

def init_mongodb():
    # Load environment variables
    load_dotenv()

    # Get MongoDB connection details
    mongo_uri = os.getenv('MONGO_URI')
    db_name = os.getenv('MONGO_DB_NAME', 'nara_db')

    if not mongo_uri:
        print("ERROR: MONGO_URI not found in .env file.")
        print("Please make sure you have a valid .env file with MONGO_URI defined.")
        return False

    # Test MongoDB connection
    try:
        print(f"Testing connection to MongoDB Atlas...")
        client = MongoClient(
            mongo_uri,
            serverSelectionTimeoutMS=5000,
            tlsCAFile=certifi.where()  # Use certifi's certificates
        )

        # Force connection to verify it works
        client.admin.command('ismaster')
        print("✅ Successfully connected to MongoDB Atlas!")

        # Access the database
        db = client[db_name]
        print(f"Testing access to database '{db_name}'...")

        # Try to list collections to verify database access
        collections = db.list_collection_names()
        print(f"✅ Successfully accessed database. Found {len(collections)} collections.")

        # Define required collections
        required_collections = [
            'users', 'assessments', 'treatment_plans', 'tasks',
            'moods', 'journals', 'chats', 'resources'
        ]

        # Create collections if they don't exist
        for collection_name in required_collections:
            if collection_name not in collections:
                print(f"Creating collection: {collection_name}")
                db.create_collection(collection_name)

        # Create indexes for better performance
        print("Creating indexes for optimal performance...")

        # Users collection indexes
        db.users.create_index([("username", pymongo.ASCENDING)], unique=True)
        db.users.create_index([("email", pymongo.ASCENDING)])

        # Assessments collection indexes
        db.assessments.create_index([("user", pymongo.ASCENDING), ("date_completed", pymongo.ASCENDING)])

        # Treatment plans collection indexes
        db.treatment_plans.create_index([("name", pymongo.ASCENDING)])
        db.treatment_plans.create_index([("user", pymongo.ASCENDING)])

        # Tasks collection indexes
        db.tasks.create_index([("user", pymongo.ASCENDING), ("category", pymongo.ASCENDING)])
        db.tasks.create_index([("is_completed", pymongo.ASCENDING)])

        # Moods collection indexes
        db.moods.create_index([("user", pymongo.ASCENDING), ("date", pymongo.ASCENDING)])

        # Journals collection indexes
        db.journals.create_index([("user", pymongo.ASCENDING), ("date", pymongo.ASCENDING)])

        # Chats collection indexes
        db.chats.create_index([("user", pymongo.ASCENDING), ("timestamp", pymongo.ASCENDING)])

        # Resources collection indexes
        db.resources.create_index([("title", pymongo.TEXT), ("description", pymongo.TEXT), ("tags", pymongo.TEXT)])
        db.resources.create_index([("type", pymongo.ASCENDING)])

        print("✅ MongoDB setup complete!")
        return True

    except ConnectionFailure as e:
        print(f"❌ ERROR: Could not connect to MongoDB Atlas: {e}")
        print("Please check your MONGO_URI in the .env file.")
    except ServerSelectionTimeoutError as e:
        print(f"❌ ERROR: Server selection timeout: {e}")
        print("This usually means your connection string is correct but the server is not reachable.")
        print("Check your network connection, IP whitelist, or firewall settings.")
    except Exception as e:
        print(f"❌ ERROR: An unexpected error occurred: {e}")

    return False

def check_mongodb_health():
    """Simple check to verify MongoDB connection without making changes"""
    load_dotenv()
    mongo_uri = os.getenv('MONGO_URI')

    if not mongo_uri:
        return False, "MongoDB URI not found in environment variables"

    try:
        client = MongoClient(
            mongo_uri,
            serverSelectionTimeoutMS=5000,
            tlsCAFile=certifi.where()  # Use certifi's certificates
        )
        client.admin.command('ismaster')
        return True, "Connected to MongoDB Atlas"
    except Exception as e:
        return False, f"Error connecting to MongoDB Atlas: {e}"

if __name__ == "__main__":
    print("==========================")
    print("MongoDB Setup & Connection")
    print("==========================")

    # Parse command line arguments
    if len(sys.argv) > 1 and sys.argv[1] == "--check-only":
        success, message = check_mongodb_health()
        print(f"MongoDB connection check: {message}")
        sys.exit(0 if success else 1)
    else:
        success = init_mongodb()

        if success:
            print("\nYour MongoDB Atlas connection is set up and ready to use!")
            print("You should now be able to run your Django application.")
            sys.exit(0)
        else:
            print("\nFailed to set up MongoDB Atlas connection.")
            print("Please fix the connection issues before running your Django application.")
            sys.exit(1)