import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/venue.dart';
import '../models/user.dart';

class SearchService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Search venues with filters
  Future<List<Venue>> searchVenues({
    String? venueName,
    String? minCapacity,
    String? maxCapacity,
    String? hours,
    String? venueType,
    int? maxPrice,
    int? minAge,
    String? locationSearch,
    int? afterVenueId,
    int limit = 20,
  }) async {
    // Build query parameters
    final Map<String, String> queryParams = {};

    if (venueName != null && venueName.isNotEmpty) {
      queryParams['venue_name'] = venueName;
    }
    if (minCapacity != null) queryParams['min_capacity'] = minCapacity;
    if (maxCapacity != null) queryParams['max_capacity'] = maxCapacity;
    if (hours != null) queryParams['hours'] = hours;
    if (venueType != null) queryParams['venue_type'] = venueType;
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
    if (minAge != null) queryParams['min_age'] = minAge.toString();
    if (locationSearch != null && locationSearch.isNotEmpty) {
      queryParams['location_search'] = locationSearch;
    }
    if (afterVenueId != null) {
      queryParams['after_venue_id'] = afterVenueId.toString();
    }
    queryParams['limit'] = limit.toString();

    final uri = Uri.parse('$baseUrl/venues/search').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final venuesList = responseData['venues'] as List;
      return venuesList.map((venue) => Venue.fromJson(venue)).toList();
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to search venues: ${errorBody['detail']}');
    }
  }

  // Search users by username
  // Note: This endpoint doesn't exist yet in your backend
  // You'll need to add it to users/controller.py
  Future<List<User>> searchUsers({
    required String username,
    int limit = 10,
  }) async {
    final uri = Uri.parse('$baseUrl/users/search').replace(
      queryParameters: {
        'username': username,
        'limit': limit.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      // Assuming the response is a list of users
      final usersList = responseData is List ? responseData : responseData['users'] as List;
      return usersList.map((user) => User.fromJson(user)).toList();
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to search users: ${errorBody['detail']}');
    }
  }
}
