import 'package:flutter/material.dart';
import 'package:sensor_app/services/bluetooth_service.dart';
import 'package:sensor_app/services/theme_service.dart';
import 'theme_notifier.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeService = ThemeService();
  final initialTheme = await themeService.loadTheme();
  runApp(SensorApp(initialTheme: initialTheme));
}

class SensorApp extends StatefulWidget {
  final ThemeData initialTheme;

  const SensorApp({super.key, required this.initialTheme});

  @override
  _SensorAppState createState() => _SensorAppState();
}

class _SensorAppState extends State<SensorApp> {
  late ThemeData _currentTheme;
  final CustomBluetoothService _bluetoothService = CustomBluetoothService(wheelDiameter: 0.7);
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.initialTheme;
  }

  void updateTheme(ThemeData theme) {
    setState(() {
      _currentTheme = theme;
    });
    _themeService.saveTheme(theme == ThemeData.dark());
  }

  @override
  Widget build(BuildContext context) {
    return ThemeNotifier(
      currentTheme: _currentTheme,
      updateTheme: updateTheme,
      child: MaterialApp(
        title: 'Sensor App',
        theme: _currentTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(bluetoothService: _bluetoothService),
          '/history': (context) => HistoryScreen(),
          '/settings': (context) => SettingsScreen(bluetoothService: _bluetoothService),
        },
      ),
    );
  }
}