import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blueplus;
import '../services/bluetooth_service.dart';


class DeviceSelectionScreen extends StatefulWidget {
  const DeviceSelectionScreen({super.key});

  @override
  _DeviceSelectionScreenState createState() => _DeviceSelectionScreenState();
}

class _DeviceSelectionScreenState extends State<DeviceSelectionScreen> {
  BluetoothService bluetoothService = BluetoothService();

  @override
  void initState() {
    super.initState();
    bluetoothService.scanForDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Device'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<blueplus.BluetoothDevice>>(
              stream: bluetoothService.devicesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No devices found'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    blueplus.BluetoothDevice device = snapshot.data![index];
                    return ListTile(
                      title: Text(device.platformName.isEmpty ? 'Unknown Device' : device.platformName),
                      subtitle: Text(device.remoteId.toString()),
                      onTap: () => bluetoothService.connectToDevice(device),
                    );
                  },
                );
              },
            ),
          ),
          StreamBuilder<String>(
            stream: bluetoothService.liveDataStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text('Connected to: ${bluetoothService.connectedDevice?.platformName ?? 'Unknown'}'),
                      SizedBox(height: 10),
                      Text('Live Data: ${snapshot.data!}'),
                    ],
                  ),
                );
              } else {
                return SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }
}