// features/resources/screens/resources_screen.dart
import 'package:flutter/material.dart';
import '../../../core/models/resource_model.dart';
import '../../../config/constants.dart';
import '../../../core/services/api_data_service.dart';
import '../widgets/category_chip.dart';
import '../widgets/resource_card.dart';
import 'resource_detail_screen.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({Key? key}) : super(key: key);

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  List<Resource> _resources = [];
  String _selectedCategory = 'All';
  bool _showFavoritesOnly = false;
  final ApiDataService _apiService = ApiDataService();

  final List<String> _categories = [
    'All',
    'Books',
    'Articles',
    'Videos',
    'Podcasts',
    'Websites',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialResources();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load initial resources
  Future<void> _loadInitialResources() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get resources from API service
      final resources = await _apiService.loadAllResources();

      setState(() {
        _resources = resources;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _resources = [];
      });
      print('Error loading resources: $e');

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load resources. Please check your connection.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Search for resources
  Future<void> _searchResources(String query) async {
    setState(() {
      _searchQuery = query;
      _isLoading = true;
    });

    try {
      List<Resource> results;

      if (_showFavoritesOnly) {
        // Get favorites
        results = await _apiService.loadFavoriteResources();

        // Filter by search query if provided
        if (query.isNotEmpty) {
          results = results.where((resource) =>
          resource.title.toLowerCase().contains(query.toLowerCase()) ||
              resource.description.toLowerCase().contains(query.toLowerCase()) ||
              resource.author.toLowerCase().contains(query.toLowerCase()) ||
              resource.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
          ).toList();
        }
      } else {
        // Search external resources via API service
        results = await _apiService.searchResources(query);
      }

      // Apply category filter if not "All"
      if (_selectedCategory != 'All') {
        final categoryType = _selectedCategory.substring(0, _selectedCategory.length - 1).toLowerCase();
        results = results.where((resource) => resource.type.toLowerCase() == categoryType).toList();
      }

      setState(() {
        _resources = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error searching resources: $e');

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Search failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Filter resources by category
  Future<void> _filterByCategory(String category) async {
    if (category == _selectedCategory) return;

    setState(() {
      _selectedCategory = category;
      _isLoading = true;
    });

    try {
      List<Resource> filteredResources;

      if (_showFavoritesOnly) {
        filteredResources = await _apiService.loadFavoriteResources();
      } else if (category == 'All') {
        filteredResources = await _apiService.loadAllResources();
      } else {
        final categoryType = category.substring(0, category.length - 1).toLowerCase();
        filteredResources = await _apiService.filterResourcesByType(categoryType);
      }

      // If there's also a search query, filter further
      if (_searchQuery.isNotEmpty) {
        filteredResources = filteredResources
            .where((resource) =>
        resource.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            resource.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            resource.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            resource.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase())))
            .toList();
      }

      setState(() {
        _resources = filteredResources;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error filtering resources: $e');

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to filter resources. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Toggle favorites filter
  Future<void> _toggleFavoritesFilter() async {
    setState(() {
      _isLoading = true;
      _showFavoritesOnly = !_showFavoritesOnly;
    });

    try {
      List<Resource> filteredResources;

      if (_showFavoritesOnly) {
        filteredResources = await _apiService.loadFavoriteResources();
      } else {
        filteredResources = await _apiService.loadAllResources();
      }

      // Apply category filter if necessary
      if (_selectedCategory != 'All') {
        final categoryType = _selectedCategory.substring(0, _selectedCategory.length - 1).toLowerCase();
        filteredResources = filteredResources
            .where((resource) => resource.type.toLowerCase() == categoryType)
            .toList();
      }

      // Apply search filter if necessary
      if (_searchQuery.isNotEmpty) {
        filteredResources = filteredResources
            .where((resource) =>
        resource.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            resource.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            resource.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            resource.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase())))
            .toList();
      }

      setState(() {
        _resources = filteredResources;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error toggling favorites filter: $e');

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load favorites. Please try again.'),
          backgroundColor: Colors.red,
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
        title: const Text(
          AppStrings.resourcesTitle,
          style: TextStyle(
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
          // Favorites toggle
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.bookmark : Icons.bookmark_border,
              color: _showFavoritesOnly ? AppColors.resourcesAccent : AppColors.textSecondary,
            ),
            onPressed: _toggleFavoritesFilter,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for resources...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _searchResources('');
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                  onChanged: (value) => _searchResources(value),
                ),
              ),

              const SizedBox(height: 20),

              // Resource Categories
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryChip(
                        label: category,
                        isSelected: _selectedCategory == category,
                        onSelected: (selected) {
                          if (selected) {
                            _filterByCategory(category);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Results heading
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _showFavoritesOnly
                        ? 'Favorites'
                        : (_searchQuery.isEmpty ? 'Recommended Resources' : 'Search Results'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (_resources.isNotEmpty)
                    Text(
                      '${_resources.length} ${_resources.length == 1 ? 'resource' : 'resources'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Results list
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.resourcesAccent,
                  ),
                )
                    : _resources.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showFavoritesOnly ? Icons.bookmark_border : Icons.search_off,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _showFavoritesOnly
                            ? 'No favorites yet'
                            : (_searchQuery.isEmpty
                            ? 'No resources available'
                            : 'No matching resources found'),
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (_showFavoritesOnly) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Bookmark resources to add them to your favorites',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: _resources.length,
                  itemBuilder: (context, index) {
                    final resource = _resources[index];
                    return ResourceCard(
                      resource: resource,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResourceDetailScreen(resource: resource),
                          ),
                        ).then((_) {
                          // Refresh resources when returning from detail screen
                          if (_showFavoritesOnly) {
                            _toggleFavoritesFilter();
                          } else if (_selectedCategory != 'All') {
                            _filterByCategory(_selectedCategory);
                          } else if (_searchQuery.isNotEmpty) {
                            _searchResources(_searchQuery);
                          } else {
                            _loadInitialResources();
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}