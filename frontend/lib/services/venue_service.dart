import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/venue.dart';

class VenueService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Get all venues (for feed page)
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

  // Get venue by ID
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
}