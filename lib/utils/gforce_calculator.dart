class GForceCalculator {
  static String calculateGForce(String sensorData) {
    // Assuming the sensor data is a numeric string.
    double value = double.tryParse(sensorData) ?? 0;
    double gForce = value / 9.8; // Using Earth's gravity for normalization.
    return gForce.toStringAsFixed(2);
  }
}

