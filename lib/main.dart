import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';

import 'screens/loading_screen.dart';
import 'models/app_state.dart';
import 'models/app_settings.dart';
import 'constants/themes.dart';
import 'screens/too_far_screen.dart';
import 'services/alarm_notification_service.dart';
import 'services/background_ble_task.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  configureBackgroundBleTask();
  if (Platform.isIOS) {
    await FlutterBluePlus.setOptions(restoreState: true);
  }
  await AlarmNotificationService.initialize();
  final initiallyShowAlarm =
      await AlarmNotificationService.wasLaunchedByAlarm();
  final appSettings = await AppSettings.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider.value(value: appSettings),
      ],
      child: MyApp(initiallyShowAlarm: initiallyShowAlarm),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initiallyShowAlarm = false});

  final bool initiallyShowAlarm;

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettings>();

    return MaterialApp(
      navigatorKey: AlarmNotificationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'ProxiLeash',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      themeMode: appSettings.themeMode,

      home: initiallyShowAlarm ? const TooFarScreen() : const LoadingScreen(),
    );
  }
}
