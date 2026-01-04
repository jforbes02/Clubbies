import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/search_service.dart';
import '../models/venue.dart';
import '../models/user.dart';
import 'venue_detail.dart';
import 'other_user_profile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();
  String _searchType = 'Venues'; // 'Venues' or 'People'
  bool _showFilters = false;

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

  // Filter states
  String? _selectedVenueType;
  String? _selectedCapacity;
  RangeValues _priceRange = const RangeValues(0, 500);
  int _minAge = 18;
  String? _selectedHours;

  // Search results
  List<Venue> _venueResults = [];
  List<User> _userResults = [];
  bool _isSearching = false;
  String? _searchError;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      if (_searchType == 'Venues') {
        final venues = await _searchService.searchVenues(
          venueName: query.isNotEmpty ? query : null,
          venueType: _selectedVenueType,
          minCapacity: _selectedCapacity,
          maxCapacity: _selectedCapacity,
          hours: _selectedHours,
          maxPrice: _priceRange.end < 500 ? _priceRange.end.round() : null,
          minAge: _minAge > 18 ? _minAge : null,
        );
        setState(() {
          _venueResults = venues;
          _isSearching = false;
        });
      } else {
        if (query.isEmpty) {
          setState(() {
            _userResults = [];
            _isSearching = false;
          });
          return;
        }
        final users = await _searchService.searchUsers(username: query);
        setState(() {
          _userResults = users;
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _searchError = e.toString();
        _isSearching = false;
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
          child: Column(
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 16),

              // Search type toggle
              _buildSearchTypeToggle(),
              const SizedBox(height: 16),

              // Search bar
              _buildSearchBar(),
              const SizedBox(height: 16),

              // Filters (if shown)
              if (_showFilters && _searchType == 'Venues') _buildFilters(),

              // Results
              Expanded(
                child: _buildResults(),
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
                child: const Icon(Icons.search, color: _mintGreen, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Search',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: _showFilters
                  ? _mintGreen.withValues(alpha: 0.2)
                  : _cardDarkElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _showFilters
                    ? _mintGreen.withValues(alpha: 0.5)
                    : _mintGreen.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                _showFilters ? Icons.filter_list_off : Icons.filter_list,
                color: _mintGreen,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
              tooltip: _showFilters ? 'Hide Filters' : 'Show Filters',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTypeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _mintGreen.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildToggleButton('Venues', Icons.nightlife),
            ),
            Expanded(
              child: _buildToggleButton('People', Icons.people),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String type, IconData icon) {
    final isSelected = _searchType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _searchType = type;
          _showFilters = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _mintGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? _backgroundDark : _textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? _backgroundDark : _textSecondary,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(16),
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
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: _textPrimary),
          decoration: InputDecoration(
            hintText: 'Search ${_searchType.toLowerCase()}...',
            hintStyle: TextStyle(color: _textSecondary.withValues(alpha: 0.5)),
            prefixIcon: Icon(Icons.search, color: _mintGreen.withValues(alpha: 0.7)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: _textSecondary),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _venueResults = [];
                        _userResults = [];
                        _searchError = null;
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          onChanged: (value) {
            setState(() {});
          },
          onSubmitted: (value) {
            _performSearch();
          },
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardDark.withValues(alpha: 0.9),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _mintGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.tune, color: _mintGreen, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Venue Type
          _buildFilterDropdown(
            'Venue Type',
            Icons.category,
            _selectedVenueType,
            ['Nightclub', 'Bar', 'Lounge', 'Jazz Club', 'Rooftop', 'Sports Bar', 'College'],
            (value) => setState(() => _selectedVenueType = value),
          ),
          const SizedBox(height: 16),

          // Capacity
          _buildFilterDropdown(
            'Capacity',
            Icons.people,
            _selectedCapacity,
            ['Tiny', 'Small', 'Medium', 'Large', 'Massive'],
            (value) => setState(() => _selectedCapacity = value),
          ),
          const SizedBox(height: 16),

          // Hours
          _buildFilterDropdown(
            'Hours',
            Icons.access_time,
            _selectedHours,
            ['Morning', 'Afternoon', 'Evening', 'Late Night', '24/7'],
            (value) => setState(() => _selectedHours = value),
          ),
          const SizedBox(height: 16),

          // Price Range
          Row(
            children: [
              Icon(Icons.attach_money, color: _mintGreen, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Price Range',
                style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _mintGreen,
              inactiveTrackColor: _cardDarkElevated,
              thumbColor: _mintGreen,
              overlayColor: _mintGreen.withValues(alpha: 0.2),
              valueIndicatorColor: _mintGreen,
              valueIndicatorTextStyle: TextStyle(color: _backgroundDark),
            ),
            child: RangeSlider(
              values: _priceRange,
              min: 0,
              max: 500,
              divisions: 50,
              labels: RangeLabels(
                '\$${_priceRange.start.round()}',
                '\$${_priceRange.end.round()}',
              ),
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _cardDarkElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                style: TextStyle(color: _mintGreen, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Minimum Age
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.cake, color: _mintGreen, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Minimum Age',
                    style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: _cardDarkElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _mintGreen.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: _textSecondary, size: 18),
                      onPressed: () {
                        if (_minAge > 16) setState(() => _minAge--);
                      },
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _mintGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_minAge+',
                        style: TextStyle(color: _mintGreen, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: _textSecondary, size: 18),
                      onPressed: () {
                        if (_minAge < 25) setState(() => _minAge++);
                      },
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Apply/Clear buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _performSearch();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Filters applied!', style: TextStyle(color: _textPrimary)),
                        backgroundColor: _mintGreenDark,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mintGreen,
                    foregroundColor: _backgroundDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedVenueType = null;
                      _selectedCapacity = null;
                      _selectedHours = null;
                      _priceRange = const RangeValues(0, 500);
                      _minAge = 18;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _textSecondary, width: 1),
                    foregroundColor: _textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, IconData icon, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _mintGreen, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
            ),
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
              value: value,
              isExpanded: true,
              hint: Text('Select $label', style: TextStyle(color: _textSecondary.withValues(alpha: 0.5))),
              dropdownColor: _cardDark,
              style: const TextStyle(color: _textPrimary),
              icon: Icon(Icons.arrow_drop_down, color: _mintGreen),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (_isSearching) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_mintGreen),
        ),
      );
    }

    if (_searchError != null) {
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
                'Search Error',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchError!,
                style: TextStyle(color: _textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _performSearch,
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

    if (_searchType == 'Venues') {
      if (_venueResults.isEmpty) {
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
              const SizedBox(height: 16),
              Text(
                'No venues found',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching or adjusting filters',
                style: TextStyle(color: _textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 80),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _venueResults.length,
          itemBuilder: (context, index) {
            return _buildVenueCard(_venueResults[index]);
          },
        ),
      );
    } else {
      if (_userResults.isEmpty) {
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
                  Icons.person_search_outlined,
                  size: 50,
                  color: _mintGreen.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No users found',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching for a username',
                style: TextStyle(color: _textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 80),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _userResults.length,
          itemBuilder: (context, index) {
            return _buildPersonCard(_userResults[index]);
          },
        ),
      );
    }
  }

  Widget _buildVenueCard(Venue venue) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VenueDetailPage(venue: venue),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          venue.venueName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                          ),
                        ),
                      ),
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
                  Row(
                    children: [
                      Icon(Icons.location_on, color: _mintGreenLight, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          venue.address,
                          style: TextStyle(color: _textSecondary, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.access_time, venue.hours),
                      _buildInfoChip(Icons.people, venue.capacity),
                      _buildInfoChip(Icons.attach_money, '\$${venue.price}'),
                      _buildInfoChip(Icons.cake, '${venue.ageReq}+'),
                    ],
                  ),
                  if (venue.averageRating > 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _mintGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: _mintGreen, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                venue.averageRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: _mintGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${venue.reviewCount} reviews',
                          style: TextStyle(color: _textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _cardDarkElevated.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _mintGreenLight, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: _textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _mintGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _mintGreen.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(Icons.person, color: _mintGreen, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          color: _mintGreen,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtherUserProfilePage(searchUser: user),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mintGreen,
                    foregroundColor: _backgroundDark,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
