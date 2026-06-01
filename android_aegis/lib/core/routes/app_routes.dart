import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/petugas/screens/petugas_home_screen.dart';
import '../../features/supervisor/screens/home_page.dart';
import '../../features/warga/screens/warga_home_screen.dart';

class AppRoutes {
  // Nama route
  static const String login      = '/login';
  static const String petugasHome    = '/petugas/home';
  static const String supervisorHome = '/supervisor/home';
  static const String wargaHome      = '/warga/home';

  // Daftar route
  static Map<String, WidgetBuilder> routes = {
    login:          (_) => const LoginScreen(),
    petugasHome:    (_) => const PetugasHomeScreen(),
    supervisorHome: (_) => const SupervisorHomePage(),
    wargaHome:      (_) => const WargaHomeScreen(),
  };
}