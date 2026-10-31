import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/storage/secure_storage.dart';

/// Top-level background message handler required by Firebase Messaging.
/// Must be outside of any class and annotated with @pragma('vm:entry-point').
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('Handling background FCM message: ${message.messageId}');
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// High importance notification channel for Android heads-up alerts
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'ainara_high_importance_channel',
    'AiNARA Notifikasi',
    description: 'Kanal notifikasi penting untuk laporan belajar, apresiasi, dan perlindungan siswa.',
    importance: Importance.max,
    playSound: true,
  );

  /// Initializes Firebase Core, Firebase Messaging, and Local Notifications.
  /// Gracefully catches errors if run in headless test environments.
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize Firebase Core
      await Firebase.initializeApp();

      // 2. Register background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Initialize Flutter Local Notifications for foreground notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
      const darwinSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Local notification clicked: ${response.payload}');
        },
      );

      // 4. Create Android Notification Channel
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      final messaging = FirebaseMessaging.instance;

      // 5. Request permissions (Android 13+ and iOS)
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('FCM Authorization status: ${settings.authorizationStatus}');

      // 6. Foreground presentation options on iOS
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 7. Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground FCM message received: ${message.messageId}');
        _showForegroundNotification(message);
      });

      // 8. Notification opened app listener
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('App opened from notification: ${message.data}');
      });

      // 9. Initial message (when app opened from terminated state)
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App launched from terminated state via notification: ${initialMessage.data}');
      }

      // 10. Token refresh listener
      messaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        syncTokenWithBackend(newToken);
      });

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully.');
    } catch (e) {
      debugPrint('NotificationService initialization skipped/failed: $e');
    }
  }

  /// Displays a local heads-up notification when a message arrives while app is in foreground.
  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final title = notification?.title ?? message.data['title'] ?? 'AiNARA';
      final body = notification?.body ?? message.data['body'] ?? message.data['message'] ?? '';

      if (title.isEmpty && body.isEmpty) return;

      await _localNotifications.show(
        notification.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: notification?.android?.smallIcon ?? '@mipmap/launcher_icon',
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  /// Retrieves the current FCM device registration token.
  static Future<String?> getToken() async {
    if (!_isInitialized) return null;
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }

  /// Synchronizes the device FCM token with the backend.
  /// Requires user to be authenticated.
  static Future<bool> syncTokenWithBackend([String? token]) async {
    try {
      final authToken = await SecureStorage.getToken();
      if (authToken == null || authToken.trim().isEmpty) {
        return false;
      }

      final fcmToken = token ?? await getToken();
      if (fcmToken == null || fcmToken.trim().isEmpty) {
        debugPrint('No FCM token available to sync.');
        return false;
      }

      debugPrint('Syncing FCM token to backend: $fcmToken');
      final response = await ApiClient.post(
        ApiEndpoints.deviceToken,
        {
          'fcm_token': fcmToken,
          'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
          'device_name': 'AiNARA Mobile App',
        },
        withAuth: true,
      );

      if (response.success) {
        debugPrint('FCM token successfully registered on backend.');
        return true;
      } else {
        debugPrint('Failed to sync FCM token with backend: ${response.message}');
        return false;
      }
    } catch (e) {
      debugPrint('Error syncing FCM token with backend: $e');
      return false;
    }
  }

  /// Unregisters the current device token from the backend (used before logout).
  static Future<void> unregisterToken() async {
    try {
      final authToken = await SecureStorage.getToken();
      if (authToken == null) return;

      final fcmToken = await getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await ApiClient.delete(
          ApiEndpoints.deviceToken,
          {'fcm_token': fcmToken},
          withAuth: true,
        );
        debugPrint('FCM token unregistered from backend.');
      }
    } catch (e) {
      debugPrint('Error unregistering FCM token from backend: $e');
    }
  }

  /// Explicitly requests notification permissions and syncs token with backend.
  /// Returns a map with status details useful for UI feedback.
  static Future<Map<String, dynamic>> testAndSyncToken() async {
    try {
      if (!_isInitialized) {
        await init();
      }
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await messaging.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token FCM tidak dapat diperoleh dari Google Play Services.',
          'permission': settings.authorizationStatus.name,
        };
      }

      final synced = await syncTokenWithBackend(token);
      return {
        'success': synced,
        'token': token,
        'permission': settings.authorizationStatus.name,
        'message': synced
            ? 'Token notifikasi berhasil didaftarkan ke server!'
            : 'Gagal mengirim token ke server backend.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}
