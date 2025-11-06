import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  //auth API endpoints
  static const String _registerEndpoint = '/auth/register';
  static const String _loginEndpoint = '/auth/login';
  static const String _healthEndpoint = '/health';

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
