import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/database_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> history = [];

  void loadHistory() async {
    await DatabaseService.initializeDatabase();
    history = await DatabaseService.getAllData();
    setState(() {});
  }

  Future<void> exportHistory() async {
    String csvData = 'Speed,G-Force,Lap Time,Timestamp\n';
    for (var entry in history) {
      csvData +=
      '${entry['speed']},${entry['gForce']},${entry['lapTime']},${entry['timestamp']}\n';
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/history.csv');
    await file.writeAsString(csvData);

    Share.shareXFiles([XFile(file.path)], text: 'Sensor Data History');
  }

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: exportHistory,
          ),
        ],
      ),
      body: history.isEmpty
          ? const Center(child: Text('No history available'))
          : ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final entry = history[index];
          return ListTile(
            title: Text('Speed: ${entry['speed']} km/h'),
            subtitle: Text('G-Force: ${entry['gForce']} G\nLap Time: ${entry['lapTime']}'),
            trailing: Text('Time: ${entry['timestamp']}'),
          );
        },
      ),
    );
  }
}
