import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
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
  bool get isLoggedIn => _token != null && _user != null;

  // ── Dipanggil AuthWrapper saat app dibuka ──────────────
  // Alur:
  //   1. Baca cache lokal → jika ada, langsung authenticated (tidak tunggu server)
  //   2. Sync server di background → jika 401, baru paksa logout
  //      jika server mati (SocketException/Timeout), biarkan pakai cache
  Future<void> checkAuthStatus() async {
    final cache = await AuthService.getLocalSession();

    if (cache.token == null || cache.user == null) {
      // Belum pernah login
      notifyListeners();
      return;
    }

    // Ada cache → langsung set state (UI tidak terblokir)
    _token = cache.token;
    _user = cache.user;
    notifyListeners();

    // Sync ke server secara background (fire-and-forget)
    _syncWithServer(cache.token!);
  }

  Future<void> _syncWithServer(String token) async {
    try {
      final freshUser = await AuthService.getMe(token);
      // Berhasil → perbarui data user (misal foto profil berubah)
      _user = freshUser;
      notifyListeners();
    } on Exception catch (e) {
      if (e.toString().contains('unauthorized')) {
        // Token sudah di-revoke di server (admin paksa logout, dll)
        // → baru paksa user login ulang
        await _forceLogout();
      }
      // SocketException / TimeoutException → server mati, diam saja
    }
  }

  // ── Login normal ───────────────────────────────────────
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthService.login(email, password);

      if (response['token'] != null && response['user'] != null) {
        _token = response['token'] as String;
        _user = UserModel.fromJson(response['user'] as Map<String, dynamic>);

        // Simpan token + data user ke cache lokal
        await AuthService.saveSession(_token!, _user!);
      } else {
        _errorMessage =
            (response['message'] as String?) ?? 'Login gagal, coba lagi.';
      }
    } on SocketException {
      _errorMessage = 'Tidak ada koneksi internet.';
    } on TimeoutException {
      _errorMessage = 'Server tidak merespons.';
    } catch (e) {
      _errorMessage = 'Tidak dapat terhubung ke server.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Logout normal (tombol logout di app) ───────────────
  Future<void> logout() async {
    final token = _token;
    _clearState();
    notifyListeners();
    if (token != null) await AuthService.logout(token);
  }

  // ── Paksa logout karena server balas 401 ───────────────
  Future<void> _forceLogout() async {
    await AuthService.clearSession();
    _clearState();
    notifyListeners();
  }

  void _clearState() {
    _token = null;
    _user = null;
    _errorMessage = null;
  }
}
