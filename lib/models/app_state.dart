import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../services/alarm_notification_service.dart';
import '../services/bluetooth_service.dart';
import 'device.dart';

class AppState extends ChangeNotifier {
  late final BluetoothService bluetoothService;

  AppState() {
    bluetoothService = BluetoothService(this);
  }

  bool _disposed = false;

  // --------------------------------------------------
  // SCANNING STATE
  // --------------------------------------------------

  bool isScanning = false;

  Map<String, Device> get scannedDevices => bluetoothService.scannedDevices;

  // --------------------------------------------------
  // CONNECTION STATE
  // --------------------------------------------------

  Device? connectedDevice;

  // True while the device is connected.
  bool deviceHasConnected = false;

  // True after a previously established connection is lost.
  bool deviceHasDisconnected = false;

  bool isConnecting = false;

  // --------------------------------------------------
  // SIGNAL STATE
  // --------------------------------------------------

  int? currentRSSI;
  String signalStatus = 'Not Connected';
  static const int weakSignalThreshold = -85;
  bool _weakSignalAlerted = false;
  bool disconnectedByWeakSignal = false;
  String? disconnectedDeviceName;

  bool get isSignalWeak =>
      currentRSSI != null && currentRSSI! < weakSignalThreshold;

  String? _connectedDeviceId;

  // --------------------------------------------------
  // ERROR STATE
  // --------------------------------------------------

  String? bluetoothError;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // --------------------------------------------------
  // SCANNING
  // --------------------------------------------------

  Future<void> startScan() async {
    if (_disposed || isScanning) return;

    bluetoothError = null;
    _notify();

    try {
      await bluetoothService.startScan();
    } catch (e) {
      onBluetoothError('Unable to scan for devices: $e');
    }
  }

  Future<void> stopScan() async {
    await bluetoothService.stopScan();
  }

  // Called by BluetoothService.
  void onScanStateChanged(bool scanning) {
    isScanning = scanning;
    _notify();
  }

  // Called when devices are discovered or their state changes.
  void onScanResultsUpdated() {
    _notify();
  }

  // --------------------------------------------------
  // CONNECTION
  // --------------------------------------------------

  Future<void> connectToDevice(Device device) async {
    if (_disposed || isConnecting) return;

    final bluetoothDevice = bluetoothService.bluetoothDevices[device.id];

    if (bluetoothDevice == null) {
      bluetoothError = 'Device not found. Scan again and retry.';
      _notify();
      return;
    }

    isConnecting = true;
    bluetoothError = null;
    deviceHasDisconnected = false;
    _notify();

    try {
      if (Platform.isIOS) {
        await AlarmNotificationService.requestPermissions();
      }
      await bluetoothService.connect(bluetoothDevice);
    } catch (e) {
      bluetoothError = 'Connection failed: $e';
    } finally {
      isConnecting = false;
      _notify();
    }
  }

  Future<void> disconnectFromDevice() async {
    final device = bluetoothService.connectedDevice;

    if (device == null) return;

    bluetoothError = null;
    _notify();

    try {
      await bluetoothService.disconnect(device);
    } catch (e) {
      bluetoothError = 'Disconnection failed: $e';
      _notify();
    }
  }

  // --------------------------------------------------
  // CONNECTION STATE CALLBACK
  // --------------------------------------------------

  // Called by BluetoothService whenever the actual connection
  // state changes.
  void onDeviceConnectionChanged(
    String id,
    bool connected, {
    bool userInitiated = false,
  }) {
    if (_disposed) return;

    if (connected) {
      final isNewConnection = _connectedDeviceId != id;

      _connectedDeviceId = id;
      deviceHasConnected = true;
      deviceHasDisconnected = false;
      disconnectedByWeakSignal = false;
      disconnectedDeviceName = null;

      connectedDevice = bluetoothService.scannedDevices[id];

      if (isNewConnection) {
        currentRSSI = null;
      }

      signalStatus = currentRSSI == null
          ? 'Waiting for signal'
          : getSignalStatus(currentRSSI!);

      bluetoothError = null;
    } else {
      // Ignore disconnect events from an unrelated device.
      if (_connectedDeviceId != id) return;

      final wasSignalWeak = isSignalWeak;
      disconnectedDeviceName = connectedDevice?.name;
      disconnectedByWeakSignal = wasSignalWeak;
      _connectedDeviceId = null;
      deviceHasDisconnected = !userInitiated;
      deviceHasConnected = false;
      connectedDevice = null;

      currentRSSI = null;
      signalStatus = 'Not Connected';

      if (userInitiated) {
        _weakSignalAlerted = false;
      } else {
        _weakSignalAlerted = true;
        unawaited(_showConnectionLostAlert(wasSignalWeak));
      }
    }

    _notify();
  }

  // --------------------------------------------------
  // RSSI
  // --------------------------------------------------

  void onRSSIUpdated(int rssi) {
    if (_disposed || !deviceHasConnected) return;

    currentRSSI = rssi;
    signalStatus = getSignalStatus(rssi);

    if (!AlarmNotificationService.distanceAlertsEnabled) {
      _weakSignalAlerted = false;
    } else if (isSignalWeak && !_weakSignalAlerted) {
      _weakSignalAlerted = true;
      if (Platform.isIOS) {
        unawaited(_showWeakSignalAlert());
      }
    } else if (!isSignalWeak && _weakSignalAlerted) {
      _weakSignalAlerted = false;
      unawaited(AlarmNotificationService.clearTooFarAlert());
    }

    _notify();
  }

  Future<void> _showWeakSignalAlert() async {
    try {
      await AlarmNotificationService.showTooFarAlert(
        deviceName: connectedDevice?.name ?? 'ProxiLeash device',
      );
    } catch (error) {
      onBluetoothError('Unable to show the distance alert: $error');
    }
  }

  Future<void> _showConnectionLostAlert(bool weakSignal) async {
    try {
      await AlarmNotificationService.showConnectionLostAlert(
        deviceName: disconnectedDeviceName ?? 'ProxiLeash device',
        weakSignal: weakSignal,
      );
    } catch (error) {
      onBluetoothError('Unable to show the connection alert: $error');
    }
  }

  String getSignalStatus(int rssi) {
    if (rssi >= -65) return 'Strong';
    if (rssi >= weakSignalThreshold) return 'Moderate';
    return 'Weak';
  }

  // --------------------------------------------------
  // ERROR CALLBACK
  // --------------------------------------------------

  void onBluetoothError(String message) {
    if (_disposed) return;

    bluetoothError = message;
    _notify();
  }

  // --------------------------------------------------
  // CLEANUP
  // --------------------------------------------------

  Future<void> disposeBluetoothService() async {
    await bluetoothService.dispose();
  }

  @override
  void dispose() {
    _disposed = true;

    // ChangeNotifier.dispose() cannot be asynchronous.
    // Schedule service cleanup without blocking disposal.
    unawaited(bluetoothService.dispose());

    super.dispose();
  }
}
