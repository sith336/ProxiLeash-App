import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'alarm_notification_service.dart';

const String _deviceIdKey = 'monitored_device_id';
const String _deviceNameKey = 'monitored_device_name';
const int _weakSignalThreshold = -85;

void configureBackgroundBleTask() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'ble_monitor',
      channelName: 'ProxiLeash monitoring',
      channelDescription: 'Keeps the Bluetooth connection monitored.',
      onlyAlertOnce: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(2000),
      allowWakeLock: true,
      allowAutoRestart: true,
      stopWithTask: false,
    ),
  );
}

@pragma('vm:entry-point')
void startBackgroundBleTask() {
  FlutterForegroundTask.setTaskHandler(BackgroundBleTask());
}

class BackgroundBleTask extends TaskHandler {
  BluetoothDevice? _device;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  String? _deviceName;
  bool _connecting = false;
  bool _readingRssi = false;
  bool _weakSignalAlerted = false;
  bool _firstConnectionAttempt = true;
  DateTime? _lastConnectionAttempt;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await AlarmNotificationService.initialize();
    final id =
        await FlutterForegroundTask.getData(key: _deviceIdKey) as String?;
    _deviceName =
        await FlutterForegroundTask.getData(key: _deviceNameKey) as String?;
    if (id != null && id.isNotEmpty) {
      await _monitorDevice(id);
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    unawaited(_pollDevice());
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
  }

  @override
  void onReceiveData(Object data) {
    if (data is! Map) return;

    final action = data['action'];
    if (action == 'alert_preferences') {
      final enabled = data['enabled'];
      final soundEnabled = data['soundEnabled'];
      final vibrationEnabled = data['vibrationEnabled'];
      if (enabled is! bool ||
          soundEnabled is! bool ||
          vibrationEnabled is! bool) {
        return;
      }

      AlarmNotificationService.applyAlertPreferences(
        enabled: enabled,
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
      );
      _weakSignalAlerted = false;
      if (enabled) unawaited(_pollDevice());
    } else if (action == 'connect' && data['id'] is String) {
      final id = data['id'] as String;
      final name = data['name'];
      _deviceName = name is String ? name : 'ProxiLeash device';
      unawaited(FlutterForegroundTask.saveData(key: _deviceIdKey, value: id));
      unawaited(
        FlutterForegroundTask.saveData(
          key: _deviceNameKey,
          value: _deviceName!,
        ),
      );
      unawaited(_monitorDevice(id));
    } else if (action == 'disconnect') {
      unawaited(_disconnect());
    } else if (action == 'state') {
      final device = _device;
      if (device != null) {
        _sendConnectionState(device.isConnected);
      }
    }
  }

  Future<void> _monitorDevice(String id) async {
    if (_device?.remoteId.str == id) {
      if (!_device!.isConnected) {
        await _connect();
      }
      return;
    }

    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _device = BluetoothDevice.fromId(id);
    _connectionSubscription = _device!.connectionState.listen(
      (state) {
        final connected = state == BluetoothConnectionState.connected;
        _sendConnectionState(connected);
      },
      onError: (Object error) {
        FlutterForegroundTask.sendDataToMain({
          'type': 'error',
          'message': 'Bluetooth connection error: $error',
        });
      },
    );
    await _connect();
  }

  Future<void> _connect() async {
    final device = _device;
    if (device == null || device.isConnected || _connecting) return;

    final now = DateTime.now();
    final lastAttempt = _lastConnectionAttempt;
    if (lastAttempt != null &&
        now.difference(lastAttempt) < const Duration(seconds: 8)) {
      return;
    }

    _connecting = true;
    _lastConnectionAttempt = now;
    FlutterForegroundTask.sendDataToMain({
      'type': 'connection',
      'id': device.remoteId.str,
      'name': _deviceName ?? device.platformName,
      'connected': false,
      'connecting': true,
    });

    try {
      if (_firstConnectionAttempt) {
        await device.connect(
          timeout: const Duration(seconds: 15),
          license: License.nonprofit,
        );
        _firstConnectionAttempt = false;
      } else {
        await device.connect(
          autoConnect: true,
          mtu: null,
          license: License.nonprofit,
        );
      }

      if (device.isConnected) {
        _sendConnectionState(true);
      }
    } catch (error) {
      _firstConnectionAttempt = false;
      FlutterForegroundTask.sendDataToMain({
        'type': 'error',
        'message': 'Connection failed: $error',
      });
    } finally {
      _connecting = false;
    }
  }

  Future<void> _pollDevice() async {
    final device = _device;
    if (device == null) return;

    if (!device.isConnected) {
      await _connect();
      return;
    }

    if (_readingRssi) return;
    _readingRssi = true;
    try {
      final rssi = await device.readRssi();
      FlutterForegroundTask.sendDataToMain({
        'type': 'rssi',
        'id': device.remoteId.str,
        'rssi': rssi,
      });

      if (rssi < _weakSignalThreshold && !_weakSignalAlerted) {
        await AlarmNotificationService.showTooFarAlert(
          deviceName: _deviceName ?? 'ProxiLeash device',
        );
        _weakSignalAlerted = true;
      } else if (rssi >= _weakSignalThreshold && _weakSignalAlerted) {
        await AlarmNotificationService.clearTooFarAlert();
        _weakSignalAlerted = false;
      }
    } catch (error) {
      FlutterForegroundTask.sendDataToMain({
        'type': 'error',
        'message': 'Unable to read Bluetooth signal strength: $error',
      });
    } finally {
      _readingRssi = false;
    }
  }

  void _sendConnectionState(bool connected) {
    final device = _device;
    if (device == null) return;

    FlutterForegroundTask.sendDataToMain({
      'type': 'connection',
      'id': device.remoteId.str,
      'name': _deviceName ?? device.platformName,
      'connected': connected,
      'connecting': false,
    });
  }

  Future<void> _disconnect() async {
    final device = _device;
    _device = null;
    _weakSignalAlerted = false;
    await AlarmNotificationService.clearTooFarAlert();
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    if (device != null && device.isConnected) {
      await device.disconnect();
    }

    await FlutterForegroundTask.saveData(key: _deviceIdKey, value: '');
    await FlutterForegroundTask.saveData(key: _deviceNameKey, value: '');
    FlutterForegroundTask.sendDataToMain({'type': 'stopped'});
    await FlutterForegroundTask.stopService();
  }
}
