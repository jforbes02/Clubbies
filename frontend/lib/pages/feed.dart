import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with TickerProviderStateMixin {
  int _selectedIndex = 0; // Home/Feed tab selected
  late AnimationController _wiggleController;
  late Animation<double> _wiggleAnimation;

  @override
  void initState() {
    super.initState();

    // Wiggle animation for navbar
    _wiggleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _wiggleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _wiggleController,
        curve: Curves.easeInOut,
      ),
    );

    _wiggleController.repeat();
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    super.dispose();
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
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Feed
              Expanded(
                child: _buildFeed(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildWigglyNavBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Clubbies',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 28),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeed() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: 5, // Placeholder
      itemBuilder: (context, index) {
        return _buildVenuePost(index);
      },
    );
  }

  Widget _buildVenuePost(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Venue Image Placeholder
              _buildVenueImage(index),

              // Venue Info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Venue name and type
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'The Purple Lounge ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.white70, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Downtown District',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Nightclub',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Venue details
                    Row(
                      children: [
                        _buildInfoChip(Icons.access_time, '10 PM - 3 AM'),
                        const SizedBox(width: 12),
                        _buildInfoChip(Icons.people, 'Large'),
                        const SizedBox(width: 12),
                        _buildInfoChip(Icons.attach_money, '\$25'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        _buildActionButton(Icons.favorite_border, '124', () {}),
                        const SizedBox(width: 16),
                        _buildActionButton(Icons.comment_outlined, '18', () {}),
                        const SizedBox(width: 16),
                        _buildActionButton(Icons.share_outlined, 'Share', () {}),
                        const Spacer(),
                        _buildSaveButton(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Reviews section
                    _buildReviewsSection(index),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVenueImage(int index) {
    return Container(
      height: 250,
      width: double.infinity,
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
      child: Stack(
        children: [
          // Placeholder for actual image
          Center(
            child: Icon(
              Icons.image_outlined,
              size: 80,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          // Rating badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${4.0 + (index * 0.2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.bookmark_border, color: Colors.white, size: 20),
    );
  }

  Widget _buildReviewsSection(int venueIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Reviews',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),

        // Review 1
        _buildReviewCard(
          username: 'user${venueIndex + 1}',
          rating: 5,
          comment: 'Amazing atmosphere! The music was incredible and the staff was super friendly. Would definitely come back!',
          likes: 12,
          timeAgo: '2h ago',
        ),
        const SizedBox(height: 12),

        // Review 2
        _buildReviewCard(
          username: 'partygoer${venueIndex + 2}',
          rating: 4,
          comment: 'Great place to hang out with friends. A bit crowded on weekends but totally worth it.',
          likes: 8,
          timeAgo: '5h ago',
        ),
        const SizedBox(height: 12),

        // Show more reviews button
        Center(
          child: TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Loading more reviews...'),
                  duration: Duration(milliseconds: 500),
                ),
              );
            },
            child: const Text(
              'View all 18 reviews',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required String username,
    required int rating,
    required String comment,
    required int likes,
    required String timeAgo,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and rating
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                child: const Icon(Icons.person, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@$username',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Star rating
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Comment
          Text(
            comment,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),

          // Actions
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    const Icon(Icons.thumb_up_outlined, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$likes',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  _showCommentBottomSheet(username);
                },
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Reply',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCommentBottomSheet(String replyTo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.purple.shade400,
                Colors.purple.shade600,
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reply to @$replyTo',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  autofocus: true,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Write your reply...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reply posted!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Post Reply',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWigglyNavBar() {
    return AnimatedBuilder(
      animation: _wiggleAnimation,
      builder: (context, child) {
        final wiggle = _wiggleAnimation.value;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.purple.shade400,
                Colors.purple.shade600,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Icons.home_rounded,
                      label: 'Home',
                      wiggleOffset: 0,
                      wiggle: wiggle,
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.search_rounded,
                      label: 'Search',
                      wiggleOffset: 0.33,
                      wiggle: wiggle,
                    ),
                    _buildNavItem(
                      index: 2,
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      wiggleOffset: 0.66,
                      wiggle: wiggle,
                    ),
                    _buildNavItem(
                      index: 3,
                      icon: Icons.star_rounded,
                      label: 'Reviews',
                      wiggleOffset: 1.0,
                      wiggle: wiggle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required double wiggleOffset,
    required double wiggle,
  }) {
    final isSelected = _selectedIndex == index;

    // Create wiggle effect using sin/cos
    final wiggleAmount = 3.0;
    final offsetY = sin((wiggle + wiggleOffset) * 2 * pi) * wiggleAmount;
    final scale = 1.0 + (cos((wiggle + wiggleOffset) * 2 * pi) * 0.05);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label tapped!'),
            duration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Transform.translate(
        offset: Offset(0, offsetY),
        child: Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: isSelected
                ? BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  )
                : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
                  size: isSelected ? 28 : 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
                    fontSize: isSelected ? 12 : 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}