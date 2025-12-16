import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:updated_smart_home/screans/home/history.dart';
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

class RoomDetailsPage extends StatefulWidget {
  final String roomId;
  final String roomName;
  final String roomImage;

  const RoomDetailsPage({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.roomImage,
  });

  @override
  State<RoomDetailsPage> createState() => _RoomDetailsPageState();
}

class _RoomDetailsPageState extends State<RoomDetailsPage> {
  List<Device> devices = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRoomDevices();
  }

  Future<void> fetchRoomDevices() async {
    setState(() => loading = true);
    try {
      // 1. جلب الـ entity IDs من فايربيز
      final snapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .collection('devices')
          .get();

      final entityIds = snapshot.docs.map((doc) => doc.id).toList();

      // 2. جلب بيانات كل جهاز من HA
      final haStates = await HomeAssistantApi.getStates();

      final roomDevices = haStates
          .where((device) {
            return entityIds.contains(device['entity_id']);
          })
          .map((device) {
            final entityId = device['entity_id'];
            final domain = entityId.split('.').first;
            final attributes = device['attributes'];

            return Device(
              entityId: entityId,
              name: attributes?['friendly_name'] ?? entityId,
              domain: domain,
              isOn: device['state'] == 'on',
              icon: _getIconForDomain(domain),
            );
          })
          .toList();

      if (!mounted) return;
      setState(() {
        devices = roomDevices;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        devices = [];
        loading = false;
      });
      debugPrint('Error fetching room devices: $e');
    }
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
      case 'input_boolean':
        return Icons.toggle_on_outlined;
      case 'input_button':
        return FontAwesomeIcons.square;
      default:
        return Icons.device_unknown;
    }
  }

  Future<void> toggleDevice(Device device) async {
    try {
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
        roomId: widget.roomId,
        message: '${device.name} turned ${turningOn ? 'on' : 'off'}',
      );

      fetchRoomDevices();
    } catch (e) {
      debugPrint('Error toggling device: $e');
    }
  }

  Future<void> removeDevice(String entityId) async {
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .collection('devices')
        .doc(entityId)
        .delete();
    fetchRoomDevices();
  }

  Widget buildDeviceCard(Device device) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 40) / 2,
      height: 180,
      child: Card(
        color: Colors.grey[200],
        shadowColor: Color(0xFF5857AA),
        elevation: device.isOn ? 12 : 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: device.isOn ? Color(0xff5857aa) : Colors.transparent,
            width: device.isOn ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
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
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => removeDevice(device.entityId),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.roomName)),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SelectDevicePage(
                roomId: widget.roomId,
                roomName: widget.roomName,
              ),
            ),
          ).then((_) => fetchRoomDevices());
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            widget.roomImage,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 50),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : devices.isEmpty
                ? const Center(
                    child: Text(
                      'No devices yet\nTap + to add devices',
                      textAlign: TextAlign.center,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: devices.map(buildDeviceCard).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class SelectDevicePage extends StatefulWidget {
  final String roomId;
  final String roomName;

  const SelectDevicePage({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<SelectDevicePage> createState() => _SelectDevicePageState();
}

class _SelectDevicePageState extends State<SelectDevicePage> {
  List<dynamic> devices = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => loading = true);
    try {
      // 1. جلب الأجهزة المضافة مسبقًا للروم
      final snapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .collection('devices')
          .get();
      final existingEntityIds = snapshot.docs.map((doc) => doc.id).toSet();

      // 2. جلب كل الأجهزة من HA
      final result = await HomeAssistantApi.getStates();

      // 3. فلترة الأجهزة حسب النوع وحسب إنها مش موجودة مسبقًا
      final filtered = result.where((d) {
        final domain = d['entity_id'].toString().split('.').first;
        final entityId = d['entity_id'].toString();
        return [
              'light',
              'switch',
              'fan',
              'input_boolean',
              'input_button',
            ].contains(domain) &&
            !existingEntityIds.contains(entityId);
      }).toList();

      if (!mounted) return;
      setState(() {
        devices = filtered;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error loading devices')));
    }
  }

  Future<void> addToRoom(String entityId) async {
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .collection('devices')
        .doc(entityId)
        .set({'entity_id': entityId, 'added_at': FieldValue.serverTimestamp()});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Device added to room')));

    // إعادة تحميل الأجهزة المتاحة بعد الإضافة
    _loadDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Device'),
        backgroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : devices.isEmpty
          ? const Center(
              child: Text(
                'No available devices to add',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                final entityId = device['entity_id'];
                final name = device['attributes']?['friendly_name'] ?? entityId;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.add_link),
                      title: Text(name),
                      subtitle: Text(entityId),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Color(0xff5857aa),
                        ),
                        onPressed: () async {
                          addToRoom(entityId);
                          await HistoryService.add(
                            type: 'device',
                            message: 'You added ${name} to ${widget.roomName}',
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
