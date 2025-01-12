import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import '../services/theme_service.dart';
import '../services/settings_service.dart';
import '../theme_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.bluetoothService});

  final CustomBluetoothService bluetoothService;

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _diameterController = TextEditingController();
  final SettingsService _settingsService = SettingsService();
  final ThemeService _themeService = ThemeService();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final diameter = await _settingsService.loadWheelDiameter();
    final theme = await _themeService.loadTheme();
    setState(() {
      _diameterController.text = diameter.toString();
      widget.bluetoothService.wheelDiameter = diameter;
      _isDarkMode = theme == ThemeData.dark();
    });
  }

  bool _validateDiameter(String value) {
    final double? diameter = double.tryParse(value);
    if (diameter == null || diameter <= 0) {
      return false;
    }
    return true;
  }

  Future<void> _updateWheelDiameter() async {
    if (_validateDiameter(_diameterController.text)) {
      final double diameter = double.parse(_diameterController.text);
      setState(() {
        widget.bluetoothService.wheelDiameter = diameter;
      });
      await _settingsService.saveWheelDiameter(diameter);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid wheel diameter.')),
      );
    }
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    final theme = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    ThemeNotifier.of(context).updateTheme(theme);
    _themeService.saveTheme(_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _diameterController,
              decoration: const InputDecoration(
                labelText: 'Wheel Diameter (m)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateWheelDiameter,
              child: const Text('Update Diameter'),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _isDarkMode,
              onChanged: _toggleTheme,
            ),
          ],
        ),
      ),
    );
  }
}