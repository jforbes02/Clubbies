import 'dart:convert';

// ============================================================================
// Request Models
// ============================================================================

/// Model for user registration request
/// Backend expects: username, email, password, age (int >= 16)
class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final int age;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.age,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'age': age,
    };
  }

  // Validation helpers
  String? validateUsername() {
    if (username.length < 4 || username.length > 40) {
      return 'Username must be between 4 and 40 characters';
    }
    return null;
  }

  String? validatePassword() {
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateAge() {
    if (age < 16) {
      return 'You must be at least 16 years old';
    }
    return null;
  }
}

/// Model for user login request
/// Backend uses OAuth2PasswordRequestForm format (username & password)
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  /// Converts to OAuth2 form format (form-data, not JSON)
  Map<String, String> toFormData() {
    return {
      'username': username,
      'password': password,
    };
  }

  /// For JSON-based login if backend supports it
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

// ============================================================================
// Response Models
// ============================================================================

/// Model for authentication token response
/// Matches backend Token model: access_token, refresh_token, token_type
class AuthToken {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
    };
  }

  /// Returns the full authorization header value
  String get authorizationHeader => '$tokenType $accessToken';

  /// Check if token is expired by decoding JWT (basic check)
  bool get isExpired {
    try {
      final parts = accessToken.split('.');
      if (parts.length != 3) return true;

      // Decode the payload (second part)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      if (payloadMap.containsKey('exp')) {
        final exp = payloadMap['exp'] as int;
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        return DateTime.now().isAfter(expiryDate);
      }
      return false;
    } catch (e) {
      return true;
    }
  }

  /// Extract user ID from JWT token payload
  String? get userId {
    try {
      final parts = accessToken.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      return payloadMap['sub'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Get token expiration date
  DateTime? get expiryDate {
    try {
      final parts = accessToken.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      if (payloadMap.containsKey('exp')) {
        final exp = payloadMap['exp'] as int;
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

// ============================================================================
// Error Models
// ============================================================================

/// Model for API error responses
class AuthError {
  final String message;
  final int? statusCode;
  final String? detail;

  AuthError({
    required this.message,
    this.statusCode,
    this.detail,
  });

  factory AuthError.fromJson(Map<String, dynamic> json) {
    return AuthError(
      message: json['message'] as String? ?? 'An error occurred',
      statusCode: json['status_code'] as int?,
      detail: json['detail'] as String?,
    );
  }

  factory AuthError.fromException(Exception e, {int? statusCode}) {
    return AuthError(
      message: e.toString(),
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    if (detail != null) return detail!;
    return message;
  }
}

/// Result wrapper for auth operations
class AuthResult<T> {
  final T? data;
  final AuthError? error;

  bool get isSuccess => error == null && data != null;
  bool get isError => error != null;

  AuthResult.success(this.data) : error = null;
  AuthResult.failure(this.error) : data = null;
}
