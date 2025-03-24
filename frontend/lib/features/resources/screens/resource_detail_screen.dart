// features/resources/screens/resource_detail_screen.dart
import 'package:flutter/material.dart';
import '../../../core/models/resource_model.dart';
import '../../../core/services/api_data_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../config/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceDetailScreen extends StatefulWidget {
  final Resource resource;

  const ResourceDetailScreen({
    Key? key,
    required this.resource,
  }) : super(key: key);

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  late Resource _resource;
  List<Resource> _relatedResources = [];
  bool _isLoading = false;
  final ApiDataService _apiService = ApiDataService();

  @override
  void initState() {
    super.initState();
    _resource = widget.resource;
    _loadRelatedResources();
  }

  Future<void> _loadRelatedResources() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use our ResourceService for consistent implementation
      final relatedResources = await ResourceService.getRelatedResources(_resource);
      setState(() {
        _relatedResources = relatedResources;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading related resources: $e');

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load related resources.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      // Toggle favorite status via API service
      final isFavorite = await _apiService.toggleResourceFavorite(_resource.id);

      setState(() {
        _resource = _resource.copyWith(isFavorite: isFavorite);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? 'Added to favorites'
                : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error toggling favorite: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating favorites: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _accessResource() async {
    try {
      // Launch the resource URL
      final Uri uri = Uri.parse(_resource.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Show error if URL can't be launched
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open resource. Please try again later.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error opening resource. Please check your internet connection.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _resource.type.toUpperFirst(),
          style: const TextStyle(
            color: AppColors.resourcesAccent,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.resourcesAccent,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share,
              color: AppColors.resourcesAccent,
            ),
            onPressed: () {
              // Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sharing resource...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resource image/thumbnail
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[200],
              child: _resource.thumbnailUrl.startsWith('assets/')
                  ? Image.asset(
                'placeholder.jpg', // Use placeholder for now
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      ResourceUI.getIconForResourceType(_resource.type),
                      size: 80,
                      color: ResourceUI.getColorForResourceType(_resource.type),
                    ),
                  );
                },
              )
                  : Image.network(
                _resource.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      ResourceUI.getIconForResourceType(_resource.type),
                      size: 80,
                      color: ResourceUI.getColorForResourceType(_resource.type),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resource Type Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ResourceUI.getColorForResourceType(_resource.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _resource.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ResourceUI.getColorForResourceType(_resource.type),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    _resource.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Author and Date
                  Text(
                    '${_resource.author} • ${_resource.date}',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    _resource.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Tags
                  if (_resource.tags.isNotEmpty) ...[
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _resource.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: ResourceUI.getAccessButtonText(_resource.type),
                          onPressed: _accessResource,
                          variant: ButtonVariant.gradient,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _toggleFavorite,
                        icon: Icon(
                          _resource.isFavorite
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: _resource.isFavorite
                              ? AppColors.resourcesAccent
                              : AppColors.textSecondary,
                          size: 30,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Related resources
                  const Text(
                    'Related Resources',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Related resources list
                  _isLoading
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        color: AppColors.resourcesAccent,
                      ),
                    ),
                  )
                      : _relatedResources.isEmpty
                      ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'No related resources found',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                      : Column(
                    children: _relatedResources
                        .take(3)
                        .map((resource) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildRelatedResourceItem(resource),
                    ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedResourceItem(Resource resource) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResourceDetailScreen(
              resource: resource,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: ResourceUI.getColorForResourceType(resource.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  ResourceUI.getIconForResourceType(resource.type),
                  color: ResourceUI.getColorForResourceType(resource.type),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resource.author,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// Helper extension for string manipulation
extension StringExtension on String {
  String toUpperFirst() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}