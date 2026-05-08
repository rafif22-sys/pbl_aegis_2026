import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
// ✅ Sekarang import AuthService, bukan ApiService
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _token != null;

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');

    if (savedToken != null) {
      try {
        // ✅ AuthService.getMe sekarang langsung return UserModel
        _user = await AuthService.getMe(savedToken);
        _token = savedToken;
      } catch (_) {
        // Token tidak valid / expired
        await prefs.remove('token');
      }
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthService.login(email, password);

      if (response['token'] != null) {
        _token = response['token'];
        _user = UserModel.fromJson(response['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
      } else {
        _errorMessage = response['message'] ?? 'Login gagal, coba lagi.';
      }
    } catch (e) {
      _errorMessage = 'Tidak dapat terhubung ke server.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      if (_token != null) await AuthService.logout(_token!);
    } catch (_) {}

    _user = null;
    _token = null;
    _errorMessage = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    notifyListeners();
  }
}