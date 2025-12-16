import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:updated_smart_home/screans/auth/selectrole.dart';
import 'package:updated_smart_home/screans/home/notificationpage.dart';

// ===== User Login Page =====
class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key});

  @override
  _UserLoginPageState createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final TextEditingController _codeController = TextEditingController();
  bool isLoading = false;

  Future<void> _login() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter the code')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('members')
          .where('password', isEqualTo: code)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid code')));
        setState(() => isLoading = false);
        return;
      }

      final userDoc = snapshot.docs.first;
      final userData = userDoc.data();
      final haUrl = userData['haUrl'] ?? '';
      final haToken = userData['haToken'] ?? '';
      final allowedEntities = List<String>.from(
        userData['allowedEntities'] ?? [],
      );
      final adminID = userData['adminId'] ?? '';

      setState(() => isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserHomePage(
            adminID: userData['adminId'],
            userName: userData['name'],
            haUrl: haUrl,
            haToken: haToken,
            allowedEntities: allowedEntities,
          ),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff5857aa),
          title: const Text(
            'User Login',
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SelectRolePage()),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: FloatingImage()),

              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Enter your code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        child: const Text('Login'),
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            Color(0xff5857aa),
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class FloatingImage extends StatefulWidget {
  @override
  _FloatingImageState createState() => _FloatingImageState();
}

class _FloatingImageState extends State<FloatingImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // مدة الحركة
    )..repeat(reverse: true); // هتخليها تتحرك لفوق ولتحت

    _animation = Tween<double>(
      begin: 0,
      end: 20,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: Image.asset("assets/images/user_login.png", fit: BoxFit.contain),
    );
  }
}

// ===== User Home Page =====
class UserHomePage extends StatefulWidget {
  final String userName;
  final String haUrl;
  final String haToken;
  final List<String> allowedEntities;
  final String adminID;

  const UserHomePage({
    super.key,
    required this.userName,
    required this.haUrl,
    required this.haToken,
    required this.allowedEntities,
    required this.adminID,
  });

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  bool isLoading = true;
  List<Map<String, dynamic>> devices = [];
  late Color myColor;

  @override
  void initState() {
    super.initState();
    fetchAllowedDevices();
    myColor = getRandomColor();
  }

  Future<void> fetchAllowedDevices() async {
    try {
      setState(() => isLoading = true);

      final allDevices = await HomeAssistant.getUserEntities(
        haToken: widget.haToken,
        haUrl: widget.haUrl,
      );

      final filtered = allDevices
          .where((d) => widget.allowedEntities.contains(d['entity_id']))
          .map<Map<String, dynamic>>(
            (d) => {
              'entity_id': d['entity_id'],
              'name': d['attributes']?['friendly_name'] ?? d['entity_id'],
              'state': d['state'] ?? 'off',
            },
          )
          .toList();

      setState(() {
        devices = filtered;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching devices: $e')));
    }
  }

  Future<void> toggleDevice(Map<String, dynamic> device, bool value) async {
    try {
      final domain = device['entity_id'].split('.').first;
      final service = value ? 'turn_on' : 'turn_off';

      await HomeAssistant.callService(
        haUrl: widget.haUrl,
        haToken: widget.haToken,
        domain: domain,
        service: service,
        entityId: device['entity_id'],
      );
      setState(() {
        device['state'] = value ? 'on' : 'off';
      });
      await sendNotification(
        user: widget.userName,
        adminID: widget.adminID,
        message: '${device['name']} turned ${value ? 'ON' : 'OFF'}',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: myColor,
                          child: Text(
                            widget.userName.isNotEmpty
                                ? widget.userName[0].toUpperCase()
                                : '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${widget.userName.split(" ")[0]}',
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
                                    Icons.group,
                                    size: 20,
                                    color: Color(0xff5857aa),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'User',
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
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => UserLoginPage()),
                        );
                      },
                      icon: Icon(Icons.logout, color: Color(0xff5857aa)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                  color: Color(0xff5857aa).withOpacity(0.5),
                  thickness: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Devices',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : devices.isEmpty
                    ? const Center(child: Text('No devices available'))
                    : Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.8,
                              ),
                          itemCount: devices.length,
                          // ===== UserHomePage build GridView items with updated colors =====
                          itemBuilder: (context, index) {
                            final device = devices[index];
                            final isOn = device['state'] == 'on';
                            final customColor = const Color(
                              0xff5857aa,
                            ); // اللون الجديد

                            return Card(
                              shadowColor: customColor,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: isOn
                                      ? customColor
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              color: Colors.grey.shade200,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.devices,
                                      size: 40,
                                      color: isOn ? customColor : Colors.grey,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      device['name'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.transparent,
                                      ),
                                      child: Switch(
                                        value: isOn,
                                        onChanged: (value) =>
                                            toggleDevice(device, value),
                                        activeColor: Colors.white,
                                        inactiveThumbColor: Colors.white,
                                        inactiveTrackColor:
                                            Colors.grey.shade400,
                                        activeTrackColor: customColor,
                                      ),
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
        ),
      ),
    );
  }
}

// ===== Home Assistant API =====
class HomeAssistant {
  static Future<List<dynamic>> getUserEntities({
    required String haUrl,
    required String haToken,
  }) async {
    final headers = {
      'Authorization': 'Bearer $haToken',
      'Content-Type': 'application/json',
    };

    final res = await http.get(
      Uri.parse('$haUrl/api/states'),
      headers: headers,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch states');
    }

    return jsonDecode(res.body);
  }

  static Future<void> callService({
    required String haUrl,
    required String haToken,
    required String domain,
    required String service,
    required String entityId,
  }) async {
    final headers = {
      'Authorization': 'Bearer $haToken',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({'entity_id': entityId});

    final res = await http.post(
      Uri.parse('$haUrl/api/services/$domain/$service'),
      headers: headers,
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to call service');
    }
  }
}

Color getRandomColor() {
  // مولد أرقام عشوائية
  final random = Random();
  return Color.fromARGB(
    255, // Alpha ثابت (شفافية كاملة)
    random.nextInt(256), // Red
    random.nextInt(256), // Green
    random.nextInt(256), // Blue
  );
}
