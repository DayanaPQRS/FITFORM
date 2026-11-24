class AppConstants {
  // Google OAuth 2.0 Android Client ID dari Google Cloud Console
  static const String defaultGoogleClientId = 'YOUR_GOOGLE_ANDROID_CLIENT_ID.apps.googleusercontent.com';

  // Google OAuth 2.0 Web Client ID & Secret (digunakan di Laravel Web Admin & Desktop Loopback)
  static const String webGoogleClientId = 'YOUR_GOOGLE_WEB_CLIENT_ID.apps.googleusercontent.com';
  static const String defaultGoogleClientSecret = 'YOUR_GOOGLE_CLIENT_SECRET';

  // Reversed Client ID scheme yang digunakan Google OAuth untuk Android
  static const String redirectUri = 'com.googleusercontent.apps.YOUR_GOOGLE_ANDROID_CLIENT_ID:/oauth2redirect';

  // OIDC Endpoints untuk Google
  static const String authorizationEndpoint = 'https://accounts.google.com/o/oauth2/v2/auth';
  static const String tokenEndpoint = 'https://oauth2.googleapis.com/token';

  // Backend Laravel API URL
  static const String defaultBackendBaseUrl = 'http://localhost:8000';
}
