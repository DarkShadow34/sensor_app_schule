import 'dart:async';
import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import '../services/database_service.dart';
import '../utils/gforce_calculator.dart';
import 'bluetooth_device_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.bluetoothService});

  final CustomBluetoothService bluetoothService;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double speed = 0.0;
  double gForce = 0.0;
  int lapCount = 0;
  String lapTime = '00:00:00';
  Stopwatch stopwatch = Stopwatch();
  late Timer timer;
  late Timer lapTimer;
  bool isRoundStopped = false;

  @override
  void initState() {
    super.initState();
    DatabaseService.initializeDatabase();
    widget.bluetoothService.liveDataStream.listen((data) {
      if (!isRoundStopped) {
        setState(() {
          lapTime = data;
        });
      }
    });
    widget.bluetoothService.speedStream.listen((newSpeed) {
      setState(() {
        speed = newSpeed;
        gForce = GForceCalculator.calculateGForce(speed.toString()) as double;
      });
    });
    widget.bluetoothService.startListeningToConnectedDevices();
  }

  void startRound() {
    setState(() {
      lapCount = 0; // Reset lap count
      lapTime = '00:00:00';
      stopwatch.reset();
      stopwatch.start();
      isRoundStopped = false;
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          final elapsed = stopwatch.elapsed;
          final hours = elapsed.inHours.toString().padLeft(2, '0');
          final minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
          final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
          lapTime = '$hours:$minutes:$seconds';
        });
      });
      lapTimer = Timer.periodic(Duration(minutes: 5), (lapTimer) {
        setState(() {
          lapCount++;
        });
      });
    });
    widget.bluetoothService.startRound();
  }

  void stopRound() {
    setState(() {
      stopwatch.stop();
      timer.cancel();
      lapTimer.cancel();
      final elapsed = stopwatch.elapsed;
      final hours = elapsed.inHours.toString().padLeft(2, '0');
      final minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
      lapTime = '$hours:$minutes:$seconds';
      isRoundStopped = true;
      print('StopRound - Elapsed: $elapsed, Hours: $hours, Minutes: $minutes, Seconds: $seconds, LapTime: $lapTime');
    });
    widget.bluetoothService.stopRound();
    DatabaseService.saveData(
      speed: speed,
      gForce: gForce,
      lapTime: lapTime,
    );
  }

  @override
  void dispose() {
    timer.cancel();
    lapTimer.cancel();
    super.dispose();
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
            ListTile(
              leading: const Icon(Icons.bluetooth),
              title: const Text('Bluetooth Devices'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BluetoothDeviceScreen()),
                );
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: startRound,
                  child: const Text('Start Round'),
                ),
                ElevatedButton(
                  onPressed: stopRound,
                  child: const Text('Stop Round'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}