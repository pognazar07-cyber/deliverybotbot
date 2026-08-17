import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'notifications.dart';

/// Real push via Firebase Cloud Messaging — unlike [DmdNotifications], these
/// fire even when the app process isn't running, because the backend sends
/// them and the OS displays the system tray entry itself. When the app is
/// in the foreground, Android/iOS suppress that system entry, so we mirror
/// it through [DmdNotifications.show] via [listenForegroundMessages].
class DmdPushNotifications {
  DmdPushNotifications._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Firebase.initializeApp();
    _initialized = true;
  }

  /// Returns null if permission was denied or a token couldn't be issued —
  /// callers should treat that as "push unavailable" and keep relying on
  /// local notifications/polling instead of surfacing an error.
  static Future<String?> getToken() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  static void onTokenRefresh(void Function(String token) onRefresh) {
    FirebaseMessaging.instance.onTokenRefresh.listen(onRefresh);
  }

  static void listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      DmdNotifications.show(
        title: notification.title ?? '',
        body: notification.body ?? '',
      );
    });
  }
}
