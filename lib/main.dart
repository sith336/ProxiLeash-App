import 'package:flutter/material.dart';

import 'screens/loading_screen.dart';
import 'package:provider/provider.dart';
import 'models/app_state.dart';

import 'constants/themes.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AppState(), child: const MyApp()),
  );
  const MyApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ProxiLeash',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // temp
      themeMode: ThemeMode.light, // Change this to ThemeMode.dark for dark mode

      home: const LoadingScreen(),
    );
  }
}
