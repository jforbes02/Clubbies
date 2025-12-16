import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'storage_service.dart';

class UserService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String _userEndpoint = '/users';

  final StorageService _storageService = StorageService();

  // Get current user's profile
  Future<User> getCurrentUserProfile() async {
    // Get the stored token
    final token = await _storageService.getToken();
    final tokenType = await _storageService.getTokenType();

    if (token == null || tokenType == null) {
      throw Exception('No authentication token found. Please log in.');
    }

    // The endpoint is /users/{user_id} but the backend uses CurrentUser
    // so we can pass any value or the actual user_id
    // Based on the controller, it ignores the path parameter and uses CurrentUser
    final response = await http.get(
      Uri.parse('$baseUrl$_userEndpoint/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$tokenType $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return User.fromJson(responseData);
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please log in again.');
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to load profile: ${errorBody['detail']}');
    }
  }

  // Change password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmed,
  }) async {
    final token = await _storageService.getToken();
    final tokenType = await _storageService.getTokenType();

    if (token == null || tokenType == null) {
      throw Exception('No authentication token found. Please log in.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl$_userEndpoint/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$tokenType $token',
      },
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
    final token = await _storageService.getToken();
    final tokenType = await _storageService.getTokenType();

    if (token == null || tokenType == null) {
      throw Exception('No authentication token found. Please log in.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl$_userEndpoint/delete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$tokenType $token',
      },
    );

    if (response.statusCode == 204) {
      // Successfully deleted, clear the token
      await _storageService.deleteToken();
      return;
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to delete account: ${errorBody['detail']}');
    }
  }
}
