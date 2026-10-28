import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proxileash/models/app_settings.dart';
import 'package:proxileash/constants/themes.dart';
import 'package:proxileash/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads useful defaults when preferences are unset', () async {
    final settings = await AppSettings.load();

    expect(settings.themeMode, ThemeMode.system);
    expect(settings.distanceAlertsEnabled, isTrue);
    expect(settings.alarmSoundEnabled, isTrue);
    expect(settings.alarmVibrationEnabled, isTrue);
  });

  test('persists appearance and alarm preferences', () async {
    final settings = await AppSettings.load();

    await settings.setThemeMode(ThemeMode.dark);
    await settings.setAlertPreferences(
      enabled: true,
      soundEnabled: false,
      vibrationEnabled: true,
    );

    final restored = await AppSettings.load();
    expect(restored.themeMode, ThemeMode.dark);
    expect(restored.distanceAlertsEnabled, isTrue);
    expect(restored.alarmSoundEnabled, isFalse);
    expect(restored.alarmVibrationEnabled, isTrue);
  });

  testWidgets('settings screen applies theme and alert changes', (
    tester,
  ) async {
    final settings = await AppSettings.load();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: settings,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const Scaffold(body: SettingsScreen()),
        ),
      ),
    );

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark').first);
    await tester.pumpAndSettle();
    expect(settings.themeMode, ThemeMode.dark);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(settings.distanceAlertsEnabled, isFalse);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('settings_distance_alerts'), isFalse);
  });
}
