class SensorDataValidator {
  static bool validateSpeed(double speed) {
    return speed >= 0 && speed <= 300; // Example range for speed
  }

  static bool validateAcceleration(double acceleration) {
    return acceleration.abs() <= 50; // Example range for acceleration (m/s²)
  }

  static bool validateData(Map<String, dynamic> data) {
    return validateSpeed(data['speed']) && validateAcceleration(data['acceleration']);
  }
}
