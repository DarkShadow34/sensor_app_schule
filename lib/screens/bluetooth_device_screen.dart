import 'package:flutter/material.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothDeviceScreen extends StatefulWidget {
  const BluetoothDeviceScreen({super.key});

  @override
  _BluetoothDeviceScreenState createState() => _BluetoothDeviceScreenState();
}

class _BluetoothDeviceScreenState extends State<BluetoothDeviceScreen> {
  final BluetoothClassic bluetoothClassic = BluetoothClassic();
  List<Device> devices = [];
  Device? connectedDevice;
  bool isScanning = false;


  @override
  void initState() {
    super.initState();
    _startScan();
    _requestPermissions();

    bluetoothClassic.onDeviceDiscovered().listen((device) {
      print("Discovered: ${device.name} - ${device.address}");
    });

    bluetoothClassic.onDeviceDataReceived().listen((data) {
      print("Data received: ${String.fromCharCodes(data)}");
    });
  }

 Future<void> _startScan() async {
    try {
      print("Requesting permissions...");
      await _requestPermissions();

      print("Clearing device list...");
      setState(() {
        devices.clear();
      });

      print("Starting scan...");
      await bluetoothClassic.startScan();

      bluetoothClassic.onDeviceDiscovered().listen((device) {
        print("Discovered device: ${device.name ?? 'Unknown'} - ${device.address}");
        setState(() {
          if (!devices.any((d) => d.address == device.address)) {
            devices.add(device);
          }
        });
      });

      Future.delayed(const Duration(seconds: 10), () async {
        await bluetoothClassic.stopScan();
        print("Scan completed. Found ${devices.length} devices.");
      });
    } catch (e) {
      print("Error during scan: $e");
    }
  }



  Future<void> _connectToDevice(Device device) async {
    try {
      await bluetoothClassic.connect(device.address, "00001101-0000-1000-8000-00805f9b34fb");
      setState(() {
        connectedDevice = device;
      });
      print("Connected to ${device.name}");
    } catch (e) {
      print("Error connecting to device: $e");
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.locationWhenInUse.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  }


  @override
  void dispose() {
    bluetoothClassic.stopScan();
    if (connectedDevice != null) {
      bluetoothClassic.disconnect();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Devices'),
        actions: [
          IconButton(
            icon: Icon(isScanning ? Icons.stop : Icons.refresh),
            onPressed: () async {
              if (isScanning) {
                await bluetoothClassic.stopScan();
                setState(() {
                  isScanning = false;
                });
                print("Scan stopped manually.");
              } else {
                setState(() {
                  isScanning = true;
                });
                  await _startScan();
                  setState(() {
                    isScanning = false;
                  }
                );
              }
            },
          ),
        ],
      ),
      body: devices.isEmpty
          ? Center(child: Text('No devices available'))
          : ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return ListTile(
            title: Text(device.name ?? 'Unknown Device'),
            subtitle: Text(device.address),
            trailing: IconButton(
              icon: Icon(Icons.bluetooth),
              onPressed: () => _connectToDevice(device),
            ),
          );
        },
      ),
    );
  }
}