import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// how to open, put things, and take things out of the storage service
class StorageService{
  //(singleton storage service)
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Where the actual storage is
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';

  // Function that is saving the tokens
  Future<void> saveToken(String token, String tokenType) async {
    await _storage.write(key: _tokenKey, value: token); //e.g. "abc123"
    await _storage.write(key: _tokenTypeKey, value: tokenType); // e.g. "Bearer"
  }

  // Function that saves both access and refresh tokens
  Future<void> saveTokens(String accessToken, String refreshToken, String tokenType) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _tokenTypeKey, value: tokenType);
  }

  //Function that retrieves the token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  //Function that retrieves the refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<String?> getTokenType() async {
    return await _storage.read(key: _tokenTypeKey);
  }

  // Function that deletes the tokens (Logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenTypeKey);
  }

  // how do we know this token is even there?
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

