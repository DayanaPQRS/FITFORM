import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../models/user_model.dart';

class AuthService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyToken = 'fitform_sanctum_token';
  static const String _keyUser = 'fitform_user_data';
  static const String _keyBaseUrl = 'fitform_backend_url';
  static const String _keyClientId = 'fitform_google_client_id';

  /// Mendapatkan Base URL backend (menyesuaikan platform Android Emulator vs Desktop)
  Future<String> getBackendUrl() async {
    final customUrl = await _storage.read(key: _keyBaseUrl);
    if (customUrl != null && customUrl.isNotEmpty) {
      return customUrl;
    }

    if (!kIsWeb && Platform.isAndroid) {
      return AppConstants.defaultBackendBaseUrl; // http://10.0.2.2:8000
    }
    return 'http://127.0.0.1:8000';
  }

  Future<void> saveBackendUrl(String url) async {
    await _storage.write(key: _keyBaseUrl, value: url);
  }

  /// Mendapatkan Google Client ID
  Future<String> getGoogleClientId() async {
    final customId = await _storage.read(key: _keyClientId);
    if (customId == null || customId.isEmpty || customId.contains('YOUR_GOOGLE_CLIENT_ID')) {
      return AppConstants.defaultGoogleClientId;
    }
    return customId;
  }

  Future<void> saveGoogleClientId(String clientId) async {
    await _storage.write(key: _keyClientId, value: clientId);
  }

  /// Cek apakah pengguna sudah memiliki sesi login aktif atau baru kembali dari callback web
  Future<UserModel?> checkAndHandleWebCallback() async {
    if (kIsWeb) {
      final uri = Uri.base;
      final params = uri.queryParameters;
      if (params.containsKey('token')) {
        final token = params['token']!;
        final user = UserModel(
          id: int.tryParse(params['id'] ?? '0') ?? 0,
          name: params['name'] ?? 'FitForm User',
          email: params['email'] ?? '',
          role: params['role'] ?? 'user',
          avatar: params['avatar'] != null && params['avatar']!.isNotEmpty ? params['avatar'] : null,
        );
        await _storage.write(key: _keyToken, value: token);
        await _storage.write(key: _keyUser, value: jsonEncode(user.toJson()));
        return user;
      }
    }
    return getCurrentUser();
  }

  /// Cek apakah pengguna sudah memiliki sesi login aktif
  Future<UserModel?> getCurrentUser() async {
    final userDataString = await _storage.read(key: _keyUser);
    if (userDataString == null) return null;
    try {
      final json = jsonDecode(userDataString);
      return UserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Helper PKCE: Generate code_verifier acak
  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  /// Helper PKCE: Generate code_challenge (SHA-256)
  String _generateCodeChallenge(String verifier) {
    final bytes = ascii.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  /// Alur PKCE Desktop (Windows) via System Browser & Local Loopback Listener (RFC 8252)
  Future<String> _loginDesktopPKCE(String clientId) async {
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);

    HttpServer server;
    int port = 8080;
    try {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    } catch (_) {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      port = server.port;
    }

    final redirectUri = 'http://127.0.0.1:$port/callback';
    final authUri = Uri.parse(
      '${AppConstants.authorizationEndpoint}?'
      'client_id=${Uri.encodeComponent(clientId)}&'
      'redirect_uri=${Uri.encodeComponent(redirectUri)}&'
      'response_type=code&'
      'scope=${Uri.encodeComponent("openid profile email")}&'
      'code_challenge=$codeChallenge&'
      'code_challenge_method=S256&'
      'prompt=select_account',
    );

    if (!await launchUrl(authUri, mode: LaunchMode.externalApplication)) {
      await server.close(force: true);
      throw Exception('Gagal membuka browser sistem untuk autentikasi Google.');
    }

    String? authCode;
    String? authError;

    await for (final HttpRequest request in server) {
      if (request.uri.path == '/callback') {
        authCode = request.uri.queryParameters['code'];
        authError = request.uri.queryParameters['error'];

        final response = request.response;
        response.headers.contentType = ContentType.html;
        if (authCode != null) {
          response.write('''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>FitForm SSO</title></head>
<body style="font-family:sans-serif;text-align:center;padding:50px;background:#0F172A;color:white;">
  <h2 style="color:#38BDF8;">Autentikasi Google Berhasil!</h2>
  <p>Sesi login Google aktif di browser. Anda dapat menutup tab ini dan kembali ke FitForm.</p>
</body>
</html>
''');
        } else {
          response.write('''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>FitForm SSO Error</title></head>
<body style="font-family:sans-serif;text-align:center;padding:50px;background:#0F172A;color:white;">
  <h2 style="color:#EF4444;">Autentikasi Dibatalkan</h2>
  <p>${authError ?? 'Terjadi kesalahan saat autentikasi.'}</p>
</body>
</html>
''');
        }
        await response.close();
        break;
      } else {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
      }
    }

    await server.close(force: true);

    if (authCode == null) {
      throw Exception(authError ?? 'Login dibatalkan oleh pengguna.');
    }

    // Tukar Authorization Code + PKCE Verifier dengan Google
    final tokenResponse = await http.post(
      Uri.parse(AppConstants.tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': clientId,
        'client_secret': AppConstants.defaultGoogleClientSecret,
        'code': authCode,
        'code_verifier': codeVerifier,
        'grant_type': 'authorization_code',
        'redirect_uri': redirectUri,
      },
    );

    if (tokenResponse.statusCode != 200) {
      final body = jsonDecode(tokenResponse.body);
      throw Exception(body['error_description'] ?? body['error'] ?? 'Gagal menukar token dengan Google.');
    }

    final tokenData = jsonDecode(tokenResponse.body);
    final idToken = tokenData['id_token'] as String?;
    if (idToken == null) {
      throw Exception('Google tidak mengembalikan id_token.');
    }

    return idToken;
  }

  /// Melakukan Login Google SSO menggunakan Authorization Code Flow + PKCE via System Browser
  Future<UserModel> loginWithGoogle() async {
    final clientId = await getGoogleClientId();
    final baseUrl = await getBackendUrl();

    String idToken;

    // Deteksi Platform:
    // 1. Web: Gunakan redirect browser langsung via Laravel Google OIDC (SSO)
    if (kIsWeb) {
      final origin = Uri.base.origin;
      final authUrl = '$baseUrl/auth/google?from=mobile&return_to=${Uri.encodeComponent(origin)}';
      await launchUrl(Uri.parse(authUrl), webOnlyWindowName: '_self');
      await Future.delayed(const Duration(seconds: 15));
      throw Exception('Mengarahkan ke Google...');
    }

    // 2. Android / iOS: Gunakan flutter_appauth via Chrome Custom Tabs (PKCE)
    // 3. Windows Desktop: Gunakan Loopback PKCE via System Browser (Chrome)
    if (Platform.isAndroid || Platform.isIOS) {
      final authResult = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          AppConstants.redirectUri,
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: AppConstants.authorizationEndpoint,
            tokenEndpoint: AppConstants.tokenEndpoint,
          ),
          scopes: ['openid', 'profile', 'email'],
          promptValues: ['select_account'],
        ),
      );

      if (authResult.idToken == null) {
        throw Exception('Autentikasi Google dibatalkan atau tidak mengembalikan ID Token.');
      }
      idToken = authResult.idToken!;
    } else {
      idToken = await _loginDesktopPKCE(clientId);
    }

    // 2. Kirim ID Token ke Laravel Backend untuk validasi kriptografis & terbit Sanctum Token
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/google-sso'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'id_token': idToken,
      }),
    );

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      final message = errorBody['message'] ?? 'Gagal memverifikasi akun di server.';
      throw Exception(message);
    }

    final data = jsonDecode(response.body);
    final String sanctumToken = data['token'];
    final UserModel user = UserModel.fromJson(data['user']);

    // 3. Simpan sesi lokal
    await _storage.write(key: _keyToken, value: sanctumToken);
    await _storage.write(key: _keyUser, value: jsonEncode(user.toJson()));

    return user;
  }

  /// Registrasi akun baru via REST API Laravel Sanctum
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    double? heightCm,
    double? weightKg,
    String? gender,
  }) async {
    final baseUrl = await getBackendUrl();

    final bodyData = {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (gender != null) 'gender': gender,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(bodyData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = 'Registrasi gagal.';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody['message'] != null) {
          errorMessage = errorBody['message'];
        }
        if (errorBody['errors'] != null && errorBody['errors'] is Map) {
          final errors = errorBody['errors'] as Map;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first.toString();
          }
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }

    final data = jsonDecode(response.body);
    final String? sanctumToken = data['token'];
    final UserModel user = UserModel.fromJson(data['user']);

    if (sanctumToken != null) {
      await _storage.write(key: _keyToken, value: sanctumToken);
      await _storage.write(key: _keyUser, value: jsonEncode(user.toJson()));
      return user;
    } else {
      return await loginWithEmail(email, password);
    }
  }

  /// Login menggunakan Email & Password via REST API Laravel Sanctum
  Future<UserModel> loginWithEmail(String email, String password) async {
    final baseUrl = await getBackendUrl();

    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      String errorMessage = 'Email atau password salah.';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody['message'] != null) {
          errorMessage = errorBody['message'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }

    final data = jsonDecode(response.body);
    final String sanctumToken = data['token'];
    final UserModel user = UserModel.fromJson(data['user']);

    await _storage.write(key: _keyToken, value: sanctumToken);
    await _storage.write(key: _keyUser, value: jsonEncode(user.toJson()));

    return user;
  }

  /// Mendapatkan Sanctum Bearer Token yang tersimpan
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  /// Logout dari aplikasi FitForm Mobile
  Future<void> logout() async {
    final baseUrl = await getBackendUrl();
    final token = await _storage.read(key: _keyToken);

    if (token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/api/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (e) {
        debugPrint('Logout API warning: $e');
      }
    }

    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUser);
  }
}
