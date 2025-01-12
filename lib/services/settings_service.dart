import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _wheelDiameterKey = 'wheel_diameter';

  Future<void> saveWheelDiameter(double diameter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_wheelDiameterKey, diameter);
  }

  Future<double> loadWheelDiameter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_wheelDiameterKey) ?? 0.7; // Default value
  }
}