import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import '../services/photo_service.dart';
import '../services/venue_service.dart';
import '../services/user_service.dart';
import '../models/venue.dart';

class PhotoUploadPage extends StatefulWidget {
  const PhotoUploadPage({super.key});

  @override
  State<PhotoUploadPage> createState() => _PhotoUploadPageState();
}

class _PhotoUploadPageState extends State<PhotoUploadPage> {
  final PhotoService _photoService = PhotoService();
  final VenueService _venueService = VenueService();
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();

  // Dark theme colors with mint green accents
  static const Color _backgroundDark = Color(0xFF0A0A0A);
  static const Color _surfaceDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1C1C1E);
  static const Color _cardDarkElevated = Color(0xFF2C2C2E);
  static const Color _mintGreen = Color(0xFFA8C5B4);
  static const Color _mintGreenDark = Color(0xFF7A9B87);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFFAAAAAA);

  File? _selectedImage;
  List<Venue> _venues = [];
  Venue? _selectedVenue;
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
    _loadVenues();
  }

  Future<void> _checkAdminAccess() async {
    try {
      final user = await _userService.getCurrentUserProfile();
      if (user.role != 'admin') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.shade400,
              content: const Text('Admin access required to upload photos'),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade400,
            content: Text('Error checking permissions: $e'),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _loadVenues() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final venues = await _venueService.getAllVenues();
      setState(() {
        _venues = venues;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load venues: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade400,
            content: Text('Failed to pick image: $e'),
          ),
        );
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: _surfaceDark.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border.all(
                color: _mintGreen.withValues(alpha: 0.1),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _cardDarkElevated,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(Icons.add_photo_alternate, color: _mintGreen, size: 22),
                        const SizedBox(width: 12),
                        const Text(
                          'Select Image Source',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildImageSourceOption(
                      Icons.photo_library,
                      'Choose from Gallery',
                      'Select an existing photo',
                      () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildImageSourceOption(
                      Icons.camera_alt,
                      'Take a Photo',
                      'Use your camera',
                      () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _mintGreen.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _mintGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _mintGreen, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: _textSecondary),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadPhoto() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _cardDarkElevated,
          content: const Text('Please select an image first', style: TextStyle(color: _textPrimary)),
        ),
      );
      return;
    }

    if (_selectedVenue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _cardDarkElevated,
          content: const Text('Please select a venue', style: TextStyle(color: _textPrimary)),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      await _photoService.uploadPhoto(
        imageFile: _selectedImage!,
        venueId: _selectedVenue!.venueId,
        caption: _captionController.text.trim().isEmpty
            ? null
            : _captionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _mintGreenDark,
            content: const Text('Photo uploaded successfully!', style: TextStyle(color: _textPrimary)),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to upload photo: $e';
        _isUploading = false;
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
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_mintGreen),
                  ),
                )
              : Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Image preview
                            _buildImagePreview(),
                            const SizedBox(height: 24),

                            // Venue dropdown
                            _buildVenueDropdown(),
                            const SizedBox(height: 20),

                            // Caption input
                            _buildCaptionInput(),
                            const SizedBox(height: 24),

                            // Error message
                            if (_errorMessage != null) _buildErrorMessage(),

                            // Upload button
                            _buildUploadButton(),
                          ],
                        ),
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
            child: const Icon(Icons.add_photo_alternate, color: _mintGreen, size: 22),
          ),
          const SizedBox(width: 12),
          const Text(
            'Upload Photo',
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

  Widget _buildImagePreview() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selectedImage != null
                ? _mintGreen.withValues(alpha: 0.3)
                : _mintGreen.withValues(alpha: 0.1),
            width: _selectedImage != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _selectedImage != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
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
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: _mintGreen, size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              'Tap to change photo',
                              style: TextStyle(
                                color: _textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _mintGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 50,
                        color: _mintGreen.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tap to select a photo',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose from gallery or take a new photo',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildVenueDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: _mintGreen, size: 18),
            const SizedBox(width: 8),
            const Text(
              'Select Venue',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _selectedVenue != null
                  ? _mintGreen.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Venue>(
              isExpanded: true,
              hint: Text('Choose a venue', style: TextStyle(color: _textSecondary)),
              value: _selectedVenue,
              dropdownColor: _cardDark,
              style: const TextStyle(color: _textPrimary),
              icon: Icon(Icons.keyboard_arrow_down, color: _textSecondary),
              items: _venues.map((venue) {
                return DropdownMenuItem(
                  value: venue,
                  child: Text(venue.venueName),
                );
              }).toList(),
              onChanged: (venue) {
                setState(() {
                  _selectedVenue = venue;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, color: _mintGreen, size: 18),
            const SizedBox(width: 8),
            const Text(
              'Caption (optional)',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _captionController,
          maxLength: 255,
          maxLines: 3,
          style: const TextStyle(color: _textPrimary),
          decoration: InputDecoration(
            hintText: 'Write a caption for your photo...',
            hintStyle: TextStyle(color: _textSecondary.withValues(alpha: 0.5)),
            filled: true,
            fillColor: _cardDark,
            counterStyle: TextStyle(color: _textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _mintGreen.withValues(alpha: 0.5)),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade400, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return ElevatedButton(
      onPressed: _isUploading ? null : _uploadPhoto,
      style: ElevatedButton.styleFrom(
        backgroundColor: _mintGreen,
        foregroundColor: _backgroundDark,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        disabledBackgroundColor: _mintGreen.withValues(alpha: 0.5),
        elevation: 0,
      ),
      child: _isUploading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(_backgroundDark),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.cloud_upload, size: 22),
                SizedBox(width: 10),
                Text(
                  'Upload Photo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }
}
