import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:share_plus/share_plus.dart';
import '../services/venue_service.dart';
import '../services/review_service.dart';
import '../services/rating_service.dart';
import '../services/photo_service.dart';
import '../services/user_service.dart';
import '../services/admin_service.dart';
import '../models/venue.dart';
import '../models/review.dart';
import '../models/photo.dart';
import '../models/user.dart';
import 'photo_upload.dart';
import 'admin.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final VenueService _venueService = VenueService();
  final PhotoService _photoService = PhotoService();
  final RatingService _ratingService = RatingService();
  final UserService _userService = UserService();
  final AdminService _adminService = AdminService();

  List<Venue> _venues = [];
  bool _isLoading = true;
  String? _errorMessage;
  User? _currentUser;

  // Map to store photos for each venue
  final Map<int, List<Photo>> _venuePhotos = {};

  // Map to store user's ratings for each venue (venueId -> ratingId)
  //Map<int, int?> _userRatings = {};

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    try {
      final venues = await _venueService.getAllVenues();
      final user = await _userService.getCurrentUserProfile();

      setState(() {
        _venues = venues;
        _currentUser = user;
        _isLoading = false;
      });

      // Load photos for each venue
      _loadVenuePhotos();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadVenuePhotos() async {
    for (var venue in _venues) {
      try {
        final result = await _photoService.getVenuePhotos(venue.venueId, limit: 1);
        final photos = result['photos'] as List<Photo>;
        setState(() {
          _venuePhotos[venue.venueId] = photos;
        });
      } catch (e) {
        // Silently fail for photos - not critical
        setState(() {
          _venuePhotos[venue.venueId] = [];
        });
      }
    }
  }

  Future<void> _showRatingDialog(Venue venue) async {
    // Check if user has already rated this venue
    Map<String, dynamic>? existingRatingData;
    try {
      existingRatingData = await _ratingService.getUserRating(venue.venueId);
    } catch (e) {
      // User hasn't rated yet
    }

    final double? existingRating = existingRatingData?['rating'];
    final int? ratingId = existingRatingData?['ratingId'];
    double selectedRating = existingRating ?? 5.0;
    final hasExistingRating = existingRating != null;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: _cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _mintGreen.withValues(alpha: 0.2)),
          ),
          title: Text(
            hasExistingRating ? 'Update Rating' : 'Rate ${venue.venueName}',
            style: const TextStyle(color: _textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasExistingRating
                    ? 'Your current rating: ${existingRating.toStringAsFixed(1)} ⭐'
                    : 'Tap a star to rate:',
                style: TextStyle(color: _textSecondary, fontSize: 14),
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
                          ? _mintGreen
                          : _cardDarkElevated,
                      size: 48,
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            if (hasExistingRating)
              TextButton(
                onPressed: () async {
                  // Show confirmation dialog
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: _cardDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      title: const Text(
                        'Delete Rating?',
                        style: TextStyle(color: _textPrimary),
                      ),
                      content: Text(
                        'Are you sure you want to remove your rating?',
                        style: TextStyle(color: _textSecondary),
                      ),
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

                  if (confirm == true && ratingId != null) {
                    try {
                      await _ratingService.deleteRating(ratingId);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: _cardDarkElevated,
                          content: const Text('Rating deleted!', style: TextStyle(color: _textPrimary)),
                        ),
                      );
                      await _loadVenues();
                    } catch (e) {
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red.shade400,
                          content: Text('Error: ${e.toString()}'),
                        ),
                      );
                    }
                  }
                },
                child: Text('Delete Rating', style: TextStyle(color: Colors.red.shade400)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: _textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _ratingService.submitRating(
                    venueId: venue.venueId,
                    rating: selectedRating,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: _mintGreenDark,
                      content: Text(
                        hasExistingRating ? 'Rating updated!' : 'Rating submitted!',
                        style: const TextStyle(color: _textPrimary),
                      ),
                    ),
                  );
                  // Reload venues to update average rating
                  await _loadVenues();
                } catch (e) {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red.shade400,
                      content: Text('Error: ${e.toString()}'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _mintGreen,
                foregroundColor: _backgroundDark,
              ),
              child: Text(hasExistingRating ? 'Update' : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _shareVenue(Venue venue) {
    final String shareText = '''
Check out ${venue.venueName} on Clubbies!

${venue.averageRating > 0 ? '⭐ ${venue.averageRating.toStringAsFixed(1)}/5 stars (${venue.reviewCount} reviews)' : '⭐ No ratings yet'}
📍 ${venue.address}
🎉 ${venue.venueType.isNotEmpty ? venue.venueType.first : 'Venue'} | ${venue.ageReq}+
💵 \$${venue.price} | ${venue.capacity}
🕐 ${venue.hours}
${venue.description != null && venue.description!.isNotEmpty ? '\n${venue.description}' : ''}
'''.trim();

    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      shareText,
      subject: venue.venueName,
      sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
    );
  }

  void _showCreateVenueDialog() {
    final formKey = GlobalKey<FormState>();
    final venueNameController = TextEditingController();
    final addressController = TextEditingController();
    final hoursController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    int ageReq = 18;
    String selectedVenueType = 'Nightclub';
    String selectedCapacity = 'Medium';
    bool isSubmitting = false;

    final venueTypes = ['Nightclub', 'Bar', 'Lounge', 'Pub', 'Club', 'Rooftop', 'Beach Club'];
    final capacityOptions = ['Massive', 'Large', 'Medium', 'Small', 'Tiny'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: const Color(0xFF121212).withValues(alpha: 0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border.all(
                  color: _mintGreen.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _cardDarkElevated,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _mintGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.add_business, color: _mintGreen, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Create Venue',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: _cardDarkElevated,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: _textSecondary),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Form
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormField(
                              controller: venueNameController,
                              label: 'Venue Name',
                              hint: 'Enter venue name',
                              icon: Icons.storefront,
                              validator: (v) => v?.isEmpty == true ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildFormField(
                              controller: addressController,
                              label: 'Address',
                              hint: 'Enter full address',
                              icon: Icons.location_on,
                              validator: (v) => v?.isEmpty == true ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildFormField(
                              controller: hoursController,
                              label: 'Hours',
                              hint: 'e.g., 10PM - 4AM',
                              icon: Icons.access_time,
                              validator: (v) => v?.isEmpty == true ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            // Venue Type Dropdown
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.category, color: _mintGreen, size: 18),
                                    const SizedBox(width: 8),
                                    const Text('Venue Type', style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: _cardDarkElevated,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedVenueType,
                                      isExpanded: true,
                                      dropdownColor: _cardDark,
                                      style: const TextStyle(color: _textPrimary),
                                      items: venueTypes.map((type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      )).toList(),
                                      onChanged: (value) {
                                        setModalState(() => selectedVenueType = value!);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Age Requirement
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.cake, color: _mintGreen, size: 18),
                                    const SizedBox(width: 8),
                                    const Text('Age Requirement', style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [18, 21, 25].map((age) {
                                    final isSelected = ageReq == age;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: GestureDetector(
                                        onTap: () => setModalState(() => ageReq = age),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: isSelected ? _mintGreen : _cardDarkElevated,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected ? _mintGreen : Colors.white.withValues(alpha: 0.08),
                                            ),
                                          ),
                                          child: Text(
                                            '$age+',
                                            style: TextStyle(
                                              color: isSelected ? _backgroundDark : _textSecondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Capacity Dropdown
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.people, color: _mintGreen, size: 18),
                                          const SizedBox(width: 8),
                                          const Text('Capacity', style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: _cardDarkElevated,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: selectedCapacity,
                                            isExpanded: true,
                                            dropdownColor: _cardDark,
                                            style: const TextStyle(color: _textPrimary),
                                            items: capacityOptions.map((cap) => DropdownMenuItem(
                                              value: cap,
                                              child: Text(cap),
                                            )).toList(),
                                            onChanged: (value) {
                                              setModalState(() => selectedCapacity = value!);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFormField(
                                    controller: priceController,
                                    label: 'Price (\$)',
                                    hint: 'e.g., 20',
                                    icon: Icons.attach_money,
                                    keyboardType: TextInputType.number,
                                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildFormField(
                              controller: descriptionController,
                              label: 'Description (Optional)',
                              hint: 'Describe the venue...',
                              icon: Icons.description,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 24),
                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isSubmitting ? null : () async {
                                  if (formKey.currentState!.validate()) {
                                    setModalState(() => isSubmitting = true);
                                    try {
                                      await _adminService.createVenue(
                                        venueName: venueNameController.text.trim(),
                                        address: addressController.text.trim(),
                                        hours: hoursController.text.trim(),
                                        venueType: [selectedVenueType],
                                        ageReq: ageReq,
                                        capacity: selectedCapacity,
                                        price: int.tryParse(priceController.text.trim()) ?? 0,
                                        description: descriptionController.text.trim().isEmpty
                                            ? null
                                            : descriptionController.text.trim(),
                                      );
                                      if (!context.mounted) return;
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: _mintGreenDark,
                                          content: const Text('Venue created successfully!', style: TextStyle(color: _textPrimary)),
                                        ),
                                      );
                                      // Reload venues
                                      _loadVenues();
                                    } catch (e) {
                                      setModalState(() => isSubmitting = false);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red.shade400,
                                          content: Text('Error: ${e.toString()}'),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _mintGreen,
                                  foregroundColor: _backgroundDark,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  disabledBackgroundColor: _mintGreen.withValues(alpha: 0.5),
                                ),
                                child: isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(_backgroundDark),
                                        ),
                                      )
                                    : const Text(
                                        'Create Venue',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _mintGreen, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: _textPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: _textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _textSecondary.withValues(alpha: 0.5)),
            filled: true,
            fillColor: _cardDarkElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _mintGreen.withValues(alpha: 0.5)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  // Dark theme colors with mint green accents
  static const Color _backgroundDark = Color(0xFF0A0A0A);
  static const Color _surfaceDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1C1C1E);
  static const Color _cardDarkElevated = Color(0xFF2C2C2E);
  static const Color _mintGreen = Color(0xFFA8C5B4);
  static const Color _mintGreenLight = Color(0xFFBED4C6);
  static const Color _mintGreenDark = Color(0xFF7A9B87);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFFAAAAAA);

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
      floatingActionButton: _currentUser?.isAdmin == true
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PhotoUploadPage()),
                );

                // Refresh photos if upload was successful
                if (result == true) {
                  _loadVenuePhotos();
                }
              },
              backgroundColor: _mintGreen,
              child: Icon(Icons.add_a_photo, color: _backgroundDark),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _mintGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.nightlife, color: _mintGreen, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Clubbies',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          if (_currentUser?.isAdmin == true)
            Row(
              children: [
                // Create Venue Button
                Container(
                  decoration: BoxDecoration(
                    color: _mintGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _mintGreen.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add_business, color: _mintGreen),
                    onPressed: () => _showCreateVenueDialog(),
                    tooltip: 'Create Venue',
                  ),
                ),
                const SizedBox(width: 8),
                // Admin Dashboard Button
                Container(
                  decoration: BoxDecoration(
                    color: _cardDarkElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _mintGreen.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.admin_panel_settings, color: _mintGreen),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminPage()),
                      );
                    },
                    tooltip: 'Admin Dashboard',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFeed() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_mintGreen),
        ),
      );
    }

    if (_errorMessage != null) {
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
                'Error Loading Feed',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(color: _textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadVenues();
                },
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
        ),
      );
    }

    if (_venues.isEmpty) {
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
              child: Icon(Icons.explore_outlined, color: _mintGreen.withValues(alpha: 0.6), size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              'No venues available yet.',
              style: TextStyle(color: _textSecondary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _venues.length,
      itemBuilder: (context, index) {
        return _buildVenuePost(_venues[index]);
      },
    );
  }

  Widget _buildVenuePost(Venue venue) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _cardDark.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _mintGreen.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _mintGreen.withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Venue Image Placeholder
              _buildVenueImage(venue),

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
                                venue.venueName,
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
                                  Expanded(
                                    child: Text(
                                      venue.address,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _mintGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _mintGreen.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            venue.venueType.isNotEmpty ? venue.venueType.first : 'Venue',
                            style: const TextStyle(
                              color: _mintGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Venue details
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _buildInfoChip(Icons.access_time, venue.hours),
                        _buildInfoChip(Icons.people, venue.capacity),
                        _buildInfoChip(Icons.attach_money, '\$${venue.price}'),
                        _buildInfoChip(Icons.cake, '${venue.ageReq}+'),
                      ],
                    ),

                    // Description
                    if (venue.description != null && venue.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        venue.description!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        // Rating display - tappable to rate
                        GestureDetector(
                          onTap: () => _showRatingDialog(venue),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _mintGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: _mintGreen, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  venue.averageRating > 0
                                      ? venue.averageRating.toStringAsFixed(1)
                                      : 'Rate',
                                  style: const TextStyle(
                                    color: _mintGreen,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildActionButton(
                          Icons.comment_outlined,
                          '${venue.reviewCount}',
                          () => _showReviewsModal(venue),
                        ),
                        const SizedBox(width: 16),
                        _buildActionButton(Icons.share_outlined, 'Share', () => _shareVenue(venue)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVenueImage(Venue venue) {
    final photos = _venuePhotos[venue.venueId] ?? [];
    final hasPhoto = photos.isNotEmpty;

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cardDarkElevated,
            _mintGreenDark.withValues(alpha: 0.3),
            _cardDark,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Display actual photo or placeholder
          if (hasPhoto)
            Image.network(
              photos[0].imgUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to placeholder if image fails to load
                return _buildPlaceholder(venue);
              },
            )
          else
            _buildPlaceholder(venue),
          // Age requirement badge
          Positioned(
            top: 12,
            right: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _cardDark.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _mintGreen.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.badge, color: _mintGreen, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${venue.ageReq}+',
                        style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(Venue venue) {
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
            child: Icon(
              Icons.nightlife_outlined,
              size: 50,
              color: _mintGreen.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            venue.venueName,
            style: TextStyle(
              color: _textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _cardDarkElevated.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _mintGreenLight, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: _textSecondary, fontSize: 12),
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
          Icon(icon, color: _textSecondary, size: 22),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: _textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewsModal(Venue venue) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReviewsModalSheet(
        venue: venue,
        currentUser: _currentUser,
      ),
    );

    // If a review was posted, reload venues to update ratings
    if (result == true) {
      setState(() {
        _isLoading = true;
      });
      _loadVenues();
    }
  }

}

// Reviews Modal Bottom Sheet Widget
class _ReviewsModalSheet extends StatefulWidget {
  final Venue venue;
  final User? currentUser;

  const _ReviewsModalSheet({
    required this.venue,
    this.currentUser,
  });

  @override
  State<_ReviewsModalSheet> createState() => _ReviewsModalSheetState();
}

class _ReviewsModalSheetState extends State<_ReviewsModalSheet> {
  // Dark theme colors
  static const Color _backgroundDark = Color(0xFF0A0A0A);
  static const Color _surfaceDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1C1C1E);
  static const Color _cardDarkElevated = Color(0xFF2C2C2E);
  static const Color _mintGreen = Color(0xFFA8C5B4);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFFAAAAAA);

  final ReviewService _reviewService = ReviewService();
  List<Review> _reviews = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _reviewTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _reviewTextController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await _reviewService.getVenueReviews(widget.venue.venueId);
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitReview() async {
    if (_reviewTextController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review')),
      );
      return;
    }

    try {
      await _reviewService.createReview(
        venueId: widget.venue.venueId,
        reviewText: _reviewTextController.text.trim(),
      );

      _reviewTextController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review posted successfully!')),
      );

      // Reload reviews
      setState(() {
        _isLoading = true;
      });
      await _loadReviews();

      // Notify parent to refresh venues
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting review: ${e.toString()}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: _surfaceDark.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(
              color: _mintGreen.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _cardDarkElevated,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.venue.venueName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.chat_bubble_outline, color: _mintGreen, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '${_reviews.length} Reviews',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: _mintGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: _cardDarkElevated,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: _textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Write Review Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _mintGreen.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_outlined, color: _mintGreen, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Write a Review',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _reviewTextController,
                      maxLines: 3,
                      style: const TextStyle(color: _textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Share your experience...',
                        hintStyle: TextStyle(color: _textSecondary.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: _cardDarkElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _mintGreen.withValues(alpha: 0.5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _mintGreen,
                          foregroundColor: _backgroundDark,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Post Review',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Reviews List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(_mintGreen),
                        ),
                      )
                    : _errorMessage != null
                        ? Center(
                            child: Text(
                              'Error: $_errorMessage',
                              style: const TextStyle(color: _textSecondary),
                            ),
                          )
                        : _reviews.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: _mintGreen.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.rate_review_outlined, color: _mintGreen.withValues(alpha: 0.6), size: 40),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'No reviews yet. Be the first!',
                                      style: TextStyle(color: _textSecondary, fontSize: 16),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: _reviews.length,
                                itemBuilder: (context, index) {
                                  return _buildReviewItem(_reviews[index]);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    final isOwnReview = widget.currentUser?.userId == review.userId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and rating
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _mintGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: _mintGreen, size: 22),
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
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDateTime(review.createdAt),
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Delete button for own reviews
              if (isOwnReview)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                    onPressed: () => _deleteReview(review),
                    tooltip: 'Delete review',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            review.reviewText,
            style: TextStyle(
              color: _textPrimary.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReview(Review review) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
        ),
        title: const Text(
          'Delete Review?',
          style: TextStyle(color: _textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete this review? This action cannot be undone.',
          style: TextStyle(color: _textSecondary),
        ),
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

    if (confirm == true) {
      try {
        await _reviewService.deleteReview(review.reviewId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted successfully')),
        );
        // Reload reviews and notify parent to update count
        setState(() {
          _isLoading = true;
        });
        await _loadReviews();
        // Close modal and signal parent to reload
        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete review: ${e.toString()}')),
        );
      }
    }
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