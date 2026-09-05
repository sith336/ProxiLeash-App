import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  bool _isDeviceConnected = false;
  bool _isInProximity = false;

  bool get isDeviceConnected => _isDeviceConnected;
  bool get isInProximity => _isInProximity;

  void setDeviceConnected(bool value) {
    _isDeviceConnected = value;
    notifyListeners();
  }

  void setInProximity(bool value) {
    _isInProximity = value;
    notifyListeners();
  }
}
