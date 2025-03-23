from rest_framework import serializers
from .models import Resource, FavoriteResource, ResourceType

class ResourceSerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='_id', read_only=True)
    type_display = serializers.CharField(source='get_type_display', read_only=True)
    tags = serializers.ListField(
        child=serializers.CharField(),
        required=False,
        allow_empty=True
    )
    is_favorite = serializers.SerializerMethodField()

    class Meta:
        model = Resource
        fields = [
            'id', 'title', 'description', 'type', 'type_display',
            'thumbnail_url', 'author', 'date', 'url', 'tags', 'is_favorite'
        ]
        read_only_fields = ['id', 'type_display', 'is_favorite']

    def get_is_favorite(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return FavoriteResource.objects.filter(
                user=request.user,
                resource=obj
            ).exists()
        return False

class FavoriteResourceSerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='_id', read_only=True)
    resource = ResourceSerializer(read_only=True)
    resource_id = serializers.PrimaryKeyRelatedField(
        queryset=Resource.objects.all(),
        source='resource',
        write_only=True
    )

    class Meta:
        model = FavoriteResource
        fields = ['id', 'resource', 'resource_id', 'date_added']
        read_only_fields = ['id', 'date_added']

    def validate(self, data):
        user = self.context['request'].user
        resource = data['resource']

        # Check if this resource is already a favorite
        if FavoriteResource.objects.filter(user=user, resource=resource).exists():
            raise serializers.ValidationError("This resource is already in your favorites.")

        return data

    def create_resources(self, validated_data):
        user = self.context['request'].user
        resource = validated_data['resource']

        return FavoriteResource.objects.create(user=user, resource=resource)