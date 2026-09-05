import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  Future<List<ScanResult>> scanDevices() async {
    final List<ScanResult> devices = [];

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      devices.clear();
      devices.addAll(results);
    });

    await Future.delayed(const Duration(seconds: 5));

    await FlutterBluePlus.stopScan();

    return devices;
  }
}
