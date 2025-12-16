import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review.dart';
import 'storage_service.dart';

class ReviewService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  final StorageService _storageService = StorageService();

  // Get reviews for a venue
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

  // Get replies for a specific review
  Future<List<Review>> getReviewReplies(int reviewId, {int limit = 50}) async {
    final uri = Uri.parse('$baseUrl/reviews/reviews/$reviewId/replies').replace(
      queryParameters: {'limit': limit.toString()},
    );

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final repliesList = responseData['replies'] as List;
      return repliesList.map((reply) => Review.fromJson(reply)).toList();
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to fetch replies: ${errorBody['detail']}');
    }
  }

  // Create a review or reply
  Future<Review> createReview({
    required int venueId,
    double? rating,  // Required for main reviews, null for replies
    String? reviewText,
    int? parentReviewId,  // Null for main reviews, has value for replies
  }) async {
    final token = await _storageService.getToken();
    final tokenType = await _storageService.getTokenType();

    final Map<String, dynamic> body = {
      'venue_id': venueId.toString(),
    };

    if (rating != null) {
      body['rating'] = rating.toString();
    }

    if (reviewText != null) {
      body['review_text'] = reviewText;
    }

    if (parentReviewId != null) {
      body['parent_review_id'] = parentReviewId.toString();
    }

    final response = await http.post(
      Uri.parse('$baseUrl/reviews/upload-review'),
      headers: {
        'Authorization': '$tokenType $token',
      },
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
    final token = await _storageService.getToken();
    final tokenType = await _storageService.getTokenType();

    final response = await http.delete(
      Uri.parse('$baseUrl/reviews/delete-review').replace(
        queryParameters: {'review_id': reviewId.toString()},
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$tokenType $token',
      },
    );

    if (response.statusCode != 204) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to delete review: ${errorBody['detail']}');
    }
  }

  // Update a review
  Future<Review> updateReview(int reviewId, {double? rating, String? reviewText}) async {
    final token = await _storageService.getToken();
    final tokenType = await _storageService.getTokenType();

    final Map<String, dynamic> body = {};

    if (rating != null) {
      body['rating'] = rating.toString();
    }

    if (reviewText != null) {
      body['review_text'] = reviewText;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/reviews/update-review/$reviewId'),
      headers: {
        'Authorization': '$tokenType $token',
      },
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