import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart'
    hide NotificationVisibility;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/too_far_screen.dart';

class AlarmNotificationService {
  AlarmNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String _distanceAlertsKey = 'settings_distance_alerts';
  static const String _alarmSoundKey = 'settings_alarm_sound';
  static const String _alarmVibrationKey = 'settings_alarm_vibration';
  static const String _payload = 'too_far';
  static bool _alertsEnabled = true;
  static bool _soundEnabled = true;
  static bool _vibrationEnabled = true;
  static bool _isInitialized = false;
  static bool get distanceAlertsEnabled => _alertsEnabled;
  static final Int64List _vibrationPattern = Int64List.fromList([
    0,
    700,
    350,
    700,
    350,
    1000,
  ]);

  static Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    _alertsEnabled = preferences.getBool(_distanceAlertsKey) ?? true;
    _soundEnabled = preferences.getBool(_alarmSoundKey) ?? true;
    _vibrationEnabled = preferences.getBool(_alarmVibrationKey) ?? true;

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
    _isInitialized = true;
  }

  static Future<void> setAlertPreferences({
    required bool enabled,
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final savedEnabled = await preferences.setBool(_distanceAlertsKey, enabled);
    final savedSound = await preferences.setBool(_alarmSoundKey, soundEnabled);
    final savedVibration = await preferences.setBool(
      _alarmVibrationKey,
      vibrationEnabled,
    );
    if (!savedEnabled || !savedSound || !savedVibration) {
      throw StateError('Unable to save the distance alert preferences.');
    }

    applyAlertPreferences(
      enabled: enabled,
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
    );
    if (!enabled) {
      await clearTooFarAlert();
    }
    if (Platform.isAndroid && await FlutterForegroundTask.isRunningService) {
      FlutterForegroundTask.sendDataToTask({
        'action': 'alert_preferences',
        'enabled': enabled,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
      });
    }
  }

  static void applyAlertPreferences({
    required bool enabled,
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) {
    _alertsEnabled = enabled;
    _soundEnabled = soundEnabled;
    _vibrationEnabled = vibrationEnabled;
  }

  static Future<bool> wasLaunchedByAlarm() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp == true &&
        details?.notificationResponse?.payload == _payload;
  }

  static Future<void> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      await android.requestNotificationsPermission();
      await android.requestFullScreenIntentPermission();
      if (await android.areNotificationsEnabled() == false) {
        throw StateError(
          'Allow ProxiLeash notifications to receive distance alerts.',
        );
      }
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> showTooFarAlert({required String deviceName}) async {
    await _showAlert(
      title: 'ProxiLeash: weak signal',
      body:
          '$deviceName has a weak Bluetooth signal. Move closer to restore '
          'the connection.',
    );
  }

  static Future<void> showConnectionLostAlert({
    required String deviceName,
    required bool weakSignal,
  }) async {
    await _showAlert(
      title: 'ProxiLeash: connection lost',
      body: weakSignal
          ? '$deviceName disconnected after its Bluetooth signal became weak. '
                'Move closer and reconnect.'
          : '$deviceName lost its Bluetooth connection. Move closer and '
                'reconnect.',
    );
  }

  static Future<void> _showAlert({
    required String title,
    required String body,
  }) async {
    if (!_alertsEnabled) return;

    final channelId =
        'distance_alarm_${_soundEnabled ? 'sound' : 'silent'}_'
        '${_vibrationEnabled ? 'vibrate' : 'still'}';
    await _plugin.show(
      id: 1,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Distance alarm',
          channelDescription:
              'Alerts when the monitored ProxiLeash device has a weak signal '
              'or loses connection.',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          visibility: NotificationVisibility.public,
          playSound: _soundEnabled,
          enableVibration: _vibrationEnabled,
          vibrationPattern: _vibrationEnabled ? _vibrationPattern : null,
          autoCancel: false,
          ongoing: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: _soundEnabled,
        ),
      ),
      payload: _payload,
    );
  }

  static Future<void> clearTooFarAlert() async {
    if (!_isInitialized) return;
    await _plugin.cancel(id: 1);
  }

  static void _onNotificationResponse(NotificationResponse response) {
    if (response.payload != _payload) return;

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    navigator.push(
      MaterialPageRoute<void>(builder: (_) => const TooFarScreen()),
    );
  }
}
