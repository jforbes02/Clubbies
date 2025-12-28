import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/photo.dart';
import 'api_service.dart';
import '../config/environment.dart';

class PhotoService {
  static String get baseUrl => Environment.apiBaseUrl;
  final ApiService _apiService = ApiService();

  // Get photos for a venue (with pagination) - public endpoint
  Future<Map<String, dynamic>> getVenuePhotos(int venueId, {int? afterPhotoId, int limit = 20}) async {
    final Map<String, String> queryParams = {
      'limit': limit.toString(),
    };

    if (afterPhotoId != null) {
      queryParams['after_photo_id'] = afterPhotoId.toString();
    }

    final uri = Uri.parse('$baseUrl/photo/venues/$venueId').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final photosList = responseData['photos'] as List;
      return {
        'photos': photosList.map((photo) => Photo.fromJson(photo)).toList(),
        'has_more': responseData['has_more'] ?? false,
        'next_cursor': responseData['next_cursor'],
      };
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to fetch venue photos: ${errorBody['detail']}');
    }
  }

  // Get photos for a user (with pagination) - public endpoint
  Future<Map<String, dynamic>> getUserPhotos(int userId, {int? afterPhotoId, int limit = 20}) async {
    final Map<String, String> queryParams = {
      'limit': limit.toString(),
    };

    if (afterPhotoId != null) {
      queryParams['after_photo_id'] = afterPhotoId.toString();
    }

    final uri = Uri.parse('$baseUrl/photo/users/$userId').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final photosList = responseData['photos'] as List;
      return {
        'photos': photosList.map((photo) => Photo.fromJson(photo)).toList(),
        'has_more': responseData['has_more'] ?? false,
        'next_cursor': responseData['next_cursor'],
      };
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to fetch user photos: ${errorBody['detail']}');
    }
  }

  // Upload a photo - requires auth
  Future<Photo> uploadPhoto({
    required File imageFile,
    required int venueId,
    String? caption,
  }) async {
    // Get auth headers from ApiService
    final authHeaders = await _apiService.getAuthHeaders();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/photo/upload'),
    );

    // Add auth headers
    request.headers.addAll(authHeaders);

    // Add file
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    // Add form fields
    request.fields['venue_id'] = venueId.toString();
    if (caption != null && caption.isNotEmpty) {
      request.fields['caption'] = caption;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final photoData = jsonDecode(response.body);
      return Photo.fromJson(photoData);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to upload photo: ${errorBody['detail']}');
    }
  }

  // Delete a photo - requires auth
  Future<void> deletePhoto(int photoId) async {
    final uri = Uri.parse('$baseUrl/photo/delete-photo').replace(
      queryParameters: {'photo_id': photoId.toString()},
    );

    final response = await _apiService.delete(uri.toString());

    if (response.statusCode != 204) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to delete photo: ${errorBody['detail']}');
    }
  }

  // Update photo caption - requires auth
  Future<void> updatePhotoCaption(int photoId, String newCaption) async {
    final uri = Uri.parse('$baseUrl/photo/update-photo').replace(
      queryParameters: {
        'photo_id': photoId.toString(),
        'new_caption': newCaption,
      },
    );

    final response = await _apiService.put(uri.toString());

    if (response.statusCode != 204) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to update photo caption: ${errorBody['detail']}');
    }
  }
}
