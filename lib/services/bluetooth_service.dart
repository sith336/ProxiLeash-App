import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/device.dart';

import '../models/app_state.dart';

class BluetoothService {
  // Bluetooth Essentials
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  // STATE MANAGEMENT CONTOL
  bool isScanning = false;

  // containers
  final Map<String, Device> scannedDevices = {};

  // SCAN FOR DEVICES

  Future<void> startScan() async {
    if (isScanning) return;

    isScanning = true;
    scannedDevices.clear();
    _scanSubscription?.cancel();

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final device = result.device;

        final id = device.remoteId.str;

        if (id.isNotEmpty) {
          scannedDevices[id] = Device(
            id: id,
            name: device.platformName,
            isConnected: false,
          );
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    await Future.delayed(const Duration(seconds: 5));

    await stopScan();
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();

    await _scanSubscription?.cancel();
    _scanSubscription = null;

    isScanning = false;
  }

  // CONNECT TO DEVICE

  Future<void> connect(BluetoothDevice device) async {
    try {
      await device.connect(license: License.free);
    } catch (e) {
      print('Connection error: $e');
    }
  }

  Future<void> disconnect(BluetoothDevice device) async {
    try {
      await device.disconnect();
    } catch (e) {
      print('Disconnection error: $e');
    }
  }

  // MAINTAIN CONNECTION

  // READ RSSI
  Future<int> getRSSI(BluetoothDevice device) async {
    return device.readRssi();
  }

  // CATCH DISCONNECTIONS
}
