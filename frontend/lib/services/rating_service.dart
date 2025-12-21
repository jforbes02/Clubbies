import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class RatingService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  final StorageService _storageService = StorageService();

  // Submit or update a rating for a venue
  Future<void> submitRating({
    required int venueId,
    required double rating,
  }) async {
    final token = await _storageService.getToken();
    final tokenType = await _storageService.getTokenType();

    final Map<String, dynamic> body = {
      'venue_id': venueId.toString(),
      'rating': rating.toString(),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/ratings/submit'),
      headers: {
        'Authorization': '$tokenType $token',
      },
      body: body,
    );

    if (response.statusCode != 201) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to submit rating: ${errorBody['detail']}');
    }
  }

  // Get the current user's rating for a specific venue
  Future<double?> getUserRating(int venueId) async {
    final token = await _storageService.getToken();
    final tokenType = await _storageService.getTokenType();

    final response = await http.get(
      Uri.parse('$baseUrl/ratings/user/venue/$venueId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$tokenType $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['rating'] == null) {
        return null;
      }
      return (responseData['rating'] as num).toDouble();
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to fetch user rating: ${errorBody['detail']}');
    }
  }

  // Delete a rating
  Future<void> deleteRating(int ratingId) async {
    final token = await _storageService.getToken();
    final tokenType = await _storageService.getTokenType();

    final response = await http.delete(
      Uri.parse('$baseUrl/ratings/$ratingId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$tokenType $token',
      },
    );

    if (response.statusCode != 204) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to delete rating: ${errorBody['detail']}');
    }
  }
}
