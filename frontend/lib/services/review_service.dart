import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review.dart';
import 'api_service.dart';
import '../config/environment.dart';

class ReviewService {
  static String get baseUrl => Environment.apiBaseUrl;
  final ApiService _apiService = ApiService();

  // Get reviews for a venue (public endpoint, no auth needed)
  Future<List<Review>> getVenueReviews(int venueId, {int? afterReviewId, int limit = 20}) async {
    final Map<String, String> queryParams = {
      'limit': limit.toString(),
    };

    if (afterReviewId != null) {
      queryParams['after_review_id'] = afterReviewId.toString();
    }

    final uri = Uri.parse('$baseUrl/reviews/venues/$venueId').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final reviewsList = responseData['reviews'] as List;
      return reviewsList.map((review) => Review.fromJson(review)).toList();
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to fetch reviews: ${errorBody['detail']}');
    }
  }

  // Get all reviews written by a specific user (requires auth)
  Future<List<Review>> getUserReviews(int userId, {int? afterReviewId, int limit = 50}) async {
    final Map<String, String> queryParams = {
      'limit': limit.toString(),
    };

    if (afterReviewId != null) {
      queryParams['after_review_id'] = afterReviewId.toString();
    }

    final uri = Uri.parse('$baseUrl/reviews/users/$userId').replace(
      queryParameters: queryParams,
    );

    final response = await _apiService.get(uri.toString());

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final reviewsList = responseData['reviews'] as List;
      return reviewsList.map((review) => Review.fromJson(review)).toList();
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to fetch user reviews: ${errorBody['detail']}');
    }
  }

  // Create a review
  Future<Review> createReview({
    required int venueId,
    required String reviewText,
  }) async {
    final Map<String, String> body = {
      'venue_id': venueId.toString(),
      'review_text': reviewText,
    };

    final response = await _apiService.postFormData(
      '$baseUrl/reviews/upload-review',
      body: body,
    );

    if (response.statusCode == 201) {
      final reviewData = jsonDecode(response.body);
      return Review.fromJson(reviewData);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to create review: ${errorBody['detail']}');
    }
  }

  // Delete a review
  Future<void> deleteReview(int reviewId) async {
    final uri = Uri.parse('$baseUrl/reviews/delete-review').replace(
      queryParameters: {'review_id': reviewId.toString()},
    );

    final response = await _apiService.delete(uri.toString());

    if (response.statusCode != 204) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to delete review: ${errorBody['detail']}');
    }
  }

  // Update a review
  Future<Review> updateReview(int reviewId, {required String reviewText}) async {
    final Map<String, String> body = {
      'review_text': reviewText,
    };

    final response = await _apiService.postFormData(
      '$baseUrl/reviews/update-review/$reviewId',
      body: body,
    );

    if (response.statusCode == 200) {
      final reviewData = jsonDecode(response.body);
      return Review.fromJson(reviewData);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to update review: ${errorBody['detail']}');
    }
  }
}
