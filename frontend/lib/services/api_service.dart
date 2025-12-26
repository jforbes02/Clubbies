import 'package:http/http.dart' as http;
import 'dart:async';
import 'storage_service.dart';
import 'auth_service.dart';

/// Centralized HTTP service with automatic token refresh and 401 handling
/// All API requests should go through this service to ensure proper auth handling
class ApiService {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();

  // Mutex to prevent multiple simultaneous refresh attempts
  bool _isRefreshing = false;
  final List<Completer<void>> _refreshQueue = [];

  /// Make a GET request with automatic token management
  Future<http.Response> get(String url, {Map<String, String>? additionalHeaders}) async {
    return _makeAuthenticatedRequest(
      () async {
        final headers = await _buildHeaders(additionalHeaders);
        return http.get(Uri.parse(url), headers: headers);
      },
    );
  }

  /// Make a POST request with automatic token management
  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _makeAuthenticatedRequest(
      () async {
        final finalHeaders = await _buildHeaders(headers);
        return http.post(
          Uri.parse(url),
          headers: finalHeaders,
          body: body,
        );
      },
    );
  }

  /// Make a POST request with form-data (not JSON)
  Future<http.Response> postFormData(
    String url, {
    required Map<String, String> body,
  }) async {
    return _makeAuthenticatedRequest(
      () async {
        final token = await _storageService.getToken();
        final tokenType = await _storageService.getTokenType();

        final headers = <String, String>{
          if (token != null && tokenType != null)
            'Authorization': '$tokenType $token',
        };

        return http.post(
          Uri.parse(url),
          headers: headers,
          body: body,
        );
      },
    );
  }

  /// Make a PUT request with automatic token management
  Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _makeAuthenticatedRequest(
      () async {
        final finalHeaders = await _buildHeaders(headers);
        return http.put(
          Uri.parse(url),
          headers: finalHeaders,
          body: body,
        );
      },
    );
  }

  /// Make a DELETE request with automatic token management
  Future<http.Response> delete(String url, {Map<String, String>? headers}) async {
    return _makeAuthenticatedRequest(
      () async {
        final finalHeaders = await _buildHeaders(headers);
        return http.delete(Uri.parse(url), headers: finalHeaders);
      },
    );
  }

  /// Get authorization headers for manual requests (like multipart)
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await _storageService.getToken();
    final tokenType = await _storageService.getTokenType();

    if (token != null && tokenType != null) {
      return {'Authorization': '$tokenType $token'};
    }
    return {};
  }

  /// Build headers with authorization token
  Future<Map<String, String>> _buildHeaders(Map<String, String>? additionalHeaders) async {
    final token = await _storageService.getToken();
    final tokenType = await _storageService.getTokenType();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && tokenType != null)
        'Authorization': '$tokenType $token',
    };

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Ensure token is valid before making request
  /// Uses mutex pattern to prevent race conditions with multiple simultaneous requests
  Future<void> _ensureValidToken() async {
    // If already refreshing, wait for it to complete
    if (_isRefreshing) {
      final completer = Completer<void>();
      _refreshQueue.add(completer);
      await completer.future;
      return;
    }

    // Check if token is expired
    if (await _authService.isTokenExpired()) {
      _isRefreshing = true;
      try {
        await _authService.refreshAccessToken();
        // Complete all waiting requests
        for (var completer in _refreshQueue) {
          completer.complete();
        }
        _refreshQueue.clear();
      } catch (e) {
        // Fail all waiting requests
        for (var completer in _refreshQueue) {
          completer.completeError(e);
        }
        _refreshQueue.clear();
        rethrow;
      } finally {
        _isRefreshing = false;
      }
    }
  }

  /// Make an authenticated request with automatic token refresh
  /// Implements both proactive (check before request) and reactive (401 handling) strategies
  Future<http.Response> _makeAuthenticatedRequest(
    Future<http.Response> Function() request,
  ) async {
    // PROACTIVE CHECK: Ensure token is valid before making request
    try {
      await _ensureValidToken();
    } catch (e) {
      // If refresh fails, logout and throw
      await _authService.forceLogout();
      throw Exception('Session expired. Please login again.');
    }

    // Make the request
    http.Response response = await request();

    // REACTIVE CHECK: Handle 401 responses
    if (response.statusCode == 401) {
      try {
        // Try to refresh token
        await _authService.refreshAccessToken();

        // Retry the original request with new token
        response = await request();

        // If still 401 after refresh, logout
        if (response.statusCode == 401) {
          await _authService.forceLogout();
          throw Exception('Session expired. Please login again.');
        }
      } catch (e) {
        // Refresh failed - logout
        await _authService.forceLogout();
        throw Exception('Session expired. Please login again.');
      }
    }

    return response;
  }
}
