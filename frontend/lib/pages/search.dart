import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/search_service.dart';
import '../models/venue.dart';
import '../models/user.dart';
import 'venue_detail.dart';

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
          // Only apply filters if user has explicitly selected them (not null)
          venueType: _selectedVenueType,
          minCapacity: _selectedCapacity,
          maxCapacity: _selectedCapacity,
          hours: _selectedHours,
          // Only apply price/age filters if user has actually adjusted them from defaults
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
    return Container(
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
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Search',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTypeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildToggleButton('Venues'),
            ),
            Expanded(
              child: _buildToggleButton('People'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String type) {
    final isSelected = _searchType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _searchType = type;
          _showFilters = false; // Hide filters when switching
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            type,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(color: Colors.purple.shade900),
          decoration: InputDecoration(
            hintText: 'Search ${_searchType.toLowerCase()}...',
            hintStyle: TextStyle(color: Colors.purple.shade300),
            prefixIcon: Icon(Icons.search, color: Colors.purple.shade600),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.purple.shade600),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Venue Type
          _buildFilterDropdown(
            'Venue Type',
            _selectedVenueType,
            ['Nightclub', 'Bar', 'Lounge', 'Jazz Club', 'Rooftop', 'Sports Bar', 'College'],
            (value) => setState(() => _selectedVenueType = value),
          ),
          const SizedBox(height: 12),

          // Capacity
          _buildFilterDropdown(
            'Capacity',
            _selectedCapacity,
            ['Tiny', 'Small', 'Medium', 'Large', 'Massive'],
            (value) => setState(() => _selectedCapacity = value),
          ),
          const SizedBox(height: 12),

          // Hours
          _buildFilterDropdown(
            'Hours',
            _selectedHours,
            ['Morning', 'Afternoon', 'Evening', 'Late Night', '24/7'],
            (value) => setState(() => _selectedHours = value),
          ),
          const SizedBox(height: 12),

          // Price Range
          const Text(
            'Price Range',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 500,
            divisions: 50,
            activeColor: Colors.white,
            inactiveColor: Colors.white.withValues(alpha: 0.3),
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
          Text(
            '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 12),

          // Minimum Age
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Minimum Age',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                      onPressed: () {
                        if (_minAge > 16) setState(() => _minAge--);
                      },
                    ),
                    Text(
                      '$_minAge+',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white, size: 16),
                      onPressed: () {
                        if (_minAge < 25) setState(() => _minAge++);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Apply/Clear buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _performSearch();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filters applied!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    side: const BorderSide(color: Colors.white, width: 2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text('Select $label', style: const TextStyle(color: Colors.white70)),
              dropdownColor: Colors.purple.shade700,
              style: const TextStyle(color: Colors.white),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
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
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchError!,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _performSearch,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchType == 'Venues') {
      if (_venueResults.isEmpty) {
        return Center(
          child: Text(
            'No venues found. Try searching or adjusting filters.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16),
            textAlign: TextAlign.center,
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 80),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _venueResults.length,
          itemBuilder: (context, index) {
            return _buildVenueCard(_venueResults[index]);
          },
        ),
      );
    } else {
      if (_userResults.isEmpty) {
        return Center(
          child: Text(
            'No users found. Try searching for a username.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16),
            textAlign: TextAlign.center,
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 80),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
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
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          venue.venueType.isNotEmpty ? venue.venueType.first : 'Venue',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          venue.address,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        venue.hours,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.people, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        venue.capacity,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.white70, size: 16),
                      Text(
                        '\$${venue.price}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.cake, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${venue.ageReq}+',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonCard(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
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
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('View'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}