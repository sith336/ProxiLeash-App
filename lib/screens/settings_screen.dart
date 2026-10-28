import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../widgets/glass_panel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _savingAlerts = false;

  Future<void> _selectAppearance(ThemeMode currentMode) async {
    final selectedMode = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Choose appearance',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              for (final mode in ThemeMode.values)
                ListTile(
                  selected: mode == currentMode,
                  title: Text(_themeModeLabel(mode)),
                  subtitle: Text(_themeModeDescription(mode)),
                  trailing: mode == currentMode
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(mode),
                ),
            ],
          ),
        ),
      ),
    );
    if (selectedMode == null || !mounted) return;

    try {
      await context.read<AppSettings>().setThemeMode(selectedMode);
    } catch (error) {
      _showError('Could not save your appearance preference: $error');
    }
  }

  Future<void> _saveAlertPreferences({
    required bool enabled,
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) async {
    if (_savingAlerts) return;
    setState(() => _savingAlerts = true);

    try {
      await context.read<AppSettings>().setAlertPreferences(
        enabled: enabled,
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
      );
    } catch (error) {
      _showError('Could not save your alert preferences: $error');
    } finally {
      if (mounted) setState(() => _savingAlerts = false);
    }
  }

  Future<void> _openSystemSettings() async {
    final opened = await openAppSettings();
    if (!opened && mounted) {
      _showError('Could not open system settings.');
    }
  }

  Future<void> _resetSettings() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset settings?'),
        content: const Text(
          'Restore system appearance and turn distance alerts, sound, and '
          'vibration back on.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (shouldReset != true || !mounted) return;

    try {
      await context.read<AppSettings>().resetToDefaults();
    } catch (error) {
      _showError('Could not reset settings: $error');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.bluetooth_searching_rounded),
        title: const Text('Connection tips'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HelpStep(
                number: '1',
                text: 'Keep Bluetooth on and your ProxiLeash device powered.',
              ),
              _HelpStep(
                number: '2',
                text: 'Open the Device tab, scan, then select your device.',
              ),
              _HelpStep(
                number: '3',
                text:
                    'Keep the app allowed to run and send notifications for '
                    'background distance alerts.',
              ),
              _HelpStep(
                number: '4',
                text:
                    'If the connection drops, move closer and reconnect. '
                    'Walls and other obstacles can weaken Bluetooth.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).pop();
              _openSystemSettings();
            },
            child: const Text('App permissions'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'ProxiLeash',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.bluetooth_connected_rounded,
        color: Theme.of(context).colorScheme.primary,
        size: 36,
      ),
      children: const [
        Text(
          'A simple Bluetooth proximity monitor. Connect your device to watch '
          'signal quality and receive distance alerts.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<AppSettings>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Make it yours', style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Personalize how ProxiLeash looks and keeps you informed.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _SectionHeading(title: 'APPEARANCE'),
          GlassPanel(
            padding: EdgeInsets.zero,
            borderRadius: 20,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: _SettingIcon(
                icon: Icons.palette_outlined,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Theme'),
              subtitle: Text(_themeModeLabel(settings.themeMode)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _selectAppearance(settings.themeMode),
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeading(title: 'DISTANCE ALERTS'),
          GlassPanel(
            padding: EdgeInsets.zero,
            borderRadius: 20,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  secondary: _SettingIcon(
                    icon: Icons.notifications_active_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Distance alerts'),
                  subtitle: const Text(
                    'Notify when the signal becomes weak or disconnects',
                  ),
                  value: settings.distanceAlertsEnabled,
                  onChanged: _savingAlerts
                      ? null
                      : (enabled) => _saveAlertPreferences(
                          enabled: enabled,
                          soundEnabled: settings.alarmSoundEnabled,
                          vibrationEnabled: settings.alarmVibrationEnabled,
                        ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile.adaptive(
                  secondary: _SettingIcon(
                    icon: Icons.volume_up_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Alarm sound'),
                  subtitle: const Text('Play a sound with distance alerts'),
                  value: settings.alarmSoundEnabled,
                  onChanged: _savingAlerts || !settings.distanceAlertsEnabled
                      ? null
                      : (enabled) => _saveAlertPreferences(
                          enabled: settings.distanceAlertsEnabled,
                          soundEnabled: enabled,
                          vibrationEnabled: settings.alarmVibrationEnabled,
                        ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile.adaptive(
                  secondary: _SettingIcon(
                    icon: Icons.vibration_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Vibration'),
                  subtitle: const Text(
                    'Use a repeating vibration pattern on supported devices',
                  ),
                  value: settings.alarmVibrationEnabled,
                  onChanged: _savingAlerts || !settings.distanceAlertsEnabled
                      ? null
                      : (enabled) => _saveAlertPreferences(
                          enabled: settings.distanceAlertsEnabled,
                          soundEnabled: settings.alarmSoundEnabled,
                          vibrationEnabled: enabled,
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Your phone’s notification settings can override sound and '
              'vibration.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeading(title: 'SUPPORT'),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & connection tips',
            subtitle: 'Troubleshoot scanning and connection issues',
            onTap: _showHelp,
          ),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'About ProxiLeash',
            subtitle: 'Bluetooth monitoring, made simple',
            onTap: _showAbout,
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: _resetSettings,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Reset all settings'),
          ),
        ],
      ),
    );
  }

  static String _themeModeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'Follow device settings',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  static String _themeModeDescription(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'Automatically match your device',
    ThemeMode.light => 'Use the light color theme',
    ThemeMode.dark => 'Use the dark color theme',
  };
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      padding: EdgeInsets.zero,
      borderRadius: 20,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        leading: _SettingIcon(icon: icon, color: theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _HelpStep extends StatelessWidget {
  const _HelpStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.10),
            foregroundColor: theme.colorScheme.primary,
            child: Text(
              number,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
