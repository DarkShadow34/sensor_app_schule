import 'package:flutter/material.dart';
import '../services/database_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseService.getAllData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final history = snapshot.data ?? [];
            if (history.isEmpty) {
              return const Center(child: Text('No history available.'));
            }
            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[index];
                return ListTile(
                  title: Text('Lap Time: ${entry['lapTime']}'),
                  subtitle: Text('Speed: ${entry['speed']} km/h, G-Force: ${entry['gForce']} G'),
                  trailing: Text('Date: ${entry['timestamp']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}