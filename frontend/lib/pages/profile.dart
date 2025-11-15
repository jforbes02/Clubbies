import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  int _selectedIndex = 1; // Start on Profile tab
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

    // Start the wiggle animation and loop it
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
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with username and menu
                      _buildHeader(),
                      const SizedBox(height: 20),

                      // Profile info section
                      _buildProfileInfo(),
                      const SizedBox(height: 20),

                      // Edit Profile button
                      _buildEditProfileButton(),
                      const SizedBox(height: 24),

                      // Story Highlights
                      _buildStoryHighlights(),
                      const SizedBox(height: 24),

                      // Bio section
                      _buildBioSection(),
                      const SizedBox(height: 80), // Add space for navbar
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildWigglyNavBar(),
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
        // TODO: Navigate to different pages
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'username',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Row(
      children: [
        // Profile Picture
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.purple,
            ),
          ),
        ),
        const SizedBox(width: 30),

        // Stats
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('42', 'Posts'),
              _buildStatColumn('1.2K', 'Followers'),
              _buildStatColumn('345', 'Following'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          foregroundColor: Colors.purple.shade600,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildStoryHighlights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Story Highlights',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildHighlightItem(Icons.add, 'New', isNew: true),
              _buildHighlightItem(Icons.favorite, 'Favorites'),
              _buildHighlightItem(Icons.travel_explore, 'Travel'),
              _buildHighlightItem(Icons.food_bank, 'Food'),
              _buildHighlightItem(Icons.sports_soccer, 'Sports'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightItem(IconData icon, String label, {bool isNew = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isNew ? Colors.white.withValues(alpha: 0.5) : Colors.white,
                width: 2.5,
              ),
              color: isNew
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.3),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Full Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '✨ Your bio goes here\n📍 Location\n🔗 yourwebsite.com',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.95),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}