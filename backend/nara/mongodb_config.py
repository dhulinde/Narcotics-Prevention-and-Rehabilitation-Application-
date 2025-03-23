# mongodb_config.py
from pymongo import MongoClient
from django.conf import settings
import os

# Get MongoDB URI from environment variable or use the default Atlas URI
MONGO_URI = os.getenv('MONGO_URI', 'mongodb+srv://username:password@cluster.mongodb.net/')
DB_NAME = os.getenv('MONGO_DB_NAME', 'nara_db')

# Create MongoDB client with proper connection string
mongo_client = MongoClient(MONGO_URI)
db = mongo_client[DB_NAME]

# Collections
users_collection = db['users']
assessments_collection = db['assessments']
treatment_plans_collection = db['treatment_plans']
tasks_collection = db['tasks']
moods_collection = db['moods']
journals_collection = db['journals']
chats_collection = db['chats']
resources_collection = db['resources']