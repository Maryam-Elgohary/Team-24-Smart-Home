import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:updated_smart_home/core/helps%20functions/getUserData.dart';
import 'package:updated_smart_home/screans/home/history.dart';
import 'package:updated_smart_home/screans/home/mood_page.dart';
import 'package:updated_smart_home/screans/home/notificationpage.dart';
import 'package:updated_smart_home/screans/rooms/add_room.dart';
import 'package:updated_smart_home/screans/rooms/room_details.dart';
import 'package:updated_smart_home/services/ha-api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> rooms = [
    {
      'name': 'Master Bedroom',
      'route': '/master-bedroom',
      'image': 'assets/images/Master.jpg',
      'devices': 5,
    },
    {
      'name': 'Child Bedroom',
      'route': '/child-bedroom',
      'image': 'assets/images/child.jpg',
      'devices': 4,
    },
    {
      'name': 'Living Room',
      'route': '/living-room',
      'image': 'assets/images/living.jpg',
      'devices': 6,
    },
    {
      'name': 'Kitchen',
      'route': '/kitchen',
      'image': 'assets/images/kitchen.jpg',
      'devices': 5,
    },
    {
      'name': 'Washing Room',
      'route': '/washing-room',
      'image': 'assets/images/washing.jpg',
      'devices': 4,
    },
    {
      'name': 'Bathroom',
      'route': '/bathroom',
      'image': 'assets/images/bathroom.jpg',
      'devices': 4,
    },
    {
      'name': 'Office',
      'route': '/office',
      'image': 'assets/images/Master.jpg',
      'devices': 6,
    },
    {
      'name': 'Guest Room',
      'route': '/guest',
      'image': 'assets/images/guest.jpg',
      'devices': 6,
    },
  ];

  String userName = "Ann"; // القيمة الديفولت
  String userImageUrl =
      "https://thaka.bing.com/th?q=Profile+Logo+Cute&w=120&h=120&c=1&rs=1&qlt=70&o=7&cb=1&dpr=1.5&pid=InlineBlock&rm=3&mkt=en-XA&cc=EG&setlang=en&adlt=strict&t=1&mw=247"; // القيمة الديفولت
  int notificationCount = 3; // مثال لعدد الإشعارات

  int connectedDevices = 0; // عدد الأجهزة من DevicesPage
  double energyUsage = 0.0; // استهلاك الطاقة من EnergyPage

  double? temperature; // درجة الحرارة من ThermostatPage
  @override
  void initState() {
    super.initState();
    _loadDeviceCount();
    _fetchTemperature();

    //_fetchSummaryData();
  }

  // Future<void> _fetchSummaryData() async {
  //   try {
  //     // Placeholder لجلب البيانات من الصفحات
  //     // 1. عدد الأجهزة من DevicesPage
  //     int deviceCount = await _fetchDeviceCount(); // Placeholder
  //     // 2. استهلاك الطاقة من EnergyPage
  //     double energy = await _fetchEnergyUsage(); // Placeholder
  //     // 3. درجة الحرارة من ThermostatPage
  //     double temp = await _fetchTemperature(); // Placeholder

  //     setState(() {
  //       connectedDevices = deviceCount;
  //       energyUsage = energy;
  //       temperature = temp;
  //     });
  //   } catch (e) {
  //     print("Error fetching summary data: $e");
  //     setState(() {
  //       connectedDevices = 108; // قيمة افتراضية لو فشل الجلب
  //       energyUsage = 200.0; // قيمة افتراضية
  //       temperature = 26.0; // قيمة افتراضية
  //     });
  //   }
  // }

  Future<void> _loadDeviceCount() async {
    final count = await HomeAssistantApi().fetchDeviceCount();
    setState(() {
      connectedDevices = count;
    });
  }

  Future<void> _fetchTemperature() async {
    try {
      final temp = await fetchTemperatureByCity('Cairo'); // ممكن تغيّري المدينة
      setState(() {
        temperature = temp;
      });
    } catch (e) {
      print('Error fetching temperature: $e');
    }
  }

  Future<double> _fetchEnergyUsage() async {
    // Placeholder لجلب استهلاك الطاقة من EnergyPage
    // بناءً على الكود السابق لـ EnergyPage، كان فيه totalEnergyConsumption
    // final energyPage = EnergyPage();
    // return energyPage.totalEnergyConsumption;
    return 200.0; // قيمة مؤقتة لحد ما نربطها
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF5857AA);
    final roomsRef = FirebaseFirestore.instance.collection('rooms');
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/profile');
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius:
                                    MediaQuery.sizeOf(context).width *
                                    0.09, // صورة بروفايل أكبر شوية
                                backgroundImage: const NetworkImage(
                                  "https://thaka.bing.com/th?q=Profile+Logo+Cute&w=120&h=120&c=1&rs=1&qlt=70&o=7&cb=1&dpr=1.5&pid=InlineBlock&rm=3&mkt=en-XA&cc=EG&setlang=en&adlt=strict&t=1&mw=247",
                                ),
                                onBackgroundImageError: (_, __) =>
                                    const Icon(Icons.person, size: 16),
                              ),

                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, ${getUser().name.split(" ")[0]}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/family-members',
                                          );
                                        },
                                        child: const Icon(
                                          Icons.person,
                                          size: 20,
                                          color: darkBlue,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Admin',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        FutureBuilder<int>(
                          future: getAdminNotificationCount(getUser().uid),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();
                            final count = snapshot.data!;
                            return Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.notifications,
                                    color: darkBlue,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/notifications',
                                    );
                                  },
                                ),
                                if (count > 0)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Text(
                                        count.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryCard(
                          context,
                          'Energy Usage',
                          '${energyUsage.toStringAsFixed(1)}kwh',
                          Icons.bolt,
                          darkBlue,
                          '/energy-monitoring',
                        ),
                        _buildSummaryCard(
                          context,
                          'Connected Devices',
                          connectedDevices.toString(),
                          Icons.devices,
                          darkBlue,
                          '/devices',
                        ),
                        _buildSummaryCard(
                          context,
                          'Temperature',
                          temperature == null
                              ? '--°C'
                              : '${temperature!.toInt()}°C',
                          Icons.thermostat,
                          darkBlue,
                          '/thermostat',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Rooms',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AddRoomPage()),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: darkBlue),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: const Text(
                                'Add room',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xff5857aa),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: roomsRef
                          .orderBy('created_at', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final rooms = snapshot.data!.docs;

                        if (rooms.isEmpty) {
                          return const Center(
                            child: Text('No rooms added yet.'),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.75,
                                ),
                            itemCount: rooms.length,
                            itemBuilder: (context, index) {
                              final room = rooms[index];
                              final roomId = room.id;

                              return StreamBuilder<QuerySnapshot>(
                                stream: roomsRef
                                    .doc(roomId)
                                    .collection('devices')
                                    .snapshots(),
                                builder: (context, devicesSnapshot) {
                                  int deviceCount = 0;
                                  if (devicesSnapshot.hasData) {
                                    deviceCount =
                                        devicesSnapshot.data!.docs.length;
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => RoomDetailsPage(
                                            roomId: roomId,
                                            roomName: room['room_name'],
                                            roomImage: room['image_url'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: RoomCard(
                                      name: room['room_name'],
                                      imagePath:
                                          room['image_url'] ??
                                          'assets/images/default.png',
                                      roomId: roomId,
                                      deviceCount: deviceCount.toString(),
                                      color: darkBlue,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            BottomAppBar(
              height: 115,
              color: Colors.white,
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.people,
                            color: Color(0xFF5857AA),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/family-members');
                          },
                        ),
                        const Text(
                          'Users',
                          style: TextStyle(fontSize: 12, color: darkBlue),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.history, color: darkBlue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HistoryScreen(),
                              ),
                            );
                          },
                        ),
                        const Text(
                          'History',
                          style: TextStyle(fontSize: 12, color: darkBlue),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MoodPage(
                              switchEntityId: "input_boolean.test_switch",
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.purpleAccent, Colors.blueAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.face_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.auto_mode, color: darkBlue),
                          onPressed: () {
                            Navigator.pushNamed(context, '/automation');
                          },
                        ),
                        const Text(
                          'Automation',
                          style: TextStyle(fontSize: 12, color: darkBlue),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings, color: darkBlue),
                          onPressed: () {
                            Navigator.pushNamed(context, '/profile');
                          },
                        ),
                        const Text(
                          'Settings',
                          style: TextStyle(fontSize: 12, color: darkBlue),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String? route,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
        child: Container(
          height: 150,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 30, color: color),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: color),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RoomCard extends StatefulWidget {
  final String name;
  final String imagePath;
  final String roomId;
  final String deviceCount;
  final Color color;

  const RoomCard({
    super.key,
    required this.name,
    required this.imagePath,
    required this.roomId,
    required this.deviceCount,
    required this.color,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  bool isOpen = true;
  int deviceCount = 0; // متغير لعدد الأجهزة

  @override
  void initState() {
    super.initState();
    deviceCount = int.parse(
      widget.deviceCount,
    ); // تهيئة العدد من البيانات الأولية
  }

  void _updateDeviceCount(int change) {
    setState(() {
      deviceCount = (deviceCount + change)
          .clamp(0, double.infinity)
          .toInt(); // منع العدد من النزول تحت الصفر
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomDetailsPage(
              roomName: widget.name,
              roomImage: widget.imagePath,
              roomId: widget.roomId,
            ),
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9E9E9E).withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        widget.imagePath,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: -5,
                        right: -10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'rename') {
                                final newName = await showDialog<String>(
                                  context: context,
                                  builder: (context) {
                                    String tempName = widget.name;
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: const Text(
                                        'Rename Room',
                                        style: TextStyle(
                                          color: Color(0xff5857aa),
                                        ),
                                      ),
                                      content: TextField(
                                        onChanged: (val) => tempName = val,
                                        decoration: const InputDecoration(
                                          hintText: 'Enter new name',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, null),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Color(0xff5857aa),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, tempName),
                                          child: const Text(
                                            'Save',
                                            style: TextStyle(
                                              color: Color(0xff5857aa),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (newName != null && newName.isNotEmpty) {
                                  await HistoryService.add(
                                    type: 'room',
                                    message:
                                        'You renamed the ${widget.name} to: $newName',
                                  );
                                  // تحديث الاسم في Firestore
                                  await FirebaseFirestore.instance
                                      .collection('rooms')
                                      .doc(widget.roomId)
                                      .update({'room_name': newName});

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Room renamed'),
                                    ),
                                  );
                                }
                              } else if (value == 'delete') {
                                // تأكيد قبل الحذف
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: const Text(
                                      'Delete Room',
                                      style: TextStyle(
                                        color: Color(0xff5857aa),
                                      ),
                                    ),
                                    content: const Text(
                                      'Are you sure you want to delete this room?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Color(0xff5857aa),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await HistoryService.add(
                                    type: 'room',
                                    message:
                                        'You deleted the room: ${widget.name}',
                                  );

                                  await FirebaseFirestore.instance
                                      .collection('rooms')
                                      .doc(widget.roomId)
                                      .delete();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Room deleted'),
                                    ),
                                  );
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'rename',
                                child: Text('Rename'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('rooms')
                            .doc(widget.roomId)
                            .collection('devices')
                            .snapshots(),
                        builder: (context, snapshot) {
                          int count = snapshot.hasData
                              ? snapshot.data!.docs.length
                              : 0;
                          return Text(
                            'Devices: $count',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<double> fetchTemperatureByCity(String cityName) async {
  const apiKey = '393453caa15da409ff3b0a4938a39f21';
  final url = Uri.parse(
    'https://api.openweathermap.org/data/2.5/weather?q=$cityName&units=metric&appid=$apiKey',
  );

  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['main']['temp']; // درجة الحرارة بالـ Celsius
  } else {
    throw Exception('Failed to fetch weather for $cityName');
  }
}
