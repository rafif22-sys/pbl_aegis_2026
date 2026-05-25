import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/petugas/providers/tamu_provider.dart';
import 'features/sos/providers/sos_provider.dart';
import 'features/sos/widgets/sos_loading_screen.dart';  

import 'core/routes/app_routes.dart';
import 'core/services/navigation_service.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/petugas/screens/petugas_home_screen.dart';
import 'features/supervisor/screens/home_page.dart';
import 'features/warga/screens/warga_home_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  await NotificationService.initialize();

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
        ChangeNotifierProvider(create: (_) => TamuProvider()),
      ],
      child: MaterialApp(
        title: 'AEGIS',
        debugShowCheckedModeBanner: false,
        navigatorKey: NavigationService.navigatorKey,
        routes: AppRoutes.routes,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id', 'ID'),
          Locale('en', 'US'),
        ],
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
  String? _pendingSosId;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _pendingSosId = initial.data['sos_id'];
    }

    await Provider.of<AuthProvider>(context, listen: false).checkAuthStatus();

    if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: Color(0xFF041221),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isLoggedIn) return const LoginScreen();

        if (_pendingSosId != null) {
          final sosId = _pendingSosId!;

          return SosLoadingScreen(      // ← gunakan widget terpisah
            sosId: sosId,
            token: auth.token!,
            role: auth.user!.role,
            onDone: () {
              if (mounted) {
                setState(() {
                  _pendingSosId = null;
                });
              }
            },
          );
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