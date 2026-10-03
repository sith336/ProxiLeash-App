import 'package:flutter/foundation.dart';

import '../services/bluetooth_service.dart';
import 'device.dart';

class AppState extends ChangeNotifier {
  final BluetoothService bluetoothService = BluetoothService();

  bool deviceHasConnected = false;
  bool deviceHasDisconnected = false;

  // Scanning Functions

  Future<void> startScan() async {
    await bluetoothService.startScan();
    notifyListeners();
  }

  Future<void> stopScan() async {
    await bluetoothService.stopScan();
    notifyListeners();
  }

  Map<String, Device> getScannedDevices() {
    return bluetoothService.scannedDevices;
  }

  // Connection Functions

  Future<void> connectToDevice(Device device) async {
    device.isConnected = true;
    deviceHasConnected = true;
    deviceHasDisconnected = false;
    notifyListeners();
  }

  String getSignalStatus(int rssi) {
    if (rssi >= -50) {
      return "Very Close";
    } else if (rssi >= -65) {
      return "Close";
    } else if (rssi >= -75) {
      return "Nearby";
    } else if (rssi >= -85) {
      return "Far";
    } else {
      return "Very Far";
    }
  }
}
