import 'package:flutter/material.dart';
import 'theme_notifier.dart';
import 'screens/home_screen.dart';
import 'screens/device_selection_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const SensorApp());
}

class SensorApp extends StatefulWidget {
  const SensorApp({super.key});

  @override
  _SensorAppState createState() => _SensorAppState();
}

class _SensorAppState extends State<SensorApp> {
  ThemeData _currentTheme = ThemeData.light();

  void updateTheme(ThemeData theme) {
    setState(() {
      _currentTheme = theme;
    });
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
          '/': (context) => const HomeScreen(),
          '/device_selection': (context) => const DeviceSelectionScreen(),
          '/history': (context) => const HistoryScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
