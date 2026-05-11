import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/warga/detail_titik_screen.dart';
import 'screens/warga/riwayat_laporan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dwyfjwwgrtdspgdaifyv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR3eWZqd3dncnRkc3BnZGFpZnl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY4ODA5MDEsImV4cCI6MjA5MjQ1NjkwMX0.bMdpGdBGPmnwHhe_bBp7ybgPnl5nIbbLYiLDF3UhG1g',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aegis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/detail-titik': (context) => const DetailTitikScreen(),
        '/riwayat-laporan': (context) => const RiwayatLaporanScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }

    switch (auth.currentRole) {
      case 'warga':
        return const HomeScreenWarga();
      case 'petugas':
        return const Scaffold(
          body: Center(child: Text('Home Petugas (Coming Soon)')),
        );
      case 'supervisor':
        return const Scaffold(
          body: Center(child: Text('Home Supervisor (Coming Soon)')),
        );
      case 'admin':
        return const Scaffold(
          body: Center(child: Text('Home Admin (Coming Soon)')),
        );
      default:
        return const LoginScreen();
    }
  }
}
