import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../widgets/circle_container.dart';
import '../widgets/glass_panel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final isConnected = appState.deviceHasConnected;
    final isDisconnected = appState.deviceHasDisconnected;
    final rssi = appState.currentRSSI;

    final statusColor = !isConnected
        ? theme.colorScheme.error
        : rssi == null
        ? theme.colorScheme.tertiary
        : rssi >= -65
        ? const Color(0xFF38856A)
        : rssi >= AppState.weakSignalThreshold
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    final statusTitle = isDisconnected
        ? 'Device disconnected'
        : !isConnected
        ? 'No device connected'
        : rssi == null
        ? 'Connecting to signal'
        : appState.isSignalWeak
        ? 'Device too far'
        : 'You’re all set';

    final statusMessage = isConnected
        ? appState.isSignalWeak
              ? 'Move closer to restore a stable Bluetooth connection.'
              : 'Your device is connected and being monitored.'
        : isDisconnected
        ? 'Reconnect from the Device tab to resume monitoring.'
        : 'Connect your ProxiLeash from the Device tab to get started.';

    final statusIcon = !isConnected
        ? Icons.bluetooth_disabled_rounded
        : rssi == null
        ? Icons.bluetooth_searching_rounded
        : appState.isSignalWeak
        ? Icons.warning_amber_rounded
        : Icons.bluetooth_connected_rounded;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 12),
      child: Column(
        children: [
          Expanded(
            child: CircleContainer(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor.withValues(alpha: 0.14),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Icon(statusIcon, size: 38, color: statusColor),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      statusTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      statusMessage,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isConnected) ...[
                      const SizedBox(height: 22),
                      Text(
                        'SIGNAL STRENGTH',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rssi == null ? 'Waiting...' : appState.signalStatus,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.2,
                        ),
                      ),
                      Text(
                        rssi == null
                            ? 'Waiting for signal'
                            : 'Bluetooth signal quality',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          appState.connectedDevice?.name ?? 'ProxiLeash device',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: GlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              borderRadius: 20,
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.38),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isDisconnected
                          ? 'Connection lost'
                          : isConnected
                          ? 'Bluetooth connected'
                          : 'Waiting for device',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isConnected)
                    Text(
                      rssi == null ? 'Waiting...' : appState.signalStatus,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
