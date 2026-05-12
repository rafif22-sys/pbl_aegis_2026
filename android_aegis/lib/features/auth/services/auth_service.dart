import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:android_aegis/core/services/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  /// POST /api/auth/login
  /// Response: { token, user }
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/auth/login'),
      headers: ApiClient.headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  /// GET /api/auth/me
  /// Response: { user }
  static Future<UserModel> getMe(String token) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/auth/me'),
      headers: ApiClient.headers(token: token),
    );

    final json = jsonDecode(response.body);

    if (json['user'] == null) {
      throw Exception('Token tidak valid');
    }

    return UserModel.fromJson(json['user']);
  }

  /// POST /api/auth/logout
  static Future<void> logout(String token) async {
    await http.post(
      Uri.parse('${ApiClient.baseUrl}/auth/logout'),
      headers: ApiClient.headers(token: token),
    );
  }
}