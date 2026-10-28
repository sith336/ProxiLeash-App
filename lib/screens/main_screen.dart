import 'package:flutter/material.dart';
import 'package:proxileash/screens/home_screen.dart';
import 'package:proxileash/widgets/glass_header.dart';

import '../widgets/background_full.dart';
import '../widgets/navigation_bar.dart';
import 'device_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentScreen = 0;

  final List<Widget> screens = [
    const HomeScreen(),
    const DeviceScreen(),
    const SettingsScreen(),
  ];

  final List<String> screenTitles = ['Home', 'Device', 'Settings'];

  void changeScreen(int choice) {
    setState(() {
      currentScreen = choice;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Column(
              children: [
                GlassHeader(
                  title: 'ProxiLeash',
                  subtitle: screenTitles[currentScreen],
                ),
                const SizedBox(height: 14),
                Expanded(child: screens[currentScreen]),
                const SizedBox(height: 10),
                FloatNavigationBar(
                  currentScreen: currentScreen,
                  onScreenChanged: changeScreen,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
