import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/auth.dart';
import 'storage_service.dart';
import '../pages/auth.dart';
import '../config/environment.dart';

class AuthService {
  static String get baseUrl => Environment.apiBaseUrl;

  //auth API endpoints
  static const String _registerEndpoint = '/auth/register';
  static const String _loginEndpoint = '/auth/login';
  static const String _refreshEndpoint = '/auth/refresh';
  static const String _healthEndpoint = '/health';

  // Global navigator key for context-independent navigation
  static GlobalKey<NavigatorState>? navigatorKey;

  // Storage service for token management
  final StorageService _storageService = StorageService();

  // Initialize the auth service with navigator key
  static void initialize(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  // register function
  Future<AuthToken> register({
    required String username,
    required String email,
    required String password,
    required int age,
  }) async {
    //request model
    final registerReq = RegisterRequest(
      username: username,
      email: email,
      password: password,
      age: age,
    );

    final response = await http.post(
      Uri.parse('$baseUrl$_registerEndpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(registerReq.toJson()),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return AuthToken.fromJson(responseData);
    } else {
      final errorBody = jsonDecode(response.body);
      // Handle both simple detail messages and validation error arrays
      String errorMessage = 'Failed to register';
      if (errorBody['detail'] is String) {
        errorMessage = errorBody['detail'];
      } else if (errorBody['detail'] is List) {
        // Format validation errors from FastAPI
        final errors = (errorBody['detail'] as List)
            .map((e) => '${e['loc'].last}: ${e['msg']}')
            .join(', ');
        errorMessage = errors;
      }
      throw Exception(errorMessage);
    }
  }

  Future<AuthToken> login({
    required String username,
    required String password,
  }) async {
    final loginReq = LoginRequest(
      username: username,
      password: password,
    );

    final response = await http.post(
      Uri.parse('$baseUrl$_loginEndpoint'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: loginReq.toFormData(),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return AuthToken.fromJson(responseData);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to login: ${errorBody['detail']}');
  }
  }

  // Refresh access token using refresh token
  Future<void> refreshAccessToken() async {
    final refreshToken = await _storageService.getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await http.post(
      Uri.parse('$baseUrl$_refreshEndpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storageService.saveTokens(
        data['access_token'],
        data['refresh_token'],
        data['token_type'],
      );
    } else {
      // Refresh token expired or invalid - force logout
      await forceLogout();
      throw Exception('Session expired. Please login again.');
    }
  }

  // Force logout and navigate to auth screen
  Future<void> forceLogout() async {
    // Clear tokens
    await _storageService.deleteToken();

    // Navigate to auth screen using global key
    if (navigatorKey?.currentContext != null) {
      navigatorKey!.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  // Check if access token is expired
  Future<bool> isTokenExpired() async {
    final token = await _storageService.getToken();
    if (token == null) return true;

    final authToken = AuthToken(
      accessToken: token,
      refreshToken: '', // Not needed for expiry check
      tokenType: 'Bearer',
    );

    return authToken.isExpired;
  }

  // test API connection
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$_healthEndpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'API connection successful!',
          'status': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': 'API returned status: ${response.statusCode}',
          'status': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed: ${e.toString()}',
        'status': 0,
      };
    }
  }

}
