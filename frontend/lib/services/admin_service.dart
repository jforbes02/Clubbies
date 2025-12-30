import 'dart:convert';
import 'api_service.dart';
import '../config/environment.dart';
import '../models/venue.dart';
import '../models/user.dart';

class AdminService {
  static String get baseUrl => Environment.apiBaseUrl;
  final ApiService _apiService = ApiService();

  // Create a new venue
  Future<Venue> createVenue({
    required String venueName,
    required String address,
    required String hours,
    required List<String> venueType,
    required int ageReq,
    required String capacity,
    required int price,
    String? description,
  }) async {
    final body = jsonEncode({
      'venue_name': venueName,
      'address': address,
      'hours': hours,
      'venue_type': venueType,
      'age_req': ageReq,
      'capacity': capacity,
      'price': price,
      if (description != null && description.isNotEmpty) 'description': description,
    });

    final response = await _apiService.post('$baseUrl/venues/', body: body);

    if (response.statusCode == 201) {
      final venueData = jsonDecode(response.body);
      return Venue.fromJson(venueData);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to create venue: ${errorBody['detail']}');
    }
  }

  // Delete a venue
  Future<void> deleteVenue(int venueId) async {
    final response = await _apiService.delete('$baseUrl/venues/$venueId');

    if (response.statusCode != 204 && response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to delete venue: ${errorBody['detail']}');
    }
  }

  // Delete a review
  Future<void> deleteReview(int reviewId) async {
    final response = await _apiService.delete('$baseUrl/reviews/$reviewId');

    if (response.statusCode != 204 && response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to delete review: ${errorBody['detail']}');
    }
  }

  // Delete a photo
  Future<void> deletePhoto(int photoId) async {
    final uri = '$baseUrl/photo/delete-photo?photo_id=$photoId';
    final response = await _apiService.delete(uri);

    if (response.statusCode != 204 && response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to delete photo: ${errorBody['detail']}');
    }
  }

  // User Management

  // Get all users
  Future<List<User>> getAllUsers({int limit = 100}) async {
    final response = await _apiService.get('$baseUrl/users/admin/all?limit=$limit');

    if (response.statusCode == 200) {
      final List<dynamic> usersData = jsonDecode(response.body);
      return usersData.map((user) => User.fromJson(user)).toList();
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to fetch users: ${errorBody['detail']}');
    }
  }

  // Delete a user
  Future<void> deleteUser(int userId) async {
    final response = await _apiService.delete('$baseUrl/users/admin/$userId');

    if (response.statusCode != 204 && response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to delete user: ${errorBody['detail']}');
    }
  }

  // Update user role
  Future<void> updateUserRole(int userId, String role) async {
    final body = jsonEncode({'role': role});
    final response = await _apiService.put('$baseUrl/users/admin/$userId/role', body: body);

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to update user role: ${errorBody['detail']}');
    }
  }
}
