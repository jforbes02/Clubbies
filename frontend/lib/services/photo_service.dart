import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/photo.dart';
import 'storage_service.dart';

class PhotoService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  final StorageService _storageService = StorageService();

  // Get photos for a venue (with pagination)
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

  // Get photos for a user (with pagination)
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

  // Upload a photo
  Future<Photo> uploadPhoto({
    required File imageFile,
    required int venueId,
    String? caption,
  }) async {
    final token = await _storageService.getToken();
    final tokenType = await _storageService.getTokenType();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/photo/upload'),
    );

    // Add headers
    request.headers['Authorization'] = '$tokenType $token';

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

  // Delete a photo
  Future<void> deletePhoto(int photoId) async {
    final token = await _storageService.getToken();
    final tokenType = await _storageService.getTokenType();

    final response = await http.delete(
      Uri.parse('$baseUrl/photo/delete-photo').replace(
        queryParameters: {'photo_id': photoId.toString()},
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$tokenType $token',
      },
    );

    if (response.statusCode != 204) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to delete photo: ${errorBody['detail']}');
    }
  }

  // Update photo caption
  Future<void> updatePhotoCaption(int photoId, String newCaption) async {
    final token = await _storageService.getToken();
    final tokenType = await _storageService.getTokenType();

    final response = await http.put(
      Uri.parse('$baseUrl/photo/update-photo').replace(
        queryParameters: {
          'photo_id': photoId.toString(),
          'new_caption': newCaption,
        },
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$tokenType $token',
      },
    );

    if (response.statusCode != 204) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to update photo caption: ${errorBody['detail']}');
    }
  }
}
