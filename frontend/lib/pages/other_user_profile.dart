import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/user.dart';
import '../models/review.dart';
import '../services/user_service.dart';
import '../services/review_service.dart';

class OtherUserProfilePage extends StatefulWidget {
  final User searchUser;

  const OtherUserProfilePage({super.key, required this.searchUser});

  @override
  State<OtherUserProfilePage> createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<OtherUserProfilePage> {
  final UserService _userService = UserService();
  final ReviewService _reviewService = ReviewService();

  // Dark theme colors with mint green accents
  static const Color _backgroundDark = Color(0xFF0A0A0A);
  static const Color _surfaceDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1C1C1E);
  static const Color _cardDarkElevated = Color(0xFF2C2C2E);
  static const Color _mintGreen = Color(0xFFA8C5B4);
  static const Color _mintGreenDark = Color(0xFF7A9B87);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFFAAAAAA);

  User? _fullUserProfile;
  List<Review> _reviews = [];

  bool _isLoadingProfile = true;
  bool _isLoadingReviews = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await _loadFullProfile();
    _loadUserReviews();
  }

  Future<void> _loadFullProfile() async {
    try {
      final profile = await _userService.getOtherUserProfile(widget.searchUser.userId);
      setState(() {
        _fullUserProfile = profile;
        _isLoadingProfile = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _loadUserReviews() async {
    try {
      final reviews = await _reviewService.getUserReviews(widget.searchUser.userId);
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingReviews = false;
      });
    }
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
        child: _isLoadingProfile
            ? _buildLoadingState()
            : _errorMessage != null
                ? _buildErrorState()
                : CustomScrollView(
                    slivers: [
                      // App Bar with back button
                      SliverAppBar(
                        expandedHeight: 0,
                        floating: false,
                        pinned: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        leading: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _cardDark.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: _textPrimary),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),

                      // Profile Header
                      SliverToBoxAdapter(
                        child: _buildProfileHeader(),
                      ),

                      // Stats Section
                      SliverToBoxAdapter(
                        child: _buildStatsSection(),
                      ),

                      // Reviews Section Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 32.0, 20.0, 16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _mintGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.rate_review, color: _mintGreen, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Reviews',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _textPrimary,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _cardDarkElevated,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _reviews.length.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _mintGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Reviews List
                      if (_isLoadingReviews)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(_mintGreen),
                              ),
                            ),
                          ),
                        )
                      else if (_reviews.isEmpty)
                        SliverToBoxAdapter(
                          child: _buildEmptyReviewsState(),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: _buildReviewCard(_reviews[index]),
                                );
                              },
                              childCount: _reviews.length,
                            ),
                          ),
                        ),

                      // Bottom padding
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Profile Picture with glow effect
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _mintGreen.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _mintGreen,
                    _mintGreenDark,
                  ],
                ),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: _cardDark,
                child: Icon(
                  Icons.person,
                  size: 70,
                  color: _mintGreen.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Username
          Text(
            _fullUserProfile?.username ?? widget.searchUser.username,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
              letterSpacing: 0.5,
            ),
          ),

          // Age badge (if available)
          if (_fullUserProfile?.age != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _mintGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _mintGreen.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cake, color: _mintGreen, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${_fullUserProfile!.age} years old',
                    style: TextStyle(
                      fontSize: 14,
                      color: _mintGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardDark.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _mintGreen.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  icon: Icons.rate_review,
                  value: _reviews.length.toString(),
                  label: 'Reviews',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _mintGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _mintGreen, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyReviewsState() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _mintGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rate_review_outlined,
                size: 50,
                color: _mintGreen.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This user hasn\'t written any reviews',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_mintGreen),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
              'Error Loading Profile',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: TextStyle(color: _textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isLoadingProfile = true;
                });
                _loadUserData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _mintGreen,
                foregroundColor: _backgroundDark,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      decoration: BoxDecoration(
        color: _cardDark.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _mintGreen.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Venue name header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _mintGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.place, color: _mintGreen, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        review.venueName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Review text
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _cardDarkElevated.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    review.reviewText,
                    style: TextStyle(
                      color: _textPrimary.withValues(alpha: 0.9),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Date
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: _textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(review.createdAt),
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                      ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
