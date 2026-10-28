class Device {
  final String name;
  final String id;
  bool isConnected;
  final int? rssi;

  Device({
    required this.name,
    required this.id,
    required this.isConnected,
    this.rssi,
  });
}
