import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import 'feed.dart';
import 'search.dart';
import 'profile.dart';

/// Main container that holds all authenticated pages and manages bottom navigation
/// Uses IndexedStack to preserve state across page switches
class MainContainer extends StatefulWidget {
  final int initialIndex;

  const MainContainer({super.key, this.initialIndex = 0});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> with TickerProviderStateMixin {
  late int _selectedIndex;
  late AnimationController _wiggleController;
  late Animation<double> _wiggleAnimation;

  // Dark theme colors
  static const Color _backgroundDark = Color(0xFF0A0A0A);
  static const Color _cardDark = Color(0xFF1C1C1E);
  static const Color _mintGreen = Color(0xFFA8C5B4);
  static const Color _textSecondary = Color(0xFFAAAAAA);

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.initialIndex;

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
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          FeedPage(),
          SearchPage(),
          ProfilePage(),
        ],
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
            color: _cardDark,
            border: Border(
              top: BorderSide(
                color: _mintGreen.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
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
                  color: _backgroundDark.withValues(alpha: 0.8),
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
                      icon: Icons.map_rounded,
                      label: 'Map',
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
        if (_selectedIndex == index) return; // Already on this page

        // Handle Map tab (not implemented yet)
        if (index == 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: _cardDark,
              content: const Text(
                'Map coming soon!',
                style: TextStyle(color: Colors.white),
              ),
              duration: const Duration(milliseconds: 500),
            ),
          );
          return;
        }

        setState(() {
          _selectedIndex = index;
        });
      },
      child: Transform.translate(
        offset: Offset(0, offsetY),
        child: Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: isSelected
                ? BoxDecoration(
                    color: _mintGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _mintGreen.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  )
                : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? _mintGreen : _textSecondary,
                  size: isSelected ? 28 : 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? _mintGreen : _textSecondary,
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
