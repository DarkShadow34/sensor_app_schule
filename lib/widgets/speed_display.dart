// lib/widgets/speed_display.dart
import 'package:flutter/material.dart';

class SpeedDisplay extends StatelessWidget {
  final double speed = 0.0;

  const SpeedDisplay({super.key}); // Example value

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.speed, color: Colors.blue),
        title: Text('Speed'),
        subtitle: Text('${speed.toStringAsFixed(2)} km/h'),
      ),
    );
  }
}
