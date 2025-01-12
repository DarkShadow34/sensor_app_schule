import 'dart:async';
import 'dart:typed_data';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bluetooth_classic/models/device.dart';

class CustomBluetoothService {
  static final CustomBluetoothService _instance = CustomBluetoothService._internal();
  final BluetoothClassic bluetoothClassic = BluetoothClassic();
  final BehaviorSubject<double> _speedController = BehaviorSubject<double>();
  final BehaviorSubject<double> _accelerationController = BehaviorSubject<double>();
  final StreamController<String> _liveDataController = StreamController<String>.broadcast();
  final List<Map<String, dynamic>> _history = [];
  Timer? _timer;
  int _elapsedTime = 0;
  int _roundCount = 0;
  int _previousLightValue = 0;
  DateTime? _previousTime;
  double wheelDiameter;

  factory CustomBluetoothService({double wheelDiameter = 0.7}) {
    _instance.wheelDiameter = wheelDiameter;
    return _instance;
  }

  CustomBluetoothService._internal() : wheelDiameter = 0.7;

  Stream<double> get speedStream => _speedController.stream;
  Stream<double> get accelerationStream => _accelerationController.stream;
  Stream<String> get liveDataStream => _liveDataController.stream;
  List<Map<String, dynamic>> get history => List.unmodifiable(_history);
  int get roundCount => _roundCount;

  Future<void> startListeningToConnectedDevices() async {
    try {
      await bluetoothClassic.initPermissions();
      final List<Device> bondedDevices = await bluetoothClassic.getPairedDevices();
      for (var device in bondedDevices) {
        await _startListeningToDevice(device);
      }
    } catch (e) {
      print('Error during listening to connected devices: $e');
    }
  }

  Future<void> _startListeningToDevice(Device device) async {
    try {
      await bluetoothClassic.connect(device.address, "00001101-0000-1000-8000-00805f9b34fb");
      bluetoothClassic.onDeviceDataReceived().listen((data) {
        final lightLevel = _parseLightLevel(data);
        _processLightLevel(lightLevel);
      });
    } catch (e) {
      print('Error while listening to device: $e');
    }
  }

  void _processLightLevel(int lightLevel) {
    const int darkThreshold = 200;
    const int lightThreshold = 300;
    const int invalidThreshold = 500;
    final double halfWheelCircumference = (wheelDiameter * 3.14159) / 2;

    if (lightLevel > invalidThreshold) {
      // Ignore invalid light levels
      return;
    }

    final currentTime = DateTime.now();
    if (_previousTime != null) {
      final timeDifference = currentTime.difference(_previousTime!).inMilliseconds / 1000.0;
      final speed = halfWheelCircumference / timeDifference;
      final acceleration = _calculateAcceleration(speed);
      _speedController.add(speed);
      _accelerationController.add(acceleration);
    }
    _previousTime = currentTime;

    if (_previousLightValue < darkThreshold && lightLevel > lightThreshold) {
      _previousLightValue = lightLevel;
    }
  }

  int _parseLightLevel(Uint8List value) {
    return int.parse(String.fromCharCodes(value));
  }

  double _calculateAcceleration(double speed) {
    return speed * 0.2; // Example calculation
  }

  void startRound() {
    _elapsedTime = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _elapsedTime++;
      final hours = (_elapsedTime ~/ 3600).toString().padLeft(2, '0');
      final minutes = ((_elapsedTime % 3600) ~/ 60).toString().padLeft(2, '0');
      final seconds = (_elapsedTime % 60).toString().padLeft(2, '0');
      final formattedTime = '$hours:$minutes:$seconds';
      _liveDataController.add(formattedTime);
    });
  }

  void stopRound() {
    if (_timer != null) {
      _timer!.cancel();
      final hours = (_elapsedTime ~/ 3600).toString().padLeft(2, '0');
      final minutes = ((_elapsedTime % 3600) ~/ 60).toString().padLeft(2, '0');
      final seconds = (_elapsedTime % 60).toString().padLeft(2, '0');
      final formattedTime = '$hours:$minutes:$seconds';

      final roundData = {
        'speed': _speedController.hasValue ? _speedController.value : 0.0,
        'gForce': _accelerationController.hasValue ? _accelerationController.value : 0.0,
        'lapTime': formattedTime,
        'timestamp': DateTime.now().toString(),
      };
      _history.add(roundData);
      _roundCount++;
      _elapsedTime = 0;
      _liveDataController.add(_elapsedTime.toString());
    }
  }

  void dispose() {
    _speedController.close();
    _accelerationController.close();
    _liveDataController.close();
  }
}