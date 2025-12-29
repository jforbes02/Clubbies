import 'package:flutter/material.dart';
import '../models/venue.dart';
import '../models/review.dart';
import '../models/photo.dart';
import '../models/user.dart';
import '../services/venue_service.dart';
import '../services/review_service.dart';
import '../services/photo_service.dart';
import '../services/admin_service.dart';
import '../config/environment.dart';
import 'venue_detail.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final VenueService _venueService = VenueService();
  final PhotoService _photoService = PhotoService();
  final AdminService _adminService = AdminService();

  List<Venue> _venues = [];
  List<Photo> _photos = [];
  List<Review> _reviews = [];
  List<User> _users = [];

  bool _isLoadingVenues = false;
  bool _isLoadingPhotos = false;
  bool _isLoadingReviews = false;
  bool _isLoadingUsers = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadVenues();
    _loadPhotos();
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVenues() async {
    setState(() {
      _isLoadingVenues = true;
      _errorMessage = null;
    });

    try {
      final venues = await _venueService.getAllVenues(limit: 100);
      setState(() {
        _venues = venues;
        _isLoadingVenues = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingVenues = false;
      });
    }
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoadingPhotos = true;
      _errorMessage = null;
    });

    try {
      // Load photos from all venues
      List<Photo> allPhotos = [];
      for (var venue in _venues) {
        final result = await _photoService.getVenuePhotos(venue.venueId, limit: 100);
        allPhotos.addAll(result['photos'] as List<Photo>);
      }

      setState(() {
        _photos = allPhotos;
        _isLoadingPhotos = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingPhotos = false;
      });
    }
  }

  Future<void> _loadReviews(int venueId) async {
    setState(() {
      _isLoadingReviews = true;
      _errorMessage = null;
    });

    try {
      final ReviewService reviewService = ReviewService();
      final reviews = await reviewService.getVenueReviews(venueId, limit: 100);
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
      _errorMessage = null;
    });

    try {
      final users = await _adminService.getAllUsers();
      setState(() {
        _users = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _deleteVenue(int venueId) async {
    final confirmed = await _showConfirmDialog('Delete Venue', 'Are you sure you want to delete this venue? This will also delete all associated reviews and photos.');

    if (confirmed == true) {
      try {
        await _adminService.deleteVenue(venueId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venue deleted successfully')),
        );
        _loadVenues();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteReview(int reviewId) async {
    final confirmed = await _showConfirmDialog('Delete Review', 'Are you sure you want to delete this review?');

    if (confirmed == true) {
      try {
        await _adminService.deleteReview(reviewId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted successfully')),
        );
        // Reload reviews for current venue
        if (_reviews.isNotEmpty) {
          _loadReviews(_reviews.first.venueId);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deletePhoto(int photoId) async {
    final confirmed = await _showConfirmDialog('Delete Photo', 'Are you sure you want to delete this photo?');

    if (confirmed == true) {
      try {
        await _adminService.deletePhoto(photoId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo deleted successfully')),
        );
        _loadPhotos();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteUser(int userId) async {
    final confirmed = await _showConfirmDialog('Delete User', 'Are you sure you want to delete this user account? This action cannot be undone.');

    if (confirmed == true) {
      try {
        await _adminService.deleteUser(userId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
        _loadUsers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _changeUserRole(int userId, String currentRole) async {
    String? selectedRole = currentRole;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change User Role'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('User'),
                value: 'user',
                groupValue: selectedRole,
                onChanged: (value) {
                  setState(() => selectedRole = value);
                },
              ),
              RadioListTile<String>(
                title: const Text('Admin'),
                value: 'admin',
                groupValue: selectedRole,
                onChanged: (value) {
                  setState(() => selectedRole = value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedRole != null && selectedRole != currentRole) {
                try {
                  await _adminService.updateUserRole(userId, selectedRole!);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User role updated successfully')),
                    );
                    _loadUsers();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              } else {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.location_city), text: 'Venues'),
            Tab(icon: Icon(Icons.photo_library), text: 'Photos'),
            Tab(icon: Icon(Icons.rate_review), text: 'Reviews'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVenuesTab(),
          _buildPhotosTab(),
          _buildReviewsTab(),
          _buildUsersTab(),
        ],
      ),
    );
  }

  Widget _buildVenuesTab() {
    if (_isLoadingVenues) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_errorMessage'),
            ElevatedButton(
              onPressed: _loadVenues,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_venues.isEmpty) {
      return const Center(child: Text('No venues found'));
    }

    return RefreshIndicator(
      onRefresh: _loadVenues,
      child: ListView.builder(
        itemCount: _venues.length,
        itemBuilder: (context, index) {
          final venue = _venues[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.shade100,
                child: Icon(Icons.location_city, color: Colors.purple.shade700),
              ),
              title: Text(venue.venueName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(venue.address),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                      const SizedBox(width: 4),
                      Text('${venue.averageRating.toStringAsFixed(1)} (${venue.reviewCount} reviews)'),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VenueDetailPage(venue: venue),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteVenue(venue.venueId),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotosTab() {
    if (_isLoadingPhotos) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No photos found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPhotos,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPhotos,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          final photo = _photos[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  '${Environment.apiBaseUrl}${photo.imgUrl}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image, size: 50),
                    );
                  },
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () => _deletePhoto(photo.photoId),
                    ),
                  ),
                ),
                if (photo.caption != null && photo.caption!.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        photo.caption!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Select Venue',
              border: OutlineInputBorder(),
            ),
            items: _venues.map((venue) {
              return DropdownMenuItem<int>(
                value: venue.venueId,
                child: Text(venue.venueName),
              );
            }).toList(),
            onChanged: (venueId) {
              if (venueId != null) {
                _loadReviews(venueId);
              }
            },
          ),
        ),
        Expanded(
          child: _isLoadingReviews
              ? const Center(child: CircularProgressIndicator())
              : _reviews.isEmpty
                  ? const Center(child: Text('Select a venue to view reviews'))
                  : ListView.builder(
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        final review = _reviews[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                review.username[0].toUpperCase(),
                                style: TextStyle(color: Colors.blue.shade700),
                              ),
                            ),
                            title: Text(review.username),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  review.reviewText,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Posted: ${review.createdAt.toString().split('.')[0]}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteReview(review.reviewId),
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildUsersTab() {
    if (_isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_errorMessage'),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final userRole = user.role ?? 'user';
          final isAdmin = userRole == 'admin';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isAdmin ? Colors.purple.shade100 : Colors.blue.shade100,
                child: Icon(
                  isAdmin ? Icons.admin_panel_settings : Icons.person,
                  color: isAdmin ? Colors.purple.shade700 : Colors.blue.shade700,
                ),
              ),
              title: Row(
                children: [
                  Text(user.username),
                  const SizedBox(width: 8),
                  if (isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ADMIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Email: ${user.email}'),
                  Text('Age: ${user.age}'),
                  Text('User ID: ${user.userId}'),
                  Text('Role: ${userRole.toUpperCase()}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.swap_horiz, color: Colors.orange),
                    onPressed: () => _changeUserRole(user.userId, userRole),
                    tooltip: 'Change Role',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteUser(user.userId),
                    tooltip: 'Delete User',
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
