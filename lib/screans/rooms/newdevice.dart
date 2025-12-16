import 'package:flutter/material.dart';
import 'package:updated_smart_home/services/ha-api.dart';

class NewDevicesPage extends StatefulWidget {
  final List<Map<String, String>> devices;
  final String roomId;

  const NewDevicesPage({
    super.key,
    required this.devices,
    required this.roomId,
  });

  @override
  _NewDevicesPageState createState() => _NewDevicesPageState();
}

class _NewDevicesPageState extends State<NewDevicesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Devices'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New devices detected:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.devices.length,
                itemBuilder: (context, index) {
                  final device = widget.devices[index];
                  return Card(
                    color: Colors.grey[300], // اللون الرصاصي للأجهزة الجديدة
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Device Name: ${device['name']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Device ID: ${device['id']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Device Type: ${device['type']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  try {
                                    // استدعاء دالة Block من الـ API
                                    await HomeAssistantApi.blockDevice(
                                      device['id']!,
                                    );
                                    setState(() {
                                      widget.devices.removeAt(
                                        index,
                                      ); // إزالة الجهاز من القائمة
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Device blocked'),
                                      ),
                                    );
                                  } catch (error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error blocking device: $error',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'BLOCK',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    // استدعاء دالة Connect من الـ API
                                    await HomeAssistantApi.connectDevice(
                                      device['id']!,
                                      widget.roomId,
                                    );
                                    setState(() {
                                      widget.devices.removeAt(
                                        index,
                                      ); // إزالة الجهاز من القائمة
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Device connected and added to room ${widget.roomId}',
                                        ),
                                      ),
                                    );
                                  } catch (error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error connecting device: $error',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('CONNECT'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
