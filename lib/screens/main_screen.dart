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
          // TOP BAR
          // Outside SafeArea
          // =========================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 16,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer.withValues(
                  alpha: 0.8,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "ProxiLeash",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    screenTitles[currentScreen],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =========================
          // SAFE AREA CONTENT
          // =========================
          SafeArea(
            child: Column(
              children: [
                // Space for the top bar
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),

                SizedBox(height: 32),

                // Screen
                Expanded(child: screens[currentScreen]),

                // Navigation
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
