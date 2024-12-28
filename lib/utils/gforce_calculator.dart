// lib/utils/gforce_calculator.dart
double calculateGForce(double accelX, double accelY, double accelZ) {
  const double gravity = 9.8; // Earth's gravity in m/s²
  return (accelX.abs() + accelY.abs() + accelZ.abs()) / gravity;
}

