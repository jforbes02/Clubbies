import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  //auth API endpoints
  static const String _registerEndpoint = '/auth/register';
  static const String _loginEndpoint = '/auth/login';

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
      throw Exception('Failed to register: ${errorBody['detail']}');
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

}
