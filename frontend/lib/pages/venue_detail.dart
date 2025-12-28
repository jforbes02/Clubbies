import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/venue.dart';
import '../models/photo.dart';
import '../models/review.dart';
import '../services/photo_service.dart';
import '../services/review_service.dart';
import '../services/rating_service.dart';
import '../config/environment.dart';

class VenueDetailPage extends StatefulWidget {
  final Venue venue;

  const VenueDetailPage({super.key, required this.venue});

  @override
  State<VenueDetailPage> createState() => _VenueDetailPageState();
}

class _VenueDetailPageState extends State<VenueDetailPage> {
  final PhotoService _photoService = PhotoService();
  final ReviewService _reviewService = ReviewService();
  final RatingService _ratingService = RatingService();

  List<Photo> _photos = [];
  List<Review> _reviews = [];
  bool _isLoadingPhotos = true;
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadVenueData();
  }

  Future<void> _loadVenueData() async {
    _loadPhotos();
    _loadReviews();
  }

  Future<void> _loadPhotos() async {
    try {
      final result = await _photoService.getVenuePhotos(widget.venue.venueId);
      setState(() {
        _photos = result['photos'] as List<Photo>;
        _isLoadingPhotos = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPhotos = false;
      });
    }
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await _reviewService.getVenueReviews(widget.venue.venueId);
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

  Future<void> _showRatingDialog() async {
    // Check if user has already rated this venue
    Map<String, dynamic>? existingRatingData;
    try {
      existingRatingData = await _ratingService.getUserRating(widget.venue.venueId);
    } catch (e) {
      // User hasn't rated yet
    }

    final double? existingRating = existingRatingData?['rating'];
    double selectedRating = existingRating ?? 5.0;
    final hasExistingRating = existingRating != null;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.purple.shade700,
          title: Text(
            hasExistingRating ? 'Update Rating' : 'Rate ${widget.venue.venueName}',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasExistingRating
                    ? 'Your current rating: ${existingRating.toStringAsFixed(1)} ⭐'
                    : 'Tap a star to rate:',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final rating = (index + 1).toDouble();
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        selectedRating = rating;
                      });
                    },
                    child: Icon(
                      Icons.star,
                      color: rating <= selectedRating
                          ? Colors.amber
                          : Colors.white.withValues(alpha: 0.3),
                      size: 48,
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _ratingService.submitRating(
                    venueId: widget.venue.venueId,
                    rating: selectedRating,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        hasExistingRating ? 'Rating updated!' : 'Rating submitted!',
                      ),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.purple.shade900,
              ),
              child: Text(hasExistingRating ? 'Update' : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade200,
              Colors.purple.shade400,
              Colors.purple.shade600,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // App Bar with back button
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.purple.shade600,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeaderImage(),
              ),
            ),

            // Venue Details
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Venue Name and Type
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.venue.venueName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (widget.venue.venueType.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.venue.venueType.first,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          widget.venue.averageRating > 0
                              ? widget.venue.averageRating.toStringAsFixed(1)
                              : 'No ratings yet',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${widget.venue.reviewCount} reviews)',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _showRatingDialog,
                          icon: const Icon(Icons.star_border, size: 20),
                          label: const Text('Rate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.purple.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Venue Info Cards
                    _buildInfoCard(
                      Icons.location_on,
                      'Address',
                      widget.venue.address,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      Icons.access_time,
                      'Hours',
                      widget.venue.hours,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      Icons.people,
                      'Capacity',
                      widget.venue.capacity,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      Icons.attach_money,
                      'Price',
                      '\$${widget.venue.price}',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      Icons.cake,
                      'Age Requirement',
                      '${widget.venue.ageReq}+',
                    ),

                    // Description
                    if (widget.venue.description != null && widget.venue.description!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.venue.description!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Reviews Section
                    const SizedBox(height: 24),
                    const Text(
                      'Reviews',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _isLoadingReviews
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : _reviews.isEmpty
                            ? Text(
                                'No reviews yet. Be the first to review!',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 16,
                                ),
                              )
                            : Column(
                                children: _reviews.map((review) => _buildReviewCard(review)).toList(),
                              ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    if (_isLoadingPhotos) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade300,
              Colors.blue.shade400,
              Colors.pink.shade300,
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    if (_photos.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade300,
              Colors.blue.shade400,
              Colors.pink.shade300,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.nightlife_outlined,
                size: 80,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                widget.venue.venueName,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          '${Environment.apiBaseUrl}${_photos[0].imgUrl}',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.shade300,
                    Colors.blue.shade400,
                    Colors.pink.shade300,
                  ],
                ),
              ),
            );
          },
        ),
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${review.username}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatDateTime(review.createdAt),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.reviewText,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
