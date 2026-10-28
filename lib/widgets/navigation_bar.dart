import 'package:flutter/material.dart';
import 'glass_panel.dart';

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

    final destinations = [
      (label: 'Home', icon: Icons.home_rounded),
      (label: 'Device', icon: Icons.bluetooth_rounded),
      (label: 'Settings', icon: Icons.tune_rounded),
    ];

    return GlassPanel(
      padding: const EdgeInsets.all(7),
      borderRadius: 22,
      child: Row(
        children: [
          for (var index = 0; index < destinations.length; index++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _NavigationDestination(
                  label: destinations[index].label,
                  icon: destinations[index].icon,
                  selected: currentScreen == index,
                  onTap: () => onScreenChanged(index),
                  theme: theme,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavigationDestination extends StatelessWidget {
  const _NavigationDestination({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final selectedColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;

    return Material(
      color: selected
          ? selectedColor.withValues(alpha: 0.16)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 21,
                color: selected
                    ? selectedColor
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected
                      ? selectedColor
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
