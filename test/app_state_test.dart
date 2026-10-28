import 'package:flutter_test/flutter_test.dart';
import 'package:proxileash/models/app_state.dart';

void main() {
  late AppState appState;

  setUp(() {
    appState = AppState();
  });

  tearDown(() {
    appState.dispose();
  });

  test('signal labels describe strong, moderate, and weak signal', () {
    expect(appState.getSignalStatus(-64), 'Strong');
    expect(appState.getSignalStatus(-65), 'Strong');
    expect(appState.getSignalStatus(-66), 'Moderate');
    expect(appState.getSignalStatus(-85), 'Moderate');
    expect(appState.getSignalStatus(-86), 'Weak');
  });

  test('weak signal begins below the moderate threshold', () {
    appState.onDeviceConnectionChanged('device-id', true);

    appState.onRSSIUpdated(-85);
    expect(appState.isSignalWeak, isFalse);

    appState.onRSSIUpdated(-86);
    expect(appState.isSignalWeak, isTrue);
  });

  test('unexpected disconnect records weak-signal warning state', () {
    appState.onDeviceConnectionChanged('device-id', true);
    appState.onRSSIUpdated(-86);

    appState.onDeviceConnectionChanged('device-id', false);

    expect(appState.deviceHasDisconnected, isTrue);
    expect(appState.disconnectedByWeakSignal, isTrue);
    expect(appState.signalStatus, 'Not Connected');
  });

  test('intentional disconnect does not become a disconnect warning', () {
    appState.onDeviceConnectionChanged('device-id', true);

    appState.onDeviceConnectionChanged('device-id', false, userInitiated: true);

    expect(appState.deviceHasDisconnected, isFalse);
    expect(appState.disconnectedByWeakSignal, isFalse);
  });
}
