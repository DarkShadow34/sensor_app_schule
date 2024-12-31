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
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    bluetoothService.scanForDevices().whenComplete(() {
      setState(() {
        isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error scanning devices: $error';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Device'),
      ),
      body: Column(
        children: [
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          if (!isLoading && errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                errorMessage!,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          if (!isLoading)
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
                        leading: Icon(Icons.bluetooth, color: Colors.blue),
                        title: Text(device.platformName.isEmpty ? 'Unknown Device' : device.platformName),
                        subtitle: Text(device.remoteId.toString()),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          bluetoothService.connectToDevice(device).catchError((error) {
                            setState(() {
                              errorMessage = 'Error connecting to device: $error';
                            });
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}