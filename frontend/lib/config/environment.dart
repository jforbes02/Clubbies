// Environment configuration for API endpoints
//
// Usage:
// - Development: Uses localhost (127.0.0.1:8000)
// - Production: Uses your deployed Render.com URL
//
// To switch environments, change isDevelopment flag

class Environment {
  // Set to false when building for production/App Store
  static const bool isDevelopment = true;

  // Your production API URL (update this after deploying to Render)
  static const String productionApiUrl = 'https://clubbies-api.onrender.com';

  // Development API URL
  static const String developmentApiUrl = 'http://127.0.0.1:8000';

  // Current API base URL based on environment
  static String get apiBaseUrl {
    return isDevelopment ? developmentApiUrl : productionApiUrl;
  }

  // Helper method to build full URL
  static String buildUrl(String path) {
    // Remove leading slash if present to avoid double slashes
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$apiBaseUrl/$cleanPath';
  }
}
