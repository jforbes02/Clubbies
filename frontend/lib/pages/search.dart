import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  int _selectedIndex = 1; // Search tab selected
  late AnimationController _wiggleController;
  late Animation<double> _wiggleAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _searchType = 'Venues'; // 'Venues' or 'People'
  bool _showFilters = false;

  // Filter states
  String? _selectedVenueType;
  String? _selectedCapacity;
  RangeValues _priceRange = const RangeValues(0, 500);
  int _minAge = 18;
  String? _selectedHours;

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
    _searchController.dispose();
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
                    // TODO: Apply filters
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
    return Container(
      margin: const EdgeInsets.only(bottom: 80),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 10, // Placeholder
        itemBuilder: (context, index) {
          if (_searchType == 'Venues') {
            return _buildVenueCard(index);
          } else {
            return _buildPersonCard(index);
          }
        },
      ),
    );
  }

  Widget _buildVenueCard(int index) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Venue ${index + 1}',
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
                      child: const Text(
                        'Nightclub',
                        style: TextStyle(color: Colors.white, fontSize: 12),
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
                        '123 Main St, City',
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
                      '9 PM - 2 AM',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.people, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Large',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
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

  Widget _buildPersonCard(int index) {
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
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User ${index + 1}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@username${index + 1}',
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
                  child: const Text('Follow'),
                ),
              ],
            ),
          ),
        ),
      ),
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