# NARA Server Setup Guide

This guide will help you set up and run the NARA server application from scratch.

## Prerequisites

- Python 3.11
- MongoDB (Atlas)
- Git (optional, for cloning the repository)

## Installation Steps

1. **Create and activate a virtual environment**

   ```bash
   python3.11 -m venv venv
   source venv/bin/activate (macos) or venv/Scripts/activate (windows)
    ```

2. **Install required packages**

   ```bash
   pip install -r requirements.txt
   ```

3. **Initialize the MongoDB database connection**

   ```bash
   python3.11 init_mongodb.py
   ```

   This script will verify your MongoDB connection and set up any necessary indexes.

4. **Initialize the database with default data**

   ```bash
   python3.11 init_data.py
   ```

   This script will create substances, treatment plans, resources, and a demo user.

5. **Apply database migrations**

   ```bash
   python3.11 manage.py makemigrations
   python3.11 manage.py migrate
   ```

6. **Run the development server**

   ```bash
   python3.11 manage.py runserver 0.0.0.0:8000
   ```

   The server will be available at http://localhost:8000/
