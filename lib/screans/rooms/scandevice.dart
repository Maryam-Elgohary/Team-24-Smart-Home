import 'package:flutter/material.dart';
import 'package:updated_smart_home/screans/rooms/newdevice.dart';
import 'package:updated_smart_home/screans/rooms/rescan.dart';
import 'package:updated_smart_home/services/ha-api.dart';

class ScanDevicesPage extends StatefulWidget {
  final String roomId; // معرف الغرفة اللي هنضيف فيها الأجهزة

  const ScanDevicesPage({super.key, required this.roomId});

  @override
  _ScanDevicesPageState createState() => _ScanDevicesPageState();
}

class _ScanDevicesPageState extends State<ScanDevicesPage> {
  bool _isScanning = false;
  List<Map<String, String>> _discoveredDevices = [];

  @override
  void initState() {
    super.initState();
    print('Room ID: ${widget.roomId}'); // للتأكد من الـ roomId
    _startScanning();
  }

  Future<void> _startScanning() async {
    setState(() {
      _isScanning = true;
      _discoveredDevices = [];
    });

    try {
      // استدعاء الـ API للسكان
      final devices = await HomeAssistantApi.scanDevices();
      setState(() {
        _discoveredDevices = devices;
        _isScanning = false;
      });

      // لو لقينا أجهزة، نروح لصفحة New Devices
      if (_discoveredDevices.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewDevicesPage(
              devices: _discoveredDevices,
              roomId: widget.roomId,
            ),
          ),
        );
      } else {
        // لو ما لقيناش أجهزة، نروح لـ RescanPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RescanPage()),
        );
      }
    } catch (error) {
      setState(() {
        _isScanning = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error scanning devices: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan for Devices'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: _isScanning
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Scanning for nearby smart devices...',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              )
            : const Text(
                'Scan complete. No devices found.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
      ),
    );
  }
}
