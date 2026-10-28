# proxileash

A new Flutter project.

## Bluetooth monitoring

The app scans for BLE devices and monitors the selected connection's signal
strength. The interface describes signal quality as Strong, Moderate, or Weak
instead of displaying raw signal readings. A weak signal or unexpected
disconnection triggers a warning alarm; on Android the alarm uses a repeating
vibration pattern and sound.

On Android, monitoring continues in a connected-device foreground service. The
app needs Bluetooth and notification permissions; Android may also require the
user to allow full-screen notifications. When allowed by the OS, a weak-signal
alarm opens the in-app warning screen. Force-stopping the app or disabling its
notifications prevents background alerts.

On iOS, Bluetooth background mode and state restoration are enabled. iOS can
deliver a notification while the app is suspended when Bluetooth wakes it, but
it does not allow an app to force its screen open. Background RSSI polling is
subject to iOS scheduling, and force-quitting the app stops background
monitoring.

## Settings

The Settings tab lets you follow the system theme or choose light/dark mode,
enable or disable distance alerts, and independently control alarm sound and
vibration. These preferences are saved on the device and applied to Android's
background monitoring service. System notification settings may override
sound or vibration.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
