import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/sos/providers/sos_provider.dart';        // ← tambah import ini
import 'core/routes/app_routes.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/petugas/screens/petugas_home_screen.dart';
import 'features/supervisor/screens/home_page.dart';
import 'features/warga/screens/warga_home_screen.dart';

void main() {
  runApp(const AegisApp());
}

class AegisApp extends StatelessWidget {
  const AegisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SosProvider()),  // ← tambah ini
      ],
      child: MaterialApp(
        title: 'AEGIS',
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes,
        home: const AuthWrapper(),
      ),
    );
  }
}

// ... sisa kode tidak berubah

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Provider.of<AuthProvider>(context, listen: false).checkAuthStatus();
    if (mounted) setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    // Selama cek token: tampilkan splash screen
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: Color(0xFF041221),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // Setelah cek selesai: langsung return halaman yang tepat
    // tanpa melewati LoginScreen sama sekali
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isLoggedIn) {
          return const LoginScreen();
        }

        switch (auth.user!.role) {
          case 'petugas':
            return const PetugasHomeScreen();
          case 'supervisor':
            return const SupervisorHomePage();
          case 'warga':
            return const WargaHomeScreen();
          default:
            return const LoginScreen();
        }
      },
    );
  }
}