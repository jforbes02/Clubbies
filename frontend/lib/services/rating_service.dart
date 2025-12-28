import 'dart:convert';
import 'api_service.dart';
import '../config/environment.dart';

class RatingService {
  static String get baseUrl => Environment.apiBaseUrl;
  final ApiService _apiService = ApiService();

  // Submit or update a rating for a venue
  Future<void> submitRating({
    required int venueId,
    required double rating,
  }) async {
    final Map<String, String> body = {
      'venue_id': venueId.toString(),
      'rating': rating.toString(),
    };

    final response = await _apiService.postFormData(
      '$baseUrl/ratings/submit',
      body: body,
    );

    if (response.statusCode != 201) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to submit rating: ${errorBody['detail']}');
    }
  }

  // Get the current user's rating for a specific venue
  // Returns a map with 'rating' and 'ratingId' keys
  Future<Map<String, dynamic>?> getUserRating(int venueId) async {
    final response = await _apiService.get('$baseUrl/ratings/user/venue/$venueId');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['rating'] == null) {
        return null;
      }
      return {
        'rating': (responseData['rating'] as num).toDouble(),
        'ratingId': responseData['rating_id'] as int,
      };
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to fetch user rating: ${errorBody['detail']}');
    }
  }

  // Delete a rating
  Future<void> deleteRating(int ratingId) async {
    final response = await _apiService.delete('$baseUrl/ratings/$ratingId');

    if (response.statusCode != 204) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to delete rating: ${errorBody['detail']}');
    }
  }
}
