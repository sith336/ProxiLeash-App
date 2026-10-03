import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:proxileash/models/app_state.dart';
import 'package:proxileash/widgets/custom_card.dart';

import '../widgets/clickable_card.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  late AppState appState;

  bool showDeviceCard = false;

  bool _isScanningDevices = false;

  String? _connectingDeviceId;

  @override
  Widget build(BuildContext context) {
    appState = context.watch<AppState>();
    return Center(
      child: Column(
        mainAxisAlignment: appState.deviceHasConnected
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          SizedBox(height: 32),
          appState.deviceHasConnected ? _deviceDescription() : _addnewDevice(),
          if (_isScanningDevices) ...[SizedBox(height: 32), _scanNewDevices()],
        ],
      ),
    );
  }

  // Existing Devices

  Widget _deviceDescription() {
    return CustomCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_connected, size: 48),
          SizedBox(height: 16),
          Text('Device Connected', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _deviceSignalTracker() {
    return CustomCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.signal_cellular_4_bar, size: 48),
          SizedBox(height: 16),
          Text('Signal Strength', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  // New Devices

  Widget _addnewDevice() {
    return ClickableCard(
      onTap: () {
        setState(() {
          _isScanningDevices = true;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, size: 48),
          SizedBox(height: 16),
          Text('Connect to Device', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _scanNewDevices() {
    final devices = appState.getScannedDevices().values.toList();

    return CustomCard(
      child: Column(
        children: [
          const Text('Scanning for Devices...', style: TextStyle(fontSize: 18)),

          const SizedBox(height: 16),

          if (devices.isEmpty)
            const Text('No devices found')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];

                final isConnecting = _connectingDeviceId == device.id;

                return ListTile(
                  leading: const Icon(Icons.bluetooth),

                  title: Text(device.name),

                  subtitle: Text(device.id),

                  trailing: isConnecting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : device.isConnected
                      ? const Icon(Icons.check_circle)
                      : const Icon(Icons.arrow_forward_ios, size: 16),

                  onTap: isConnecting
                      ? null
                      : () => appState.connectToDevice(device),
                );
              },
            ),
        ],
      ),
    );
  }
}
