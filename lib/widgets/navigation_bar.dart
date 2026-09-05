import 'dart:ui';

import 'package:flutter/material.dart';

class FloatNavigationBar extends StatelessWidget {
  final int currentScreen;
  final Function(int) onScreenChanged;

  const FloatNavigationBar({
    super.key,
    required this.currentScreen,
    required this.onScreenChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  onScreenChanged(0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentScreen == 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  foregroundColor: currentScreen == 0
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  elevation: 0,
                ),
                child: const Text("Home"),
              ),

              ElevatedButton(
                onPressed: () {
                  onScreenChanged(1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentScreen == 1
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  foregroundColor: currentScreen == 1
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  elevation: 0,
                ),
                child: const Text("Device"),
              ),

              ElevatedButton(
                onPressed: () {
                  onScreenChanged(2);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentScreen == 2
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  foregroundColor: currentScreen == 2
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  elevation: 0,
                ),
                child: const Text("Settings"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
