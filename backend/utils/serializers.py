from rest_framework import serializers


class MongoBaseSerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='_id', read_only=True)

    class Meta:
        abstract = True