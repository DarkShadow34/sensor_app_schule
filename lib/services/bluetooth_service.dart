import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blueplus;

class BluetoothService {
  final StreamController<String> _liveDataController = StreamController<String>.broadcast();


  blueplus.BluetoothDevice? connectedDevice;

  Stream<String> get liveDataStream => _liveDataController.stream;

  Future<void> autoConnectToDevice() async {
    try {
      // Liste aller gekoppelten Geräte abrufen
      final List<blueplus.BluetoothDevice> connectedDevices = await blueplus.FlutterBluePlus.connectedDevices;
//blueplus.FlutterBluePlus.connectedDevices
      for (var device in connectedDevices) {
        if (_isTargetDevice(device)) {
          print('Connecting to ${device.platformName}...');
          await _connect(device);
          return;
        }
      }

      // Falls kein bereits verbundenes Gerät gefunden wird, nach verfügbaren Geräten scannen
      print('No connected devices found. Scanning...');
      await blueplus.FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

      blueplus.FlutterBluePlus.scanResults.listen((results) async {
        for (blueplus.ScanResult result in results) {
          if (_isTargetDevice(result.device)) {
            print('Found target device: ${result.device.platformName}. Connecting...');
            await _connect(result.device);
            await blueplus.FlutterBluePlus.stopScan();
            return;
          }
        }
      });
    } catch (e) {
      print('Error during auto-connect: $e');
    }
  }

  Future<void> _connect(blueplus.BluetoothDevice device) async {
    try {
      if (device.isConnected) {
        print('Device is already connected.');
      } else {
        await device.connect(autoConnect: false, timeout: const Duration(seconds: 10));
        print('Connected to ${device.platformName}');
      }

      connectedDevice = device;

      // Lesen von Echtzeitdaten vom Gerät starten
      await _startListeningToDevice(device);
    } catch (e) {
      print('Failed to connect to ${device.platformName}: $e');
    }
  }

  Future<void> _startListeningToDevice(blueplus.BluetoothDevice device) async {
    try {
      // Entdecken der Dienste auf dem Gerät
      final List<blueplus.BluetoothService> services = await device.discoverServices();

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.notify) {
            // Starten des Lesens der Echtzeitdaten
            await characteristic.setNotifyValue(true);
            characteristic.lastValueStream.listen((value) {
              final data = String.fromCharCodes(value);
              print('Received data: $data');
              _liveDataController.add(data); // Daten weiterleiten
            });
          }
        }
      }
    } catch (e) {
      print('Error while listening to device: $e');
    }
  }

  bool _isTargetDevice(blueplus.BluetoothDevice device) {
    // Passen Sie dies an Ihren Sensor-Namen an
    return device.platformName.contains('SensorName'); // Beispiel: "MySensor"
  }

  void dispose() {
    _liveDataController.close();
    if (connectedDevice != null) {
      connectedDevice!.disconnect();
    }
  }
}
