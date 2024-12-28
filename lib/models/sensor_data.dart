// lib/models/sensor_data.dart
class SensorData {
  final double speed;
  final double gForce;
  final String timestamp;

  SensorData({
    required this.speed,
    required this.gForce,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'speed': speed,
      'gForce': gForce,
      'timestamp': timestamp,
    };
  }

  static SensorData fromMap(Map<String, dynamic> map) {
    return SensorData(
      speed: map['speed'],
      gForce: map['gForce'],
      timestamp: map['timestamp'],
    );
  }
}
