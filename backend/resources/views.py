# resources/views.py
from bson import ObjectId
from django.shortcuts import get_object_or_404
from rest_framework import viewsets, permissions, status, filters
from rest_framework.exceptions import PermissionDenied
from rest_framework.response import Response
from rest_framework.decorators import action
from django.db.models import Q
from django_filters.rest_framework import DjangoFilterBackend
import requests
import re
import json
from django.conf import settings

from .models import Resource, FavoriteResource, ResourceType
from .serializers import ResourceSerializer, FavoriteResourceSerializer
from api.mixins import UserOwnershipMixin


class ResourceViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Resource.objects.all()
    serializer_class = ResourceSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['type']
    search_fields = ['title', 'description', 'author', 'tags']
    ordering_fields = ['title', 'date', 'author']

    def get_queryset(self):
        queryset = super().get_queryset()

        # Get resources by type if specified
        resource_type = self.request.query_params.get('type')
        if resource_type and resource_type.lower() in [choice[0] for choice in ResourceType.choices]:
            queryset = queryset.filter(type=resource_type.lower())

        return queryset

    def get_object(self):
        """
        Override get_object to handle MongoDB ObjectIds in the URL
        """
        queryset = self.filter_queryset(self.get_queryset())

        # Get the lookup value from the URL
        lookup_url_kwarg = self.lookup_url_kwarg or self.lookup_field
        lookup_value = self.kwargs[lookup_url_kwarg]

        # Try to convert to ObjectId if it's a string
        try:
            if isinstance(lookup_value, str) and len(lookup_value) == 24:
                lookup_value = ObjectId(lookup_value)
        except:
            pass

        # Use _id instead of id for lookup
        filter_kwargs = {'_id': lookup_value}
        obj = get_object_or_404(queryset, **filter_kwargs)

        # Check permissions
        self.check_object_permissions(self.request, obj)

        return obj

    @action(detail=False, methods=['get'])
    def search(self, request):
        query = request.query_params.get('q', '')
        if not query:
            return Response(ResourceSerializer(self.get_queryset(), many=True, context={'request': request}).data)

        # First search local database
        local_results = self.get_queryset().filter(
            Q(title__icontains=query) |
            Q(description__icontains=query) |
            Q(author__icontains=query) |
            Q(type__icontains=query) |
            Q(tags__contains=query)
        )

        # Return local results if we have enough
        if local_results.count() >= 5:
            serializer = ResourceSerializer(local_results, many=True, context={'request': request})
            return Response(serializer.data)

        # Otherwise, try to fetch additional resources from external sources
        try:
            external_results = self._search_external_resources(query)

            # Save new resources to database
            for result in external_results:
                if not Resource.objects.filter(
                        Q(title=result['title']) &
                        Q(url=result['url'])
                ).exists():
                    Resource.objects.create(**result)

            # Re-query to get all resources including new ones
            updated_results = self.get_queryset().filter(
                Q(title__icontains=query) |
                Q(description__icontains=query) |
                Q(author__icontains=query) |
                Q(type__icontains=query) |
                Q(tags__contains=query)
            )

            serializer = ResourceSerializer(updated_results, many=True, context={'request': request})
            return Response(serializer.data)

        except Exception as e:
            # If external search fails, return local results only
            serializer = ResourceSerializer(local_results, many=True, context={'request': request})
            return Response(serializer.data)

    def _search_external_resources(self, query, limit=10):
        """
        Search for resources from external APIs and websites
        """
        results = []

        # Use actual API integrations
        try:
            # YouTube search for videos
            youtube_results = self._search_youtube(query, limit=3)
            results.extend(youtube_results)

            # PubMed search for academic articles
            pubmed_results = self._search_pubmed(query, limit=3)
            results.extend(pubmed_results)

            # Google Books API for books
            books_results = self._search_books(query, limit=3)
            results.extend(books_results)

            # General web search for articles and websites
            web_results = self._search_web(query, limit=3)
            results.extend(web_results)
        except Exception as e:
            print(f"Error in external resource search: {e}")

        return results[:limit]  # Limit total results

    def _search_youtube(self, query, limit=3):
        """Search YouTube for relevant videos"""
        results = []
        if not settings.YOUTUBE_API_KEY:
            return results

        try:
            search_query = f"{query} addiction recovery"
            url = f"https://www.googleapis.com/youtube/v3/search?part=snippet&q={search_query}&type=video&maxResults={limit}&key={settings.YOUTUBE_API_KEY}"

            response = requests.get(url)
            data = response.json()

            if 'items' in data:
                for item in data['items']:
                    video_id = item['id']['videoId']
                    snippet = item['snippet']
                    thumbnail_url = snippet['thumbnails']['medium']['url'] if 'thumbnails' in snippet and 'medium' in \
                                                                              snippet['thumbnails'] else ""

                    results.append({
                        'title': snippet['title'],
                        'description': snippet['description'],
                        'type': 'video',
                        'thumbnail_url': thumbnail_url,
                        'author': snippet['channelTitle'],
                        'date': snippet['publishedAt'].split('T')[0] if 'publishedAt' in snippet else "",
                        'url': f"https://www.youtube.com/watch?v={video_id}",
                        'tags': query.split(),
                        'source': 'YouTube',
                        'external_id': video_id
                    })
        except Exception as e:
            print(f"YouTube API error: {e}")

        return results

    def _search_pubmed(self, query, limit=3):
        """Search PubMed for academic articles"""
        results = []
        try:
            # Use PubMed API (E-utilities)
            search_query = f"{query} addiction recovery"
            base_url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils"

            # First get IDs
            search_url = f"{base_url}/esearch.fcgi?db=pubmed&term={search_query}&retmode=json&retmax={limit}"
            search_response = requests.get(search_url)
            search_data = search_response.json()

            if 'esearchresult' in search_data and 'idlist' in search_data['esearchresult']:
                id_list = search_data['esearchresult']['idlist']

                # Then get details
                if id_list:
                    ids = ",".join(id_list)
                    summary_url = f"{base_url}/esummary.fcgi?db=pubmed&id={ids}&retmode=json"
                    summary_response = requests.get(summary_url)
                    summary_data = summary_response.json()

                    if 'result' in summary_data:
                        for pmid in id_list:
                            if pmid in summary_data['result']:
                                article = summary_data['result'][pmid]

                                # Extract authors
                                authors = []
                                if 'authors' in article and article['authors']:
                                    authors = [author['name'] for author in article['authors'][:3]]
                                author_text = ", ".join(authors) if authors else "Various Authors"

                                # Create result
                                results.append({
                                    'title': article.get('title', f"Article on {query}"),
                                    'description': article.get('description',
                                                               f"Academic article about {query} in addiction recovery"),
                                    'type': 'article',
                                    'thumbnail_url': 'https://source.unsplash.com/random/300x200/?science',
                                    'author': author_text,
                                    'date': article.get('pubdate', ""),
                                    'url': f"https://pubmed.ncbi.nlm.nih.gov/{pmid}/",
                                    'tags': query.split(),
                                    'source': 'PubMed',
                                    'external_id': pmid
                                })
        except Exception as e:
            print(f"PubMed API error: {e}")

        return results

    def _search_books(self, query, limit=3):
        """Search Google Books API for books on recovery"""
        results = []
        try:
            search_query = f"{query} addiction recovery"
            url = f"https://www.googleapis.com/books/v1/volumes?q={search_query}&maxResults={limit}"

            response = requests.get(url)
            data = response.json()

            if 'items' in data:
                for item in data['items']:
                    volume_info = item.get('volumeInfo', {})

                    # Get thumbnail
                    thumbnail_url = ""
                    if 'imageLinks' in volume_info:
                        thumbnail_url = volume_info['imageLinks'].get('thumbnail', "")

                    # Get authors
                    authors = volume_info.get('authors', ['Unknown Author'])
                    author_text = ", ".join(authors[:3])

                    # Create result
                    results.append({
                        'title': volume_info.get('title', f"Book on {query}"),
                        'description': volume_info.get('description', f"Book about {query} and recovery"),
                        'type': 'book',
                        'thumbnail_url': thumbnail_url or 'https://source.unsplash.com/random/300x200/?book',
                        'author': author_text,
                        'date': volume_info.get('publishedDate', ""),
                        'url': volume_info.get('infoLink', f"https://books.google.com/books?q={query}+recovery"),
                        'tags': query.split(),
                        'source': 'Google Books',
                        'external_id': item.get('id', "")
                    })
        except Exception as e:
            print(f"Google Books API error: {e}")

        return results

    def _search_web(self, query, limit=3):
        """Search for general web articles and resources"""
        # This is a placeholder. In a real application, you might use Google Custom Search API
        # or another search API to find relevant articles

        # For now, return some generic results
        return [
            {
                'title': f"{query.capitalize()} Recovery Resources",
                'description': f"Collection of articles and resources about {query} in recovery",
                'type': 'website',
                'thumbnail_url': 'https://source.unsplash.com/random/300x200/?website',
                'author': 'Various Authors',
                'date': '2024',
                'url': f"https://www.google.com/search?q={query}+addiction+recovery+resources",
                'tags': query.split(),
                'source': 'Web Search',
                'external_id': ""
            }
        ]

    @action(detail=False, methods=['get'])
    def all(self, request):
        """Get all resources"""
        resources = self.get_queryset()
        serializer = self.get_serializer(resources, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def favorite(self, request, pk=None):
        """Toggle favorite status for a resource"""
        resource = self.get_object()
        user = request.user

        # Check if already favorited
        favorite, created = FavoriteResource.objects.get_or_create(
            user=user, resource=resource
        )

        if not created:
            # If it exists, remove it
            favorite.delete()
            is_favorite = False
        else:
            is_favorite = True

        return Response({"isFavorite": is_favorite})

    @action(detail=False, methods=['get'])
    def category(self, request, type=None):
        """Compatibility endpoint for frontend - retrieve resources by category"""
        if not type or type.lower() not in [choice[0] for choice in ResourceType.choices]:
            return Response(
                {"detail": f"Invalid category. Options: {[choice[0] for choice in ResourceType.choices]}"},
                status=status.HTTP_400_BAD_REQUEST
            )

        queryset = self.get_queryset().filter(type=type.lower())
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def related(self, request, pk=None):
        resource = self.get_object()

        # Get all resources except the current one
        all_resources = Resource.objects.exclude(_id=resource._id)

        # Get the current resource's tags
        resource_tags = resource.get_tags()

        # Related resources will be those with matching tags or type
        related_resources = []

        # First, find resources with matching tags
        for res in all_resources:
            res_tags = res.get_tags()
            if any(tag in res_tags for tag in resource_tags):
                related_resources.append(res)

        # If we need more, add resources of the same type
        if len(related_resources) < 3:
            same_type_resources = list(
                all_resources.filter(type=resource.type).exclude(_id__in=[res._id for res in related_resources]))
            related_resources.extend(same_type_resources[:3 - len(related_resources)])

        # Limit to 5 related resources
        related_resources = related_resources[:5]

        serializer = ResourceSerializer(related_resources, many=True, context={'request': request})
        return Response(serializer.data)


class FavoriteResourceViewSet(UserOwnershipMixin, viewsets.ModelViewSet):
    serializer_class = FavoriteResourceSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        """
        Override get_object to handle MongoDB ObjectIds in the URL
        """
        queryset = self.filter_queryset(self.get_queryset())

        # Get the lookup value from the URL
        lookup_url_kwarg = self.lookup_url_kwarg or self.lookup_field
        lookup_value = self.kwargs[lookup_url_kwarg]

        # Try to convert to ObjectId if it's a string
        try:
            if isinstance(lookup_value, str) and len(lookup_value) == 24:
                lookup_value = ObjectId(lookup_value)
        except:
            pass

        # Use _id instead of id for lookup
        filter_kwargs = {'_id': lookup_value}
        obj = get_object_or_404(queryset, **filter_kwargs)

        # Check permissions
        self.check_object_permissions(self.request, obj)

        return obj

    def perform_destroy(self, instance):
        if instance.user != self.request.user:
            raise PermissionDenied("You can only remove your own favorites.")
        instance.delete()