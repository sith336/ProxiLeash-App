import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:proxileash/models/app_state.dart';
import 'package:proxileash/models/device.dart';
import 'package:proxileash/widgets/custom_card.dart';

import '../widgets/clickable_card.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  bool _showScanner = false;
  String? _connectingDeviceId;

  String? _scanError;
  String? _connectionError;

  // --------------------------------------------------
  // SCANNING
  // --------------------------------------------------

  Future<void> _startScan() async {
    final appState = context.read<AppState>();

    if (appState.isScanning) return;

    setState(() {
      _showScanner = true;
      _scanError = null;
      _connectionError = null;
    });

    await appState.startScan();

    if (!mounted) return;

    if (appState.bluetoothError != null) {
      setState(() {
        _scanError = appState.bluetoothError;
      });
    }
  }

  Future<void> _stopScan() async {
    await context.read<AppState>().stopScan();
  }

  // --------------------------------------------------
  // CONNECTION
  // --------------------------------------------------

  Future<void> _connect(Device device) async {
    if (_connectingDeviceId != null) return;

    final appState = context.read<AppState>();

    setState(() {
      _connectingDeviceId = device.id;
      _connectionError = null;
    });

    try {
      await appState.connectToDevice(device);

      if (!mounted) return;

      final connected =
          appState.deviceHasConnected &&
          appState.connectedDevice?.id == device.id;

      if (!connected) {
        setState(() {
          _connectionError =
              appState.bluetoothError ??
              'Connection was not established. '
                  'Check the device and try again.';
        });
      } else {
        setState(() {
          _showScanner = false;
          _connectionError = null;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _connectionError =
            'Could not connect. Move closer to the device '
            'and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _connectingDeviceId = null;
        });
      }
    }
  }

  Future<void> _disconnect() async {
    final appState = context.read<AppState>();

    try {
      await appState.disconnectFromDevice();

      if (!mounted) return;

      if (appState.bluetoothError != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(appState.bluetoothError!)));
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to disconnect the device.')),
      );
    }
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final isConnected = appState.deviceHasConnected;
    final isScanning = appState.isScanning;
    final connectedDevice = appState.connectedDevice;
    final theme = Theme.of(context);

    // Disconnected screen.
    if (!isConnected) {
      return SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (appState.deviceHasDisconnected)
                  _buildDisconnectedWarning(
                    deviceName:
                        appState.disconnectedDeviceName ?? 'Your ProxiLeash',
                    weakSignal: appState.disconnectedByWeakSignal,
                  ),

                if (appState.deviceHasDisconnected) const SizedBox(height: 12),

                if (!_showScanner)
                  _buildConnectCard()
                else
                  _buildScanner(appState, isScanning),

                if (_scanError != null) ...[
                  const SizedBox(height: 12),
                  _buildError(_scanError!),
                ],

                if (_connectionError != null) ...[
                  const SizedBox(height: 12),
                  _buildError(_connectionError!),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // Connected device monitoring screen.
    final deviceName = connectedDevice?.name ?? 'ProxiLeash Device';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            Icon(
              Icons.bluetooth_connected,
              size: 54,
              color: theme.colorScheme.primary,
            ),

            const SizedBox(height: 12),

            Text(
              deviceName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF38856A).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF38856A).withValues(alpha: 0.18),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 17,
                        color: Color(0xFF38856A),
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Connected',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            _buildSignalCard(appState.currentRSSI, appState.signalStatus),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: _disconnect,
              icon: const Icon(Icons.bluetooth_disabled),
              label: const Text('Disconnect Device'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // CONNECT CARD
  // --------------------------------------------------

  Widget _buildConnectCard() {
    return ClickableCard(
      onTap: _startScan,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline, size: 56),
            SizedBox(height: 16),
            Text(
              'Connect to Device',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Tap to find and connect your ProxiLeash.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // DEVICE SCANNER
  // --------------------------------------------------

  Widget _buildScanner(AppState appState, bool isScanning) {
    final devices = appState.scannedDevices.values.toList();

    return CustomCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.bluetooth_searching, size: 28),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Find a Device',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: 'Close scanner',
                onPressed: isScanning
                    ? null
                    : () {
                        setState(() {
                          _showScanner = false;
                          _scanError = null;
                        });
                      },
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (isScanning) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
            const Text(
              'Searching for nearby BLE devices...',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _stopScan,
              icon: const Icon(Icons.stop),
              label: const Text('Stop Scanning'),
            ),
          ] else ...[
            OutlinedButton.icon(
              onPressed: _startScan,
              icon: const Icon(Icons.refresh),
              label: const Text('Scan Again'),
            ),
          ],

          if (appState.bluetoothError != null &&
              _scanError == null &&
              !appState.isConnecting) ...[
            const SizedBox(height: 12),
            _buildError(appState.bluetoothError!),
          ],

          const SizedBox(height: 12),

          if (devices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                isScanning
                    ? 'Waiting for nearby devices...'
                    : 'No devices found. Check that your '
                          'ProxiLeash is powered on.',
                textAlign: TextAlign.center,
              ),
            )
          else
            ...devices.map((device) {
              final isConnecting = _connectingDeviceId == device.id;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.bluetooth_rounded),
                ),
                title: Text(
                  device.name.isEmpty ? 'Unknown Device' : device.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  device.rssi == null
                      ? device.id
                      : '${device.id}  ·  ${appState.getSignalStatus(device.rssi!)} signal',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: isConnecting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _connectingDeviceId != null || appState.isConnecting
                    ? null
                    : () => _connect(device),
              );
            }),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SIGNAL STRENGTH
  // --------------------------------------------------

  Widget _buildSignalCard(int? rssi, String signalStatus) {
    final theme = Theme.of(context);
    final hasSignal = rssi != null;

    final bars = hasSignal ? _signalBars(rssi) : 0;

    final color = !hasSignal
        ? theme.colorScheme.onSurfaceVariant
        : rssi >= -65
        ? const Color(0xFF38856A)
        : rssi >= AppState.weakSignalThreshold
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text(
              'Signal Strength',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(4, (index) {
                final active = index < bars;

                return Container(
                  width: 24,
                  height: 20.0 + (index * 13),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: active
                        ? color
                        : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            Text(
              hasSignal ? signalStatus : 'Waiting for signal',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(height: 8),

            const SizedBox(height: 8),

            const Text(
              'Signal readings fluctuate with distance '
              'and obstacles.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // DISCONNECTION WARNING
  // --------------------------------------------------

  Widget _buildDisconnectedWarning({
    required String deviceName,
    required bool weakSignal,
  }) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.error.withValues(alpha: 0.08),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: theme.colorScheme.error,
              size: 30,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bluetooth connection lost',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    weakSignal
                        ? '$deviceName disconnected after the signal became '
                              'weak. Move closer and reconnect. A sound and '
                              'vibration alert has been sent.'
                        : '$deviceName lost its Bluetooth connection. Move '
                              'closer and reconnect. A sound and vibration '
                              'alert has been sent.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // ERROR MESSAGE
  // --------------------------------------------------

  Widget _buildError(String message) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: TextStyle(color: theme.colorScheme.error)),
    );
  }

  // --------------------------------------------------
  // SIGNAL BARS
  // --------------------------------------------------

  int _signalBars(int rssi) {
    if (rssi >= -65) return 4;
    if (rssi >= AppState.weakSignalThreshold) return 2;
    return 1;
  }
}
