import 'dart:convert';
import '../models/user.dart';
import 'api_service.dart';

class UserService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String _userEndpoint = '/users';

  final ApiService _apiService = ApiService();

  // Get current user's profile
  Future<User> getCurrentUserProfile() async {
    final response = await _apiService.get('$baseUrl$_userEndpoint/me');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return User.fromJson(responseData);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to load profile: ${errorBody['detail']}');
    }
  }

  // Get another user's profile by user_id
  Future<User> getOtherUserProfile(int userId) async {
    final response = await _apiService.get('$baseUrl$_userEndpoint/$userId');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return User.fromJson(responseData);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to load user profile: ${errorBody['detail']}');
    }
  }

  // Change password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmed,
  }) async {
    final response = await _apiService.put(
      '$baseUrl$_userEndpoint/change-password',
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmed': newPasswordConfirmed,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Invalid current password');
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to change password: ${errorBody['detail']}');
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    final response = await _apiService.delete('$baseUrl$_userEndpoint/delete');

    if (response.statusCode == 204) {
      // Successfully deleted - token will be cleared by logout
      return;
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to delete account: ${errorBody['detail']}');
    }
  }
}
