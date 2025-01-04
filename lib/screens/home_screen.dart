import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import '../services/database_service.dart';
import '../utils/gforce_calculator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BluetoothService bluetoothService = BluetoothService();
  double speed = 0.0;
  double gForce = 0.0;
  int lapCount = 0;
  String lapTime = '00:00:00';
  Stopwatch stopwatch = Stopwatch();

  void updateSpeed(double newSpeed) {
    setState(() {
      speed = newSpeed;
    });
  }

  @override
  void initState() {
    super.initState();
    DatabaseService.initializeDatabase();
    bluetoothService.liveDataStream.listen((data) {
      setState(() {
        speed = double.tryParse(data) ?? 0.0;
        gForce = GForceCalculator.calculateGForce(speed as String) as double;
      });
    });
  }

  void detectLap() {
    setState(() {
      lapCount++;
      lapTime = stopwatch.elapsed.toString().split('.').first;
      stopwatch.reset();
      stopwatch.start();
    });

    DatabaseService.saveData(
      speed: speed,
      gForce: gForce,
      lapTime: lapTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/history');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              '${speed.toStringAsFixed(2)} km/h',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      'Lap $lapCount',
                      style: const TextStyle(fontSize: 24),
                    ),
                    Text(
                      'Time: $lapTime',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${gForce.toStringAsFixed(2)} G',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: detectLap,
              child: const Text('Simulate Lap Detection'),
            ),
          ],
        ),
      ),
    );
  }
}
