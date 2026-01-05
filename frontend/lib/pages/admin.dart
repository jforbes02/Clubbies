import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/venue.dart';
import '../models/review.dart';
import '../models/photo.dart';
import '../models/user.dart';
import '../services/venue_service.dart';
import '../services/review_service.dart';
import '../services/photo_service.dart';
import '../services/admin_service.dart';
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

  // Dark theme colors with mint green accents
  static const Color _backgroundDark = Color(0xFF0A0A0A);
  static const Color _surfaceDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1C1C1E);
  static const Color _cardDarkElevated = Color(0xFF2C2C2E);
  static const Color _mintGreen = Color(0xFFA8C5B4);
  static const Color _mintGreenDark = Color(0xFF7A9B87);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFFAAAAAA);

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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _mintGreenDark,
            content: const Text('Venue deleted successfully', style: TextStyle(color: _textPrimary)),
          ),
        );
        _loadVenues();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade400,
            content: Text('Error: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _deleteReview(int reviewId) async {
    final confirmed = await _showConfirmDialog('Delete Review', 'Are you sure you want to delete this review?');

    if (confirmed == true) {
      try {
        await _adminService.deleteReview(reviewId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _mintGreenDark,
            content: const Text('Review deleted successfully', style: TextStyle(color: _textPrimary)),
          ),
        );
        // Reload reviews for current venue
        if (_reviews.isNotEmpty) {
          _loadReviews(_reviews.first.venueId);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade400,
            content: Text('Error: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _deletePhoto(int photoId) async {
    final confirmed = await _showConfirmDialog('Delete Photo', 'Are you sure you want to delete this photo?');

    if (confirmed == true) {
      try {
        await _adminService.deletePhoto(photoId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _mintGreenDark,
            content: const Text('Photo deleted successfully', style: TextStyle(color: _textPrimary)),
          ),
        );
        _loadPhotos();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade400,
            content: Text('Error: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(int userId) async {
    final confirmed = await _showConfirmDialog('Delete User', 'Are you sure you want to delete this user account? This action cannot be undone.');

    if (confirmed == true) {
      try {
        await _adminService.deleteUser(userId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _mintGreenDark,
            content: const Text('User deleted successfully', style: TextStyle(color: _textPrimary)),
          ),
        );
        _loadUsers();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade400,
            content: Text('Error: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _changeUserRole(int userId, String currentRole) async {
    String? selectedRole = currentRole;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _mintGreen.withValues(alpha: 0.2)),
        ),
        title: const Text('Change User Role', style: TextStyle(color: _textPrimary)),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRoleOption('User', 'user', selectedRole, (value) {
                setState(() => selectedRole = value);
              }),
              const SizedBox(height: 8),
              _buildRoleOption('Admin', 'admin', selectedRole, (value) {
                setState(() => selectedRole = value);
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: _textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedRole != null && selectedRole != currentRole) {
                try {
                  await _adminService.updateUserRole(userId, selectedRole!);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: _mintGreenDark,
                        content: const Text('User role updated successfully', style: TextStyle(color: _textPrimary)),
                      ),
                    );
                    _loadUsers();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red.shade400,
                        content: Text('Error: ${e.toString()}'),
                      ),
                    );
                  }
                }
              } else {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _mintGreen,
              foregroundColor: _backgroundDark,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(String label, String value, String? groupValue, Function(String?) onChanged) {
    final isSelected = groupValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _mintGreen.withValues(alpha: 0.15) : _cardDarkElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _mintGreen : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(
              value == 'admin' ? Icons.admin_panel_settings : Icons.person,
              color: isSelected ? _mintGreen : _textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? _mintGreen : _textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: _mintGreen, size: 20),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
        ),
        title: Text(title, style: const TextStyle(color: _textPrimary)),
        content: Text(message, style: TextStyle(color: _textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: _textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _backgroundDark,
              _surfaceDark,
              _backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVenuesTab(),
                    _buildPhotosTab(),
                    _buildReviewsTab(),
                    _buildUsersTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _cardDarkElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: const Icon(Icons.arrow_back, color: _textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _mintGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.admin_panel_settings, color: _mintGreen, size: 22),
          ),
          const SizedBox(width: 12),
          const Text(
            'Admin Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _mintGreen.withValues(alpha: 0.1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: _mintGreen.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: _mintGreen,
        unselectedLabelColor: _textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(icon: Icon(Icons.location_city, size: 20), text: 'Venues'),
          Tab(icon: Icon(Icons.photo_library, size: 20), text: 'Photos'),
          Tab(icon: Icon(Icons.rate_review, size: 20), text: 'Reviews'),
          Tab(icon: Icon(Icons.people, size: 20), text: 'Users'),
        ],
      ),
    );
  }

  Widget _buildVenuesTab() {
    if (_isLoadingVenues) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_mintGreen),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState(_loadVenues);
    }

    if (_venues.isEmpty) {
      return _buildEmptyState(Icons.location_city_outlined, 'No venues found');
    }

    return RefreshIndicator(
      onRefresh: _loadVenues,
      color: _mintGreen,
      backgroundColor: _cardDark,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _venues.length,
        itemBuilder: (context, index) {
          final venue = _venues[index];
          return _buildVenueCard(venue);
        },
      ),
    );
  }

  Widget _buildVenueCard(Venue venue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _mintGreen.withValues(alpha: 0.1),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _mintGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_city, color: _mintGreen, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue.venueName,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        venue.address,
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: _mintGreen),
                          const SizedBox(width: 4),
                          Text(
                            '${venue.averageRating.toStringAsFixed(1)} (${venue.reviewCount})',
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionIconButton(
                      Icons.visibility,
                      _mintGreen,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VenueDetailPage(venue: venue),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildActionIconButton(
                      Icons.delete,
                      Colors.red.shade400,
                      () => _deleteVenue(venue.venueId),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosTab() {
    if (_isLoadingPhotos) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_mintGreen),
        ),
      );
    }

    if (_photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEmptyState(Icons.photo_library_outlined, 'No photos found'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPhotos,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _mintGreen,
                foregroundColor: _backgroundDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPhotos,
      color: _mintGreen,
      backgroundColor: _cardDark,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          final photo = _photos[index];
          return _buildPhotoCard(photo);
        },
      ),
    );
  }

  Widget _buildPhotoCard(Photo photo) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _mintGreen.withValues(alpha: 0.1),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              photo.imgUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: _cardDarkElevated,
                  child: Icon(Icons.broken_image, size: 50, color: _textSecondary),
                );
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _deletePhoto(photo.photoId),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.delete, color: Colors.red.shade400, size: 18),
                ),
              ),
            ),
            if (photo.caption != null && photo.caption!.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    photo.caption!,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _mintGreen.withValues(alpha: 0.1),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              hint: Row(
                children: [
                  Icon(Icons.location_city, color: _mintGreen, size: 18),
                  const SizedBox(width: 10),
                  Text('Select Venue', style: TextStyle(color: _textSecondary)),
                ],
              ),
              dropdownColor: _cardDark,
              style: const TextStyle(color: _textPrimary),
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
        ),
        Expanded(
          child: _isLoadingReviews
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_mintGreen),
                  ),
                )
              : _reviews.isEmpty
                  ? _buildEmptyState(Icons.rate_review_outlined, 'Select a venue to view reviews')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        final review = _reviews[index];
                        return _buildReviewCard(review);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _mintGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                review.username[0].toUpperCase(),
                style: const TextStyle(
                  color: _mintGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@${review.username}',
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  review.reviewText,
                  style: TextStyle(
                    color: _textPrimary.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  review.createdAt.toString().split('.')[0],
                  style: TextStyle(
                    fontSize: 11,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildActionIconButton(
            Icons.delete,
            Colors.red.shade400,
            () => _deleteReview(review.reviewId),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_isLoadingUsers) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_mintGreen),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState(_loadUsers);
    }

    if (_users.isEmpty) {
      return _buildEmptyState(Icons.people_outline, 'No users found');
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      color: _mintGreen,
      backgroundColor: _cardDark,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(User user) {
    final userRole = user.role ?? 'user';
    final isAdmin = userRole == 'admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAdmin ? _mintGreen.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isAdmin ? _mintGreen.withValues(alpha: 0.15) : _cardDarkElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isAdmin ? Icons.admin_panel_settings : Icons.person,
                color: isAdmin ? _mintGreen : _textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _mintGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _mintGreen.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              color: _mintGreen,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? 'No email',
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Age: ${user.age}',
                        style: TextStyle(color: _textSecondary, fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'ID: ${user.userId}',
                        style: TextStyle(color: _textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionIconButton(
                  Icons.swap_horiz,
                  Colors.orange.shade400,
                  () => _changeUserRole(user.userId, userRole),
                ),
                const SizedBox(width: 8),
                _buildActionIconButton(
                  Icons.delete,
                  Colors.red.shade400,
                  () => _deleteUser(user.userId),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _mintGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _mintGreen.withValues(alpha: 0.6), size: 50),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: _textSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Data',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error',
            style: TextStyle(color: _textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: _mintGreen,
              foregroundColor: _backgroundDark,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
