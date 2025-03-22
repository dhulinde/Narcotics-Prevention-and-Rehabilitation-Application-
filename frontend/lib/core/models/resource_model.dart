// core/models/resource_model.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../services/api_data_service.dart';

class Resource {
  final String id;
  final String title;
  final String description;
  final String type; // book, article, video, etc.
  final String thumbnailUrl;
  final String author;
  final String date;
  final String url; // URL to access the resource
  final List<String> tags;
  final bool isFavorite;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.thumbnailUrl,
    required this.author,
    required this.date,
    required this.url,
    this.tags = const [],
    this.isFavorite = false,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    // Extract tags from comma-separated string or list
    List<String> extractTags(dynamic tagsData) {
      if (tagsData == null) return [];

      if (tagsData is String) {
        return tagsData.isEmpty ? [] : tagsData.split(',').map((tag) => tag.trim()).toList();
      } else if (tagsData is List) {
        return tagsData.map((tag) => tag.toString()).toList();
      }
      return [];
    }

    return Resource(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      description: json['description'] ?? '',
      type: json['type'] ?? 'unknown',
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'] ?? '',
      author: json['author'] ?? 'Unknown Author',
      date: json['date'] ?? '',
      url: json['url'] ?? '',
      tags: extractTags(json['tags']),
      isFavorite: json['is_favorite'] ?? json['isFavorite'] ?? false,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'thumbnail_url': thumbnailUrl,
      'author': author,
      'date': date,
      'url': url,
      'tags': tags.join(','),
      'is_favorite': isFavorite,
    };
  }

  Resource copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? thumbnailUrl,
    String? author,
    String? date,
    String? url,
    List<String>? tags,
    bool? isFavorite,
    String? source,
    String? externalId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Resource(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      author: author ?? this.author,
      date: date ?? this.date,
      url: url ?? this.url,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// Resource UI helper for icons and colors
class ResourceUI {
  /// Get icon for resource type
  static IconData getIconForResourceType(String type) {
    switch (type.toLowerCase()) {
      case 'book':
        return Icons.menu_book_rounded;
      case 'article':
        return Icons.article_rounded;
      case 'video':
        return Icons.video_library_rounded;
      case 'podcast':
        return Icons.headset_rounded;
      case 'website':
        return Icons.language_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  /// Get color for resource type
  static Color getColorForResourceType(String type) {
    switch (type.toLowerCase()) {
      case 'book':
        return const Color(0xFF6366F1); // Primary color
      case 'article':
        return const Color(0xFF10B981); // Emerald
      case 'video':
        return const Color(0xFFEF4444); // Red
      case 'podcast':
        return const Color(0xFF8B5CF6); // Purple
      case 'website':
        return const Color(0xFF3B82F6); // Blue
      default:
        return const Color(0xFF9CA3AF); // Gray
    }
  }

  /// Get gradient for resource type
  static List<Color> getGradientForResourceType(String type) {
    switch (type.toLowerCase()) {
      case 'book':
        return [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
      case 'article':
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case 'video':
        return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
      case 'podcast':
        return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
      case 'website':
        return [const Color(0xFF3B82F6), const Color(0xFF2563EB)];
      default:
        return [const Color(0xFF9CA3AF), const Color(0xFF6B7280)];
    }
  }

  /// Get access button text based on resource type
  static String getAccessButtonText(String type) {
    switch (type.toLowerCase()) {
      case 'book':
        return 'READ NOW';
      case 'article':
        return 'READ ARTICLE';
      case 'video':
        return 'WATCH VIDEO';
      case 'podcast':
        return 'LISTEN NOW';
      case 'website':
        return 'VISIT WEBSITE';
      default:
        return 'ACCESS RESOURCE';
    }
  }
}

/// Service for resource management
// Just the ResourceService part of the file
class ResourceService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/resources';

  // Headers with auth token
  static Map<String, String> _getHeaders() {
    final token = AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Fetch all resources
  static Future<List<Resource>> fetchAllResources() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/all/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> resourcesJson = jsonDecode(response.body);
        return resourcesJson.map((json) => Resource.fromJson(json)).toList();
      } else {
        print('Resource API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching resources: $e');
      return [];
    }
  }

  /// Search resources
  static Future<List<Resource>> searchResources(String query) async {
    try {
      if (query.isEmpty) {
        return await fetchAllResources();
      }

      // Get resources from API
      final response = await http.get(
        Uri.parse('$baseUrl/all/search/?q=${Uri.encodeComponent(query)}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> resourcesJson = jsonDecode(response.body);
        return resourcesJson.map((json) => Resource.fromJson(json)).toList();
      } else {
        print('Resource API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error searching resources: $e');
      return [];
    }
  }

  /// Filter resources by type
  static Future<List<Resource>> filterResourcesByType(String type) async {
    try {
      if (type.isEmpty || type.toLowerCase() == 'all') {
        return await fetchAllResources();
      }

      // Get resources by category from API
      final response = await http.get(
        Uri.parse('$baseUrl/all/?type=${Uri.encodeComponent(type)}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> resourcesJson = jsonDecode(response.body);
        return resourcesJson.map((json) => Resource.fromJson(json)).toList();
      } else {
        print('Resource API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error filtering resources: $e');
      return [];
    }
  }

  /// Get resource by ID
  static Future<Resource?> getResourceById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/all/$id/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return Resource.fromJson(jsonDecode(response.body));
      } else {
        print('Resource API Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting resource by ID: $e');
      return null;
    }
  }

  /// Get related resources
  static Future<List<Resource>> getRelatedResources(Resource resource) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/all/${resource.id}/related/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> resourcesJson = jsonDecode(response.body);
        return resourcesJson.map((json) => Resource.fromJson(json)).toList();
      } else {
        print('Resource API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting related resources: $e');
      return [];
    }
  }

  /// Toggle favorite resource
  static Future<bool> toggleFavorite(String resourceId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/all/$resourceId/favorite/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isFavorite'] ?? false;
      } else {
        print('Resource API Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  /// Get favorite resources
  static Future<List<Resource>> getFavoriteResources() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> resourcesJson = jsonDecode(response.body);
        return resourcesJson.map((json) => Resource.fromJson(json)).toList();
      } else {
        print('Resource API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting favorite resources: $e');
      return [];
    }
  }

  /// Get favorite resource IDs
  static Future<List<String>> getFavoriteResourceIds() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites/ids/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map<String>((item) => item['resourceId'].toString()).toList();
      } else {
        print('Resource API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting favorite resource IDs: $e');
      return [];
    }
  }

  /// Open a resource URL in browser
  static Future<bool> openResourceUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      print('Error launching URL: $e');
      return false;
    }
  }
}
