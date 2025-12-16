import 'package:flutter/material.dart';
import 'package:updated_smart_home/models/device.dart';
import 'package:updated_smart_home/services/api_service.dart';

class DeviceCard extends StatefulWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  @override
  _DeviceCardState createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  late bool _isOn;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _isOn = widget.device.isOn;
  }

  IconData _getDeviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'light':
        return Icons.lightbulb;
      case 'thermostat':
        return Icons.thermostat;
      case 'camera':
        return Icons.camera_alt;
      case 'fan':
        return Icons.air;
      default:
        return Icons.device_unknown;
    }
  }

  Color _getIconColor() {
    return _isOn ? Colors.yellow : Colors.grey;
  }

  Future<void> _toggleDevice() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.updateDeviceStatus(widget.device.id, !_isOn);
      setState(() {
        _isOn = !_isOn;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update device: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  _getDeviceIcon(widget.device.type),
                  size: 40,
                  color: _getIconColor(),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.device.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.device.type,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isOn ? 'On' : 'Off',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isOn ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _isLoading
                ? const CircularProgressIndicator()
                : Switch(
                    value: _isOn,
                    onChanged: (value) {
                      _toggleDevice();
                    },
                    activeColor: Colors.blue,
                  ),
          ],
        ),
      ),
    );
  }
}
