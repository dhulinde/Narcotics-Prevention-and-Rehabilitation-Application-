# list_substances.py
import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'nara.settings')
django.setup()

from assessment.models import Substance

substances = Substance.objects.all()
for substance in substances:
    print(f"ID: {substance._id}, Name: {substance.name}")