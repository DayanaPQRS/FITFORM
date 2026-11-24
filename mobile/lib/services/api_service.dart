import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/exercise_model.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService _authService = AuthService();

  /// Mengambil daftar latihan dari backend Laravel (/api/exercises)
  /// Jika backend offline atau gagal, mengembalikan fallback daftar latihan bawaan
  Future<List<ExerciseModel>> getExercises() async {
    try {
      final baseUrl = await _authService.getBackendUrl();
      final token = await _authService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/exercises'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final dynamic rawData = body['data'];
        List items = [];

        if (rawData is List) {
          items = rawData;
        } else if (rawData is Map && rawData['data'] is List) {
          items = rawData['data'];
        }

        if (items.isNotEmpty) {
          return items.map((e) => ExerciseModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('ApiService getExercises warning: $e');
    }

    // Fallback jika backend belum aktif
    return ExerciseModel.defaultExercises;
  }

  /// Mengirim payload sesi latihan lengkap beserta repetisinya (Atomic Transaction)
  /// ke endpoint Laravel POST /api/workout-sessions
  Future<Map<String, dynamic>> saveWorkoutSession(Map<String, dynamic> sessionPayload) async {
    final baseUrl = await _authService.getBackendUrl();
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('Sesi login kedaluwarsa. Silakan login kembali.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/workout-sessions'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(sessionPayload),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      String errorMessage = 'Gagal menyimpan sesi latihan (${response.statusCode})';
      try {
        final errorJson = jsonDecode(response.body);
        if (errorJson['message'] != null) {
          errorMessage = errorJson['message'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  /// Mengambil riwayat sesi latihan pengguna (GET /api/workout-sessions)
  Future<List<Map<String, dynamic>>> getWorkoutSessions() async {
    try {
      final baseUrl = await _authService.getBackendUrl();
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/api/workout-sessions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final dynamic raw = body['data'];
        if (raw is Map && raw['data'] is List) {
          return List<Map<String, dynamic>>.from(raw['data']);
        } else if (raw is List) {
          return List<Map<String, dynamic>>.from(raw);
        }
      }
    } catch (e) {
      debugPrint('ApiService getWorkoutSessions error: $e');
    }
    return [];
  }

  /// Mengambil statistik performa latihan (GET /api/workout-sessions/statistics)
  Future<Map<String, dynamic>?> getStatistics() async {
    try {
      final baseUrl = await _authService.getBackendUrl();
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/workout-sessions/statistics'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('ApiService getStatistics error: $e');
    }
    return null;
  }

  /// Mengambil daftar perangkat Smart Dumbbell (GET /api/devices)
  Future<List<Map<String, dynamic>>> getDevices() async {
    try {
      final baseUrl = await _authService.getBackendUrl();
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/api/devices'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final dynamic raw = body['data'];
        if (raw is List) {
          return List<Map<String, dynamic>>.from(raw);
        }
      }
    } catch (e) {
      debugPrint('ApiService getDevices error: $e');
    }
    return [];
  }

  /// Memperbarui profil antropometri pengguna (PUT /api/user/profile)
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    final baseUrl = await _authService.getBackendUrl();
    final token = await _authService.getToken();
    if (token == null) throw Exception('Sesi login kedaluwarsa');

    final response = await http.put(
      Uri.parse('$baseUrl/api/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profileData),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Gagal memperbarui profil: ${response.body}');
    }
  }

  /// Mengubah kata sandi pengguna (PUT /api/user/change-password)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final baseUrl = await _authService.getBackendUrl();
    final token = await _authService.getToken();
    if (token == null) throw Exception('Sesi login kedaluwarsa');

    final response = await http.put(
      Uri.parse('$baseUrl/api/user/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      }),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      String errorMessage = 'Gagal mengubah kata sandi.';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          errorMessage = body['message'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  /// Menghapus akun pengguna secara permanen (DELETE /api/user/account)
  Future<void> deleteAccount() async {
    final baseUrl = await _authService.getBackendUrl();
    final token = await _authService.getToken();
    if (token == null) throw Exception('Sesi login kedaluwarsa');

    final response = await http.delete(
      Uri.parse('$baseUrl/api/user/account'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      String errorMessage = 'Gagal menghapus akun.';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          errorMessage = body['message'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }

    // Bersihkan sesi lokal
    await _authService.logout();
  }
}
