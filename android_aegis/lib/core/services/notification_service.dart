import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation_service.dart';
import '../../features/sos/repositories/sos_repository.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/petugas/screens/detail_sos_screen.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotif = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channelId = 'sos_channel';
  static const _channelName = 'SOS Alerts';

  static final _vibrationPattern =
      Int64List.fromList([0, 500, 200, 500, 200, 500]);

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotif.initialize(
      const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (details) {
        final sosId = details.payload;
        if (sosId != null) _navigateToDetail(sosId);
      },
    );

    final channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Notifikasi darurat patroli',
      importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('sirine'),
      playSound: true,
      enableVibration: true,
      vibrationPattern: _vibrationPattern,
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Handle tap saat app di background (via FCM langsung)
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      final sosId = msg.data['sos_id'];
      if (sosId != null) _navigateToDetail(sosId);
    });

    FirebaseMessaging.onMessage.listen(showLocalNotification);
  }

  /// Dipanggil dari AuthWrapper setelah app & navigator sudah siap
  static Future<void> handleInitialMessage() async {
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial == null) return;

    final sosId = initial.data['sos_id'];
    if (sosId != null) {
      await _navigateToDetail(sosId);
    }
  }

  static Future<void> _navigateToDetail(String sosId) async {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.token == null) return;

      final repo = SosRepository();
      final sos = await repo.getSOS(
        token: auth.token!,
        sosId: int.parse(sosId),
      );

      NavigationService.navigator?.push(
        MaterialPageRoute(
          builder: (_) => DetailSosScreen(sos: sos),
        ),
      );
    } catch (e) {
      debugPrint('Navigasi ke detail SOS gagal: $e');
    }
  }

  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  static Future<void> showLocalNotification(RemoteMessage msg) async {
    final notif = msg.notification;
    if (notif == null) return;

    final sosId = msg.data['sos_id'];
    final notifId = sosId != null
        ? int.tryParse(sosId) ?? notif.hashCode
        : notif.hashCode;

    await _localNotif.show(
      notifId,
      notif.title,
      notif.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.high,
          icon: 'ic_notif_color',
          color: const Color(0xFF041221),
          sound: const RawResourceAndroidNotificationSound('sirine'),
          playSound: true,
          enableVibration: true,
          vibrationPattern: _vibrationPattern,
          fullScreenIntent: true,
        ),
      ),
      payload: sosId,
    );
  }
}