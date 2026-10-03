import 'package:flutter/material.dart';
import 'package:proxileash/screens/home_screen.dart';

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

  final List<String> screenTitles = ["Home", "Device", "Settings"];

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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // =========================
          // BACKGROUND
          // =========================
          Opacity(
            opacity: 0.3,
            child: Image.asset('assets/bg.png', fit: BoxFit.cover),
          ),

          // =========================
          // SAFE AREA CONTENT
          // =========================
          SafeArea(
            child: Column(
              children: [
                // =========================
                // HEADER
                // =========================
                Column(
                  children: [
                    Text("ProxiLeash", style: theme.textTheme.headlineLarge),

                    const SizedBox(height: 16),
                    Text(
                      screenTitles[currentScreen],
                      style: theme.textTheme.headlineSmall,
                    ),
                  ],
                ),

                SizedBox(height: 32),

                // =========================
                // SCREEN CONTENT
                // =========================
                Expanded(child: screens[currentScreen]),

                // =========================
                // NAVIGATION BAR
                // =========================
                FloatNavigationBar(
                  currentScreen: currentScreen,
                  onScreenChanged: changeScreen,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
