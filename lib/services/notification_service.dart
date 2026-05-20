import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/alert.dart';

// v2 channel IDs — forces fresh channel creation, clearing any stale
// settings from previous installs.
const _channelAlertId = 'nl_alerts_v2';
const _channelAlertLocationId = 'nl_alerts_location_v2';

class NotificationService {
  static final instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  final _idMap = <String, int>{};
  int _nextId = 0;

  int _notificationIdFor(String alertId) =>
      _idMap.putIfAbsent(alertId, () => _nextId++);

  /// Called when the user taps a notification. Receives the alert ID.
  void Function(String alertId)? onNotificationTap;

  Future<void> initialize() async {
    if (kIsWeb) return;

    final settings = InitializationSettings(
      android: const AndroidInitializationSettings('@mipmap/launcher_icon'),
      linux: Platform.isLinux
          ? const LinuxInitializationSettings(defaultActionName: 'Open')
          : null,
    );

    final ok = await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final alertId = response.payload;
        if (alertId != null && alertId.isNotEmpty) {
          debugPrint('[Notifications] tapped, alertId=$alertId');
          onNotificationTap?.call(alertId);
        }
      },
    );
    debugPrint('[Notifications] initialize result: $ok');

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) {
      debugPrint('[Notifications] androidPlugin is null');
      _initialized = true;
      return;
    }

    // Remove old v1 channels so they don't clutter the app's channel list.
    await androidPlugin.deleteNotificationChannel(channelId: 'nl_alerts');
    await androidPlugin.deleteNotificationChannel(channelId: 'nl_alerts_location');

    // Alert without sound but WITH vibration so heads-up is triggered.
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelAlertId,
        'NL-Alerts',
        description: 'Nieuwe NL-Alert meldingen',
        importance: Importance.high,
        playSound: false,
        enableVibration: true,
      ),
    );

    // Alert with sound and vibration for alerts in user's location.
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelAlertLocationId,
        'NL-Alerts in jouw gebied',
        description: 'NL-Alert actief in jouw directe omgeving',
        importance: Importance.max,
        enableVibration: true,
      ),
    );

    _initialized = true;
    debugPrint('[Notifications] initialized, channels created');
  }

  Future<void> requestPermission() async {
    if (!_initialized || kIsWeb) return;
    if (!Platform.isAndroid) return;
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    final enabled = await androidPlugin.areNotificationsEnabled() ?? false;
    debugPrint('[Notifications] notifications enabled: $enabled');
    if (!enabled) {
      final granted = await androidPlugin.requestNotificationsPermission();
      debugPrint('[Notifications] permission granted: $granted');
    }
  }

  Future<void> showAlertNotification(
    Alert alert, {
    required bool withSound,
  }) async {
    debugPrint(
      '[Notifications] showAlertNotification — '
      'initialized=$_initialized withSound=$withSound id=${alert.id}',
    );
    if (!_initialized || kIsWeb) return;

    final notificationId = _notificationIdFor(alert.id);
    final title = withSound ? 'NL-Alert in jouw gebied!' : 'Nieuw NL-Alert';

    NotificationDetails? details;

    if (Platform.isAndroid) {
      details = NotificationDetails(
        android: AndroidNotificationDetails(
          withSound ? _channelAlertLocationId : _channelAlertId,
          withSound ? 'NL-Alerts in jouw gebied' : 'NL-Alerts',
          importance: withSound ? Importance.max : Importance.high,
          priority: Priority.high,
          ticker: title,
          // Vibration on for all alerts so heads-up is triggered even
          // when the sound channel is not used.
          enableVibration: true,
          playSound: withSound,
        ),
      );
    } else if (Platform.isLinux) {
      details = NotificationDetails(
        linux: LinuxNotificationDetails(
          urgency: withSound
              ? LinuxNotificationUrgency.critical
              : LinuxNotificationUrgency.normal,
        ),
      );
    }

    if (details == null) return;

    try {
      await _plugin.show(
        id: notificationId,
        title: title,
        body: alert.title,
        notificationDetails: details,
        payload: alert.id,
      );
      debugPrint('[Notifications] show() sent id=$notificationId');
    } catch (e) {
      debugPrint('[Notifications] show() error: $e');
    }
  }
}
