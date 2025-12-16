import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:updated_smart_home/screans/home/home.dart';
import 'package:updated_smart_home/screans/setup/constant.dart';

class ThermostatPage extends StatefulWidget {
  const ThermostatPage({super.key});

  @override
  _ThermostatPageState createState() => _ThermostatPageState();
}

class _ThermostatPageState extends State<ThermostatPage>
    with SingleTickerProviderStateMixin {
  double _temperature =
      5.0; // درجة الحرارة الافتراضية (سيتم تحديثها من الـ API)
  bool _isRunning = true; // حالة الثرموستات (تشغيل/إيقاف)
  String _selectedMode = "cooling"; // الوضع الافتراضي
  double _arcAngle = 0.1; // زاوية القوس الابتدائية (بالراديان)
  late AnimationController _animationController; // للتحكم في الدوران
  late Animation<double> _rotationAnimation; // لتأثير الدوران
  bool _isFanOn = false; // حالة المروحة
  String _humidity = '35%'; // قيمة الرطوبة الافتراضية
  double temperature = 0.0;
  // متغيرات الـ API
  final String _baseUrl = Constants.baseUrl;
  final String _token = Constants.token;
  Future<void> _fetchTemperature() async {
    try {
      final temp = await fetchTemperatureByCity('Cairo'); // ممكن تغيّري المدينة
      setState(() {
        temperature = temp;
      });
    } catch (e) {
      print('Error fetching temperature: $e');
    }
    _updateThermostatMode();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_animationController);
    _fetchTemperature();
    _fetchHumidity();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Future<void> _fetchTemperature() async {
  //   try {
  //     final response = await http
  //         .get(
  //           Uri.parse('$_baseUrl/api/states/sensor.room_temperature'),
  //           headers: {
  //             'Authorization': 'Bearer $_token',
  //             'Content-Type': 'application/json',
  //           },
  //         )
  //         .timeout(const Duration(seconds: 15));

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       setState(() {
  //         _temperature = double.parse(data['state']);
  //         _arcAngle = (_temperature / 40) * 2 * pi;
  //         _arcAngle = _arcAngle.clamp(0.1, 2 * pi);
  //       });
  //     } else {
  //       throw Exception(
  //         'Failed to fetch temperature data: ${response.statusCode}',
  //       );
  //     }
  //   } catch (e) {
  //     print('Error fetching temperature: $e');
  //   }
  // }

  Future<void> _fetchHumidity() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/states/sensor.humidity'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _humidity = '${data['state']}%';
        });
      } else {
        throw Exception(
          'Failed to fetch humidity data: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching humidity: $e');
    }
  }

  Future<void> _changeMode(String mode) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/services/climate/set_hvac_mode'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'entity_id': 'climate.thermostat',
              'hvac_mode': mode.toLowerCase(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        setState(() {
          _selectedMode = mode;
        });
      } else {
        throw Exception(
          'Failed to change thermostat mode: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error changing thermostat mode: $e');
    }
  }

  Future<void> _toggleFan(bool turnOn) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '$_baseUrl/api/services/fan/${turnOn ? 'turn_on' : 'turn_off'}',
            ),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'entity_id': 'fan.living_room_fan'}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        setState(() {
          _isFanOn = turnOn;
        });
      } else {
        throw Exception('Failed to control fan: ${response.statusCode}');
      }
    } catch (e) {
      print('Error controlling fan: $e');
    }
  }

  Future<void> _increaseTemperature() async {
    setState(() {
      _temperature += 1;
      _arcAngle += 0.2;
      _arcAngle = _arcAngle.clamp(0.1, 2 * pi);
    });
    _animationController.forward(from: 0);
    await _setTemperature(_temperature);
  }

  Future<void> _decreaseTemperature() async {
    setState(() {
      _temperature -= 1;
      _arcAngle -= 0.2;
      _arcAngle = _arcAngle.clamp(0.1, 2 * pi);
    });
    _animationController.forward(from: 0);
    await _setTemperature(_temperature);
  }

  void _updateThermostatMode() {
    if (!_isRunning) {
      _selectedMode = 'Off';
    } else if (temperature < _temperature - 1) {
      // أقل من الهدف → Heating
      _selectedMode = 'Heating';
    } else if (temperature > _temperature + 1) {
      // أكبر من الهدف → Cooling
      _selectedMode = 'Cooling';
    } else {
      // قريب من الهدف → Dry أو Off
      _selectedMode = 'Dry';
    }

    setState(() {
      _arcAngle = (temperature / 40) * 2 * pi;
      _arcAngle = _arcAngle.clamp(0.1, 2 * pi);
    });
  }

  Future<void> _setTemperature(double temp) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/services/climate/set_temperature'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'entity_id': 'climate.thermostat',
              'temperature': temp,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Failed to update temperature: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating temperature: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Thermostat',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thermostat is running last 3 hrs.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Switch(
                        value: _isRunning,
                        onChanged: (value) {
                          setState(() {
                            _isRunning = value;
                          });
                        },
                        activeColor: const Color(0xFF5857AA),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_temperature.toInt()}°C',
                          style: const TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Room Temperature',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          '${_isRunning
                              ? _temperature > temperature
                                    ? 'Heating'
                                    : _temperature < temperature
                                    ? 'Cooling'
                                    : 'Dry'
                              : 'Off'}',
                          style: TextStyle(
                            fontSize: 18,
                            color: _isRunning ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(250, 250),
                          painter: ArcPainter(
                            startAngle: _rotationAnimation.value,
                            sweepAngle: _arcAngle,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _decreaseTemperature,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.remove,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    GestureDetector(
                      onTap: _increaseTemperature,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _buildOptionButton(
                      'Dry',
                      Icons.air,
                      () => _changeMode('Dry'),
                    ),
                    _buildOptionButton(
                      'Heating',
                      Icons.local_fire_department,
                      () => _changeMode('Heating'),
                    ),
                    _buildOptionButton(
                      'Cooling',
                      Icons.ac_unit,
                      () => _changeMode('Cooling'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOptionButton(
                      'Fan',
                      Icons.toys,
                      () => _toggleFan(!_isFanOn),
                    ),
                    _buildOptionButton(
                      'Humidity\n$_humidity',
                      Icons.water_drop,
                      () {
                        // يمكنك إضافة تحكم إضافي لـ Humidity هنا إذا كان لديك entity_id
                        print('Humidity toggled');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: label.contains(_selectedMode) || (label == 'Fan' && _isFanOn)
              ? const Color(0xFF5857AA)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color:
                  label.contains(_selectedMode) || (label == 'Fan' && _isFanOn)
                  ? Colors.white
                  : Colors.black,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color:
                    label.contains(_selectedMode) ||
                        (label == 'Fan' && _isFanOn)
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArcPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;

  ArcPainter({required this.startAngle, required this.sweepAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
