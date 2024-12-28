// lib/widgets/gforce_display.dart
import 'package:flutter/material.dart';

class GForceDisplay extends StatelessWidget {
  final double gForce = 0.0;

  const GForceDisplay({super.key}); // Example value

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.av_timer, color: Colors.red),
        title: Text('G-Force'),
        subtitle: Text('${gForce.toStringAsFixed(2)} G'),
      ),
    );
  }
}
