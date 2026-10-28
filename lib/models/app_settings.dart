import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/alarm_notification_service.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._({
    required this.themeMode,
    required this.distanceAlertsEnabled,
    required this.alarmSoundEnabled,
    required this.alarmVibrationEnabled,
  });

  static const _themeModeKey = 'settings_theme_mode';
  static const _distanceAlertsKey = 'settings_distance_alerts';
  static const _alarmSoundKey = 'settings_alarm_sound';
  static const _alarmVibrationKey = 'settings_alarm_vibration';

  ThemeMode themeMode;
  bool distanceAlertsEnabled;
  bool alarmSoundEnabled;
  bool alarmVibrationEnabled;

  static Future<AppSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    final themeModeName = preferences.getString(_themeModeKey);
    final themeMode = switch (themeModeName) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final alertsEnabled = preferences.getBool(_distanceAlertsKey) ?? true;
    final soundEnabled = preferences.getBool(_alarmSoundKey) ?? true;
    final vibrationEnabled = preferences.getBool(_alarmVibrationKey) ?? true;

    await AlarmNotificationService.setAlertPreferences(
      enabled: alertsEnabled,
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
    );

    return AppSettings._(
      themeMode: themeMode,
      distanceAlertsEnabled: alertsEnabled,
      alarmSoundEnabled: soundEnabled,
      alarmVibrationEnabled: vibrationEnabled,
    );
  }

  Future<void> setThemeMode(ThemeMode value) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_themeModeKey, value.name);
    if (!saved) {
      throw StateError('Unable to save the appearance preference.');
    }

    themeMode = value;
    notifyListeners();
  }

  Future<void> setAlertPreferences({
    required bool enabled,
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) async {
    await AlarmNotificationService.setAlertPreferences(
      enabled: enabled,
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
    );

    distanceAlertsEnabled = enabled;
    alarmSoundEnabled = soundEnabled;
    alarmVibrationEnabled = vibrationEnabled;
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    final preferences = await SharedPreferences.getInstance();
    final removedThemeMode = await preferences.remove(_themeModeKey);
    if (!removedThemeMode) {
      throw StateError('Unable to reset the appearance preference.');
    }

    await setAlertPreferences(
      enabled: true,
      soundEnabled: true,
      vibrationEnabled: true,
    );
    themeMode = ThemeMode.system;
    notifyListeners();
  }
}
