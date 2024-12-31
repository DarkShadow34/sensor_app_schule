import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  final StreamController<List<BluetoothDevice>> _devicesController = StreamController<List<BluetoothDevice>>.broadcast();
  final StreamController<String> _liveDataController = StreamController<String>.broadcast();

  final List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? connectedDevice;

  Stream<List<BluetoothDevice>> get devicesStream => _devicesController.stream;
  Stream<String> get liveDataStream => _liveDataController.stream;

  Future<void> scanForDevices() async {
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult scanResult in results) {
        if (!_devicesList.any((device) => device.remoteId == scanResult.device.remoteId)) {
          _devicesList.add(scanResult.device);
          _devicesController.add(_devicesList);
        }
      }
    });

    await FlutterBluePlus.startScan(); // Use await to convert it to a Future.
  }


  Future<void> connectToDevice(BluetoothDevice device) async {
    connectedDevice = device;
    await device.connect();

    // Discover services to find the appropriate characteristic
    var services = await device.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.read) {
          characteristic.lastValueStream.listen((value) {
            String liveData = String.fromCharCodes(value);
            _liveDataController.add(liveData);
          });
          await characteristic.setNotifyValue(true);
          break;
        }
      }
    }
  }

  void dispose() {
    _devicesController.close();
    _liveDataController.close();
    if (connectedDevice != null) {
      connectedDevice!.disconnect();
    }
  }
}
