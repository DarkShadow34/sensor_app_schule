import 'package:flutter/material.dart';

class ThemeNotifier extends InheritedWidget {
  final ThemeData currentTheme;
  final Function(ThemeData) updateTheme;

  const ThemeNotifier({super.key,
    required this.currentTheme,
    required this.updateTheme,
    required super.child,
  });

  static ThemeNotifier of(BuildContext context) {
    final notifier =
    context.dependOnInheritedWidgetOfExactType<ThemeNotifier>();
    if (notifier == null) {
      debugPrint(
          'ThemeNotifier is not found in the widget tree. Context: $context');
      throw FlutterError('ThemeNotifier is not found in the widget tree.');
    }
    return notifier;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}
