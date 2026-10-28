import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/device.dart';
import '../models/app_state.dart';
import 'alarm_notification_service.dart';
import 'background_ble_task.dart';

class BluetoothService {
  final AppState appState;

  BluetoothService(this.appState) {
    if (Platform.isAndroid) {
      FlutterForegroundTask.addTaskDataCallback(_onBackgroundTaskData);
      unawaited(_restoreBackgroundTask());
    }
  }

  // Scanning
  bool isScanning = false;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<bool>? _scanStateSubscription;
  bool _isFinishingScan = false;

  // Discovered devices
  final Map<String, Device> scannedDevices = {};
  final Map<String, BluetoothDevice> bluetoothDevices = {};
  final Map<String, int> latestRSSI = {};

  // Connection
  BluetoothDevice? connectedDevice;
  String? _activeDeviceId;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  // RSSI monitoring
  Timer? _rssiTimer;
  bool _isReadingRSSI = false;
  Completer<void>? _connectionCompleter;
  Completer<void>? _disconnectCompleter;
  bool _isDisconnecting = false;

  bool _isDisposed = false;

  bool get isConnected => connectedDevice?.isConnected ?? false;

  // Optional RSSI stream for other consumers.
  final StreamController<Map<String, int>> _rssiController =
      StreamController<Map<String, int>>.broadcast();

  Stream<Map<String, int>> get rssiStream => _rssiController.stream;

  // --------------------------------------------------
  // SCANNING
  // --------------------------------------------------

  Future<void> startScan({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (_isDisposed || isScanning) return;

    await _requestBluetoothPermissions();

    if (!await FlutterBluePlus.isSupported) {
      throw Exception('Bluetooth is not supported on this device.');
    }

    await stopScan();

    isScanning = true;
    scannedDevices.clear();
    bluetoothDevices.clear();

    appState.onScanStateChanged(true);
    appState.onScanResultsUpdated();

    try {
      await _scanSubscription?.cancel();

      _scanSubscription = FlutterBluePlus.onScanResults.listen(
        (results) {
          if (_isDisposed) return;

          for (final result in results) {
            final bluetoothDevice = result.device;
            final id = bluetoothDevice.remoteId.str;

            if (id.isEmpty) continue;

            bluetoothDevices[id] = bluetoothDevice;

            final previous = scannedDevices[id];
            final advertisedName = result.advertisementData.advName;

            scannedDevices[id] = Device(
              id: id,
              name: bluetoothDevice.platformName.isNotEmpty
                  ? bluetoothDevice.platformName
                  : advertisedName.isNotEmpty
                  ? advertisedName
                  : (previous?.name ?? 'Unknown Device'),
              isConnected: bluetoothDevice.isConnected,
              rssi: result.rssi,
            );
          }

          appState.onScanResultsUpdated();
        },
        onError: (Object error) {
          debugPrint('BLE scan error: $error');
          appState.onBluetoothError('Unable to receive scan results: $error');
        },
      );

      var scanStarted = FlutterBluePlus.isScanningNow;
      _scanStateSubscription = FlutterBluePlus.isScanning.listen((scanning) {
        if (scanning) {
          scanStarted = true;
          if (!isScanning && !_isDisposed) {
            isScanning = true;
            appState.onScanStateChanged(true);
          }
        } else if (scanStarted) {
          unawaited(_finishScan());
        }
      });

      await FlutterBluePlus.startScan(timeout: timeout);
    } catch (e) {
      debugPrint('Unable to start BLE scan: $e');
      await _finishScan();
      rethrow;
    }
  }

  Future<void> stopScan() async {
    try {
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
    } catch (e) {
      debugPrint('Unable to stop BLE scan: $e');
    }
    await _finishScan();
  }

  Future<void> _finishScan() async {
    if (_isFinishingScan) return;
    _isFinishingScan = true;

    try {
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      await _scanStateSubscription?.cancel();
      _scanStateSubscription = null;

      isScanning = false;
      if (!_isDisposed) {
        appState.onScanStateChanged(false);
      }
    } finally {
      _isFinishingScan = false;
    }
  }

  // --------------------------------------------------
  // CONNECTION
  // --------------------------------------------------

  Future<void> connect(BluetoothDevice device) async {
    if (_isDisposed) {
      throw StateError('BluetoothService has been disposed.');
    }

    await stopScan();

    final id = device.remoteId.str;
    _activeDeviceId = id;

    if (connectedDevice?.remoteId.str == id && device.isConnected) {
      _updateDeviceConnection(id, true);
      return;
    }

    // Stop the previous device's RSSI monitoring.
    await stopRSSIMonitoring();

    // Do not leave a previous device listener active.
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    connectedDevice = null;

    // Preserve the device in our maps even if it was
    // selected from a source other than the current scan.
    bluetoothDevices[id] = device;

    final previous = scannedDevices[id];

    scannedDevices[id] = Device(
      id: id,
      name: device.platformName.isNotEmpty
          ? device.platformName
          : (previous?.name ?? 'Unknown Device'),
      isConnected: device.isConnected,
    );

    if (Platform.isAndroid) {
      await _startBackgroundMonitoring(id, scannedDevices[id]!.name);
      return;
    }

    // Subscribe before connecting so connection events
    // are not missed.
    _connectionSubscription = device.connectionState.listen(
      (state) {
        if (_isDisposed) return;

        if (state == BluetoothConnectionState.connected) {
          connectedDevice = device;
          _updateDeviceConnection(id, true);

          appState.onDeviceConnectionChanged(id, true);
          startRSSIMonitoring(device);
        } else if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnection(id);
        }
      },
      onError: (Object error) {
        debugPrint('Connection state error: $error');

        if (!_isDisposed) {
          appState.onBluetoothError('Bluetooth connection error: $error');
        }
      },
    );

    try {
      if (!device.isConnected) {
        await device.connect(
          timeout: const Duration(seconds: 15),
          license: License.nonprofit,
        );
      }

      // Synchronize state even if the connected event
      // arrived before connect() completed.
      if (device.isConnected && !_isDisposed) {
        connectedDevice = device;
        _updateDeviceConnection(id, true);

        appState.onDeviceConnectionChanged(id, true);
        startRSSIMonitoring(device);
      }
    } catch (e) {
      debugPrint('BLE connection error: $e');

      await _connectionSubscription?.cancel();
      _connectionSubscription = null;

      connectedDevice = null;
      stopRSSIMonitoring();

      _updateDeviceConnection(id, false);

      if (!_isDisposed) {
        appState.onDeviceConnectionChanged(id, false);
      }

      rethrow;
    }
  }

  Future<void> disconnect(BluetoothDevice device) async {
    final id = device.remoteId.str;

    await stopRSSIMonitoring();
    await AlarmNotificationService.clearTooFarAlert();
    _isDisconnecting = true;

    try {
      if (Platform.isAndroid && await FlutterForegroundTask.isRunningService) {
        final completer = Completer<void>();
        _disconnectCompleter = completer;
        FlutterForegroundTask.sendDataToTask({'action': 'disconnect'});

        try {
          await completer.future.timeout(const Duration(seconds: 3));
        } on TimeoutException {
          if (await FlutterForegroundTask.isRunningService) {
            final result = await FlutterForegroundTask.stopService();
            if (result is ServiceRequestFailure) {
              throw result.error;
            }
          }
        }

        _handleDisconnection(id, userInitiated: true);
        return;
      }

      await device.disconnect();
      _handleDisconnection(id, userInitiated: true);
    } catch (e) {
      debugPrint('BLE disconnection error: $e');
      rethrow;
    } finally {
      _disconnectCompleter = null;
      _isDisconnecting = false;
    }
  }

  // --------------------------------------------------
  // RSSI
  // --------------------------------------------------

  Future<int> getRSSI(BluetoothDevice device) async {
    if (_isDisposed || !device.isConnected) {
      throw StateError('Device is not connected.');
    }

    final rssi = await device.readRssi();

    if (_isDisposed ||
        connectedDevice?.remoteId.str != device.remoteId.str ||
        !device.isConnected) {
      throw StateError('Connection changed while reading RSSI.');
    }

    final id = device.remoteId.str;

    latestRSSI[id] = rssi;

    // Send a snapshot so consumers cannot modify our map.
    _rssiController.add(Map<String, int>.unmodifiable(latestRSSI));

    // Keep AppState synchronized with every successful read.
    appState.onRSSIUpdated(rssi);

    return rssi;
  }

  void startRSSIMonitoring(
    BluetoothDevice device, {
    Duration interval = const Duration(seconds: 2),
  }) {
    _rssiTimer?.cancel();
    _rssiTimer = null;

    if (_isDisposed || !device.isConnected) return;

    _rssiTimer = Timer.periodic(interval, (_) async {
      if (_isDisposed) return;

      if (!device.isConnected) {
        _handleDisconnection(device.remoteId.str);
        return;
      }

      // Avoid overlapping asynchronous RSSI reads.
      if (_isReadingRSSI) return;

      _isReadingRSSI = true;

      try {
        await getRSSI(device);
      } catch (e) {
        debugPrint('RSSI read error: $e');
      } finally {
        _isReadingRSSI = false;
      }
    });
  }

  Future<void> stopRSSIMonitoring() async {
    _rssiTimer?.cancel();
    _rssiTimer = null;
  }

  // --------------------------------------------------
  // STATE SYNCHRONIZATION
  // --------------------------------------------------

  void _updateDeviceConnection(String id, bool connected) {
    final existing = scannedDevices[id];

    if (existing == null) return;

    scannedDevices[id] = Device(
      id: existing.id,
      name: existing.name,
      isConnected: connected,
      rssi: existing.rssi,
    );

    if (!_isDisposed) {
      appState.onScanResultsUpdated();
    }
  }

  void _handleDisconnection(String id, {bool userInitiated = false}) {
    final wasCurrentDevice = connectedDevice?.remoteId.str == id;

    if (!wasCurrentDevice) return;

    final isUserInitiated = userInitiated || _isDisconnecting;
    connectedDevice = null;
    _activeDeviceId = null;

    _rssiTimer?.cancel();
    _rssiTimer = null;

    latestRSSI.remove(id);

    _updateDeviceConnection(id, false);

    _rssiController.add(Map<String, int>.unmodifiable(latestRSSI));

    if (!_isDisposed) {
      appState.onDeviceConnectionChanged(
        id,
        false,
        userInitiated: isUserInitiated,
      );
    }

    debugPrint('BLE device disconnected: $id');
  }

  // --------------------------------------------------
  // CLEANUP
  // --------------------------------------------------

  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;

    _rssiTimer?.cancel();
    _rssiTimer = null;

    try {
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
    } catch (e) {
      debugPrint('Scan cleanup error: $e');
    }

    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await _scanStateSubscription?.cancel();
    _scanStateSubscription = null;

    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    if (Platform.isAndroid) {
      FlutterForegroundTask.removeTaskDataCallback(_onBackgroundTaskData);
    }

    await _rssiController.close();

    connectedDevice = null;
    scannedDevices.clear();
    bluetoothDevices.clear();
    latestRSSI.clear();

    isScanning = false;
  }

  Future<void> _startBackgroundMonitoring(String id, String name) async {
    await AlarmNotificationService.requestPermissions();

    final permission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (permission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    final savedId = await FlutterForegroundTask.saveData(
      key: 'monitored_device_id',
      value: id,
    );
    final savedName = await FlutterForegroundTask.saveData(
      key: 'monitored_device_name',
      value: name,
    );
    if (!savedId || !savedName) {
      throw StateError('Unable to save the device for background monitoring.');
    }

    final completer = Completer<void>();
    _connectionCompleter = completer;

    try {
      if (await FlutterForegroundTask.isRunningService) {
        FlutterForegroundTask.sendDataToTask({
          'action': 'connect',
          'id': id,
          'name': name,
        });
      } else {
        final result = await FlutterForegroundTask.startService(
          serviceId: 271,
          serviceTypes: const [ForegroundServiceTypes.connectedDevice],
          notificationTitle: 'ProxiLeash is monitoring',
          notificationText: 'Watching the connection to $name.',
          callback: startBackgroundBleTask,
        );
        if (result is ServiceRequestFailure) {
          throw result.error;
        }
      }

      await completer.future.timeout(const Duration(seconds: 20));
    } finally {
      if (identical(_connectionCompleter, completer)) {
        _connectionCompleter = null;
      }
    }
  }

  Future<void> _restoreBackgroundTask() async {
    try {
      if (await FlutterForegroundTask.isRunningService) {
        FlutterForegroundTask.sendDataToTask({'action': 'state'});
      }
    } catch (error) {
      debugPrint('Unable to restore background BLE monitoring: $error');
      appState.onBluetoothError(
        'Unable to restore background Bluetooth monitoring: $error',
      );
    }
  }

  void _onBackgroundTaskData(Object data) {
    if (data is! Map) return;

    final type = data['type'];
    if (type == 'connection') {
      final id = data['id'];
      if (id is! String || id.isEmpty) return;

      final name = data['name'];
      final connected = data['connected'] == true;
      final connecting = data['connecting'] == true;
      final previous = scannedDevices[id];
      final deviceName = name is String && name.isNotEmpty
          ? name
          : previous?.name ?? 'Unknown Device';

      scannedDevices[id] = Device(
        id: id,
        name: deviceName,
        isConnected: connected,
        rssi: previous?.rssi,
      );
      bluetoothDevices[id] = bluetoothDevices[id] ?? BluetoothDevice.fromId(id);

      if (connected) {
        connectedDevice = bluetoothDevices[id];
        _activeDeviceId = id;
        appState.onDeviceConnectionChanged(id, true);
        final completer = _connectionCompleter;
        if (completer != null && !completer.isCompleted) {
          completer.complete();
        }
      } else if (!connecting && _activeDeviceId == id) {
        _handleDisconnection(id);
      }

      appState.onScanResultsUpdated();
      return;
    }

    if (type == 'rssi') {
      final id = data['id'];
      final rssi = data['rssi'];
      if (id is String && rssi is int && _activeDeviceId == id) {
        latestRSSI[id] = rssi;
        appState.onRSSIUpdated(rssi);
      }
      return;
    }

    if (type == 'error') {
      final message = data['message'];
      if (message is String) {
        appState.onBluetoothError(message);
        final completer = _connectionCompleter;
        if (completer != null && !completer.isCompleted) {
          completer.completeError(StateError(message));
        }
      }
      return;
    }

    if (type == 'stopped') {
      final completer = _disconnectCompleter;
      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }
    }
  }

  Future<void> _requestBluetoothPermissions() async {
    if (!Platform.isAndroid) return;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final permissions = androidInfo.version.sdkInt >= 31
        ? [Permission.bluetoothScan, Permission.bluetoothConnect]
        : [Permission.locationWhenInUse];
    final statuses = await permissions.request();
    if (statuses.values.any((status) => !status.isGranted)) {
      throw StateError(
        'Bluetooth permissions are required to scan for nearby devices.',
      );
    }
  }
}
