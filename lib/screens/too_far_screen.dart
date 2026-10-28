import 'package:flutter/material.dart';

import 'main_screen.dart';
import '../widgets/background_full.dart';
import '../widgets/glass_panel.dart';

class TooFarScreen extends StatelessWidget {
  const TooFarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassPanel(
                padding: const EdgeInsets.all(28),
                borderRadius: 32,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(
                          context,
                        ).colorScheme.tertiary.withValues(alpha: 0.22),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Your device is too far away',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Move closer to your ProxiLeash device. The sound and '
                      'vibration alert will stop when its signal returns to '
                      'moderate or strong.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute<void>(
                            builder: (_) => const MainScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.bluetooth_searching_rounded),
                      label: const Text('Open device monitor'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
