import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_aegis/core/services/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  static const _keyToken = 'auth_token';
  static const _keyUser  = 'auth_user';

  // ── Simpan sesi ke SharedPreferences ──────────────────
  static Future<void> saveSession(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  // ── Hapus sesi lokal ───────────────────────────────────
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }

  // ── Baca sesi dari cache lokal ─────────────────────────
  static Future<({String? token, UserModel? user})> getLocalSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token    = prefs.getString(_keyToken);
    final userJson = prefs.getString(_keyUser);

    if (token == null || userJson == null) return (token: null, user: null);

    try {
      final user = UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      return (token: token, user: user);
    } catch (_) {
      return (token: null, user: null);
    }
  }

  // ── Login (online) ─────────────────────────────────────
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/auth/login'),
      headers: ApiClient.headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ── GET /api/auth/me ───────────────────────────────────
  // Lempar [SocketException] / [HttpException] jika server mati.
  // Lempar [Exception('unauthorized')] jika server balas 401.
  static Future<UserModel> getMe(String token) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/auth/me'),
      headers: ApiClient.headers(token: token),
    ).timeout(const Duration(seconds: 8)); // biar tidak hang lama

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('unauthorized');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['user'] == null) throw Exception('unauthorized');

    final user = UserModel.fromJson(json['user'] as Map<String, dynamic>);
    // Perbarui cache setiap kali berhasil ambil data terbaru
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    return user;
  }

  // ── Logout ─────────────────────────────────────────────
  static Future<void> logout(String token) async {
    try {
      await http.post(
        Uri.parse('${ApiClient.baseUrl}/auth/logout'),
        headers: ApiClient.headers(token: token),
      ).timeout(const Duration(seconds: 6));
    } catch (_) {
      // Jika server mati, tetap lanjut hapus sesi lokal
    } finally {
      await clearSession();
    }
  }
}