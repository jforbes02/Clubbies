import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import 'main_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final Map<String, AnimationController> _bubbleControllers = {};
  final Map<String, Animation<double>> _bubbleAnimations = {};
  final Map<String, AnimationController> _wiggleControllers = {};
  final Map<String, Animation<double>> _wiggleAnimations = {};

  @override
  void initState() {
    super.initState();

    // Fade in animation for the whole page
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();

    // Create animation controllers for each bubble
    final bubbles = ['home', 'search', 'profile', 'reviews'];
    for (var i = 0; i < bubbles.length; i++) {
      var bubble = bubbles[i];

      // Tap animation
      _bubbleControllers[bubble] = AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      );
      _bubbleAnimations[bubble] = Tween<double>(begin: 1.0, end: 0.85).animate(
        CurvedAnimation(
          parent: _bubbleControllers[bubble]!,
          curve: Curves.easeInOut,
        ),
      );

      // Wiggle animation (continuous)
      _wiggleControllers[bubble] = AnimationController(
        duration: Duration(milliseconds: 2000 + (i * 500)), // Different speeds for each
        vsync: this,
      );
      _wiggleAnimations[bubble] = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _wiggleControllers[bubble]!,
          curve: Curves.easeInOut,
        ),
      );

      // Start wiggle animation and repeat
      _wiggleControllers[bubble]!.repeat();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    for (var controller in _bubbleControllers.values) {
      controller.dispose();
    }
    for (var controller in _wiggleControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onBubbleTap(String bubbleName) {
    // Show a snackbar for now (placeholder for future navigation)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${bubbleName.toUpperCase()} pressed!'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.purple.shade400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade200,
              Colors.lightBlue.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clubbies',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.nightlife,
                        size: 40,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),

                // Navigation Bubbles
                Expanded(
                  child: Center(
                    child: Wrap(
                      spacing: 30,
                      runSpacing: 30,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildAnimatedBubble(
                          name: 'home',
                          icon: Icons.home_rounded,
                          label: 'Home',
                          color: Colors.blue.shade300,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MainContainer(initialIndex: 0)),
                            );
                          },
                        ),
                        _buildAnimatedBubble(
                          name: 'search',
                          icon: Icons.search_rounded,
                          label: 'Search',
                          color: Colors.purple.shade300,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MainContainer(initialIndex: 1)),
                            );
                          }
                        ),
                        _buildAnimatedBubble(
                          name: 'profile',
                          icon: Icons.person_rounded,
                          label: 'Profile',
                          color: Colors.pink.shade300,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MainContainer(initialIndex: 2)),
                            );
                          },
                        ),
                        _buildAnimatedBubble(
                          name: 'reviews',
                          icon: Icons.star_rounded,
                          label: 'Reviews',
                          color: Colors.amber.shade300,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBubble({
    required String name,
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return ScaleTransition(
      scale: _bubbleAnimations[name]!,
      child: AnimatedBuilder(
        animation: _wiggleAnimations[name]!,
        builder: (context, child) {
          // Create a morphing effect using sin waves
          final wiggle = _wiggleAnimations[name]!.value;
          final morphX = 35 + (5 * sin(wiggle * 2 * pi));
          final morphY = 35 + (5 * cos(wiggle * 2 * pi + 1));

          return GestureDetector(
            onTap: () {
              final controller = _bubbleControllers[name]!;
              controller.forward().then((_) => controller.reverse());

              if (onPressed != null) {
                onPressed();
              } else {
                _onBubbleTap(name);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(morphX),
                    topRight: Radius.circular(morphY),
                    bottomLeft: Radius.circular(morphY),
                    bottomRight: Radius.circular(morphX),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(morphX),
                          topRight: Radius.circular(morphY),
                          bottomLeft: Radius.circular(morphY),
                          bottomRight: Radius.circular(morphX),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Inner glow effect
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(morphX),
                                  topRight: Radius.circular(morphY),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withOpacity(0.3),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Icon in center
                          Center(
                            child: Icon(
                              icon,
                              size: 60,
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}