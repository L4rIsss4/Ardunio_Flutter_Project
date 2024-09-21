import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ev Otomasyon Sistemi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BluetoothScreen(),
    );
  }
}

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? hc06Device;
  BluetoothCharacteristic? targetCharacteristic;
  String receivedData = '';
  bool isScanning = false;
  final String targetMacAddress = '98:DA:60:07:E3:34';

  @override
  void initState() {
    super.initState();
    startScan();
  }

  void startScan() {
    setState(() {
      isScanning = true;
    });
    flutterBlue.startScan(timeout: Duration(seconds: 4)).then((_) {
      setState(() {
        isScanning = false;
      });
    });

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.id.id == targetMacAddress) {
          flutterBlue.stopScan();
          connectToDevice(r.device);
          break;
        }
      }
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
    } catch (e) {
      if (e.toString().contains('Başarili bir şekilde bağlanildi')) {
        // Device is already connected
      } else {
        print(e);
      }
    }
    setState(() {
      hc06Device = device;
    });
    discoverServices(device);
  }

  void discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.notify) {
          setState(() {
            targetCharacteristic = characteristic;
          });
          await characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            setState(() {
              receivedData += String.fromCharCodes(value);
            });
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ev Otomasyon Sistemi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Mevcut Veriler:'),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(receivedData, style: TextStyle(fontSize: 16)),
              ),
            ),
            hc06Device == null
                ? isScanning
                    ? CircularProgressIndicator()
                    : Text('Bluetoth Modülü Aranıyor')
                : Text('Bluetooth Modulüne Bağlanildi..'),
            ElevatedButton(
              onPressed: startScan,
              child: Text('Bağlanti Bul'),
            ),
          ],
        ),
      ),
    );
  }
}
