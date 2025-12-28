import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/venue.dart';
import 'api_service.dart';
import '../config/environment.dart';

class VenueService {
  static String get baseUrl => Environment.apiBaseUrl;
  final ApiService _apiService = ApiService();

  // Get all venues (for feed page) - public endpoint
  Future<List<Venue>> getAllVenues({
    int? afterVenueId,
    int limit = 20,
  }) async {
    final Map<String, String> queryParams = {
      'limit': limit.toString(),
    };

    if (afterVenueId != null) {
      queryParams['after_venue_id'] = afterVenueId.toString();
    }

    final uri = Uri.parse('$baseUrl/venues/').replace(
      queryParameters: queryParams,
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
      throw Exception('Failed to fetch venues: ${errorBody['detail']}');
    }
  }

  // Get venue by ID - public endpoint
  Future<Venue> getVenueById(int venueId) async {
    final uri = Uri.parse('$baseUrl/venues/$venueId');

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final venueData = jsonDecode(response.body);
      return Venue.fromJson(venueData);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to fetch venue: ${errorBody['detail']}');
    }
  }

  // Get venues rated by the current user - requires auth
  Future<List<Venue>> getUserRatedVenues() async {
    final response = await _apiService.get('$baseUrl/ratings/user/venues');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final venuesList = responseData['venues'] as List;
      return venuesList.map((venue) => Venue.fromJson(venue)).toList();
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to fetch rated venues: ${errorBody['detail']}');
    }
  }
}
