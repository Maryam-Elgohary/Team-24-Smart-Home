import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:updated_smart_home/core/helps%20functions/getUserData.dart';
import 'package:updated_smart_home/screans/home/history.dart';
import 'package:updated_smart_home/screans/home/send_notificatios.dart';
import 'package:updated_smart_home/services/ha-api.dart';

class Device {
  final String entityId;
  final String name;
  final String domain;
  final bool isOn;
  final dynamic icon;

  Device({
    required this.entityId,
    required this.name,
    required this.domain,
    required this.isOn,
    required this.icon,
  });
}

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  List<Device> devices = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    try {
      final response = await HomeAssistantApi.getStates();

      final filtered = response.where((e) {
        final entityId = e['entity_id'] as String;
        return entityId.startsWith('light.') ||
            entityId.startsWith('switch.') ||
            entityId.startsWith('input_boolean.') ||
            entityId.startsWith('fan.') ||
            entityId.startsWith('lock.') ||
            entityId.startsWith('media_player.') ||
            entityId.startsWith('climate.') ||
            entityId.startsWith('input_button.');
      }).toList();

      final fetchedDevices = filtered.map<Device>((device) {
        final entityId = device['entity_id'];
        final domain = entityId.split('.').first;
        final attributes = device['attributes'];

        return Device(
          entityId: entityId,
          name: attributes['friendly_name'] ?? entityId,
          domain: domain,
          isOn: device['state'] == 'on',
          icon: _getIconForDomain(domain),
        );
      }).toList();

      setState(() {
        devices = fetchedDevices;
        loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching devices: $e');
      setState(() {
        devices = [];
        loading = false;
      });
    }
  }

  Future<void> toggleDevice(Device device) async {
    final turningOn = !device.isOn;
    final service = turningOn ? 'turn_on' : 'turn_off';

    await HomeAssistantApi.callService(
      domain: device.domain,
      service: service,
      entityId: device.entityId,
    );

    await HistoryService.add(
      type: 'device',
      entityId: device.entityId,
      message: '${device.name} turned ${turningOn ? 'on' : 'off'}',
    );

    fetchDevices();
  }

  dynamic _getIconForDomain(String domain) {
    switch (domain) {
      case 'light':
        return Icons.lightbulb;
      case 'switch':
        return Icons.toggle_on;
      case 'climate':
        return Icons.thermostat;
      case 'media_player':
        return Icons.tv;
      case 'lock':
        return Icons.lock;
      case 'fan':
        return Icons.air;
      default:
        return Icons.device_unknown;
    }
  }

  Widget buildDeviceCard(Device device) {
    return GestureDetector(
      onTap: () => toggleDevice(device),
      child: SizedBox(
        width: (MediaQuery.of(context).size.width - 40) / 2,
        height: 180,
        child: Card(
          shadowColor: Color(0xFF5857AA),
          color: Colors.grey[200], // light grey background
          elevation: device.isOn ? 12 : 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: device.isOn ? Color(0xFF5857AA) : Colors.transparent,
              width: device.isOn ? 2 : 1,
            ), // dark blue border
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                device.icon is IconData
                    ? Icon(
                        device.icon,
                        size: 35,
                        color: device.isOn ? Color(0xff5857AA) : Colors.grey,
                      )
                    : FaIcon(device.icon, size: 35, color: Color(0xff5857AA)),
                const SizedBox(height: 10),
                Text(
                  device.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Switch(
                  value: device.isOn,
                  onChanged: (_) => toggleDevice(device),
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey,
                  trackOutlineColor: MaterialStateProperty.all(
                    Colors.transparent,
                  ),
                  thumbColor: MaterialStateProperty.all(Colors.white),
                  trackColor: MaterialStateProperty.resolveWith(
                    (states) => device.isOn ? Color(0xff5857aa) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final splashColors = [
      Colors.purpleAccent.shade100,
      Colors.tealAccent.shade100,
      Colors.orangeAccent.shade100,
      Colors.greenAccent.shade100,
      Colors.cyanAccent.shade100,
      Colors.pinkAccent.shade100,
    ];

    final iconColors = [
      Colors.purple.shade700,
      Colors.teal.shade700,
      Colors.orange.shade700,
      Colors.green.shade700,
      Colors.cyan.shade700,
      Colors.pink.shade700,
    ];

    return Scaffold(
      backgroundColor: Colors.white, // soft light blue background
      appBar: AppBar(
        title: const Text('Devices'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SendNotificationPage(
                    haUrl: getUser().ha_url,
                    haToken: getUser().ha_token,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : devices.isEmpty
          ? const Center(
              child: Text(
                'No devices found in Home Assistant',
                style: TextStyle(fontSize: 16),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: devices.asMap().entries.map((entry) {
                  final index = entry.key;
                  final device = entry.value;
                  return buildDeviceCard(device);
                }).toList(),
              ),
            ),
    );
  }
}
