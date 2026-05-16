import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/sos/providers/sos_provider.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/petugas/screens/petugas_home_screen.dart';
import 'features/supervisor/screens/supervisor_home_screen.dart';
import 'features/warga/screens/warga_home_screen.dart';

void main() async {
  // Diperlukan sebelum memanggil SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SosProvider()),
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
    // checkAuthStatus sekarang hanya baca cache lokal (cepat),
    // server sync jalan di background — tidak memperlambat splash
    await Provider.of<AuthProvider>(context, listen: false).checkAuthStatus();
    if (mounted) setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: Color(0xFF041221),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isLoggedIn) return const LoginScreen();

        switch (auth.user!.role) {
          case 'petugas':
            return const PetugasHomeScreen();
          case 'supervisor':
            return const SupervisorHomeScreen();
          case 'warga':
            return const WargaHomeScreen();
          default:
            return const LoginScreen();
        }
      },
    );
  }
}