import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _currentRole = '';
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  String get currentRole => _currentRole;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkCurrentSession();
  }

  Future<void> _checkCurrentSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _isLoggedIn = true;
      await _loadUserData(session.user!.email!);
      notifyListeners();
    }
  }

  Future<void> _loadUserData(String email) async {
    try {
      final user = await UserService().getUserByEmail(email);
      if (user != null) {
        _currentUser = user;
        _currentRole = user.role;
      } else {
        _currentRole = 'warga';
      }
    } catch (e) {
      _currentRole = 'warga';
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _isLoggedIn = true;
        await _loadUserData(email);
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    _isLoggedIn = false;
    _currentRole = '';
    _currentUser = null;
    notifyListeners();
  }
}
