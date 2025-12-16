import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:updated_smart_home/screans/setup/constant.dart';

class EnergyData {
  final String day;
  final double consumption;
  EnergyData(this.day, this.consumption);
}

class DeviceConsumption {
  final String deviceCategory;
  final double percentage;
  final IconData icon;
  final double energyUsage;
  final String description;
  DeviceConsumption(this.deviceCategory, this.percentage, this.icon, this.energyUsage, this.description);
}

class EnergyPage extends StatefulWidget {
  @override
  _EnergyPageState createState() => _EnergyPageState();
}

class _EnergyPageState extends State<EnergyPage> {
  double totalEnergyConsumption = 0.0;
  List<DeviceConsumption> deviceConsumptions = [];
  List<EnergyData> energyData = [];
  String dateRange = "";
  String currentDayLabel = "";

  // قائمة الأجهزة الثابتة بصفر في البداية
  final List<Map<String, dynamic>> initialDevices = [
    {"category": "HCA", "icon": Icons.ac_unit, "description": "Heating and cooling appliances"},
    {"category": "CFA", "icon": Icons.soup_kitchen, "description": "Cooking and food heating appliances"},
    {"category": "CLA", "icon": Icons.local_laundry_service, "description": "Cleaning and laundry appliances"},
    {"category": "EE", "icon": Icons.sports_esports, "description": "Entertainment and electronics"},
    {"category": "LD", "icon": Icons.light, "description": "Lighting devices"},
    {"category": "PCA", "icon": Icons.air, "description": "Personal care appliances"},
    {"category": "SHS", "icon": Icons.camera_alt, "description": "Smart home and security devices"},
    {"category": "MA", "icon": Icons.power, "description": "Miscellaneous appliances"},
  ];

  String _baseUrl = Constants.baseUrl; // استبدلي بـ IP و Port
  String _apiToken = Constants.token; // استبدلي بـ Token

  @override
  void initState() {
    super.initState();
    setDateRange();
    fetchEnergyData();
    // تهيئة الأجهزة بصفر
    deviceConsumptions = initialDevices.map((device) => DeviceConsumption(
          device["category"],
          0.0,
          device["icon"],
          0.0,
          device["description"],
        )).toList();
    energyData = List.generate(7, (index) {
      return EnergyData(DateFormat('EEE').format(DateTime.now().subtract(Duration(days: 6 - index))), 0.0);
    });
  }

  void setDateRange() {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    String startFormatted = DateFormat('EEE dd MMM').format(startOfWeek);
    String endFormatted = DateFormat('EEE dd MMM').format(endOfWeek);
    dateRange = "$startFormatted - $endFormatted";

    currentDayLabel = DateFormat('EEE dd MMM').format(now);
  }

  Future<void> fetchEnergyData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/states'),
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> entities = jsonDecode(response.body);
        Map<String, double> deviceUsage = {};

        for (var entity in entities) {
          String entityId = entity['entity_id'];
          if (entityId.contains('sensor') && entity['attributes']['unit_of_measurement'] == 'kWh') {
            String deviceName = entity['attributes']['friendly_name'] ?? entityId;
            double usage = double.tryParse(entity['state'].toString()) ?? 0.0;
            // تطابق الاسم مع الفئات الموجودة
            String matchedCategory = initialDevices
                .firstWhere((d) => deviceName.contains(d["category"]),
                    orElse: () => {"category": "MA"})["category"];
            deviceUsage[matchedCategory] = (deviceUsage[matchedCategory] ?? 0.0) + usage;
          }
        }

        setState(() {
          totalEnergyConsumption = deviceUsage.values.reduce((a, b) => a + b);
          deviceConsumptions = initialDevices.map((device) {
            double usage = deviceUsage[device["category"]] ?? 0.0;
            double percentage = totalEnergyConsumption > 0 ? (usage / totalEnergyConsumption) * 100 : 0.0;
            return DeviceConsumption(
              device["category"],
              percentage,
              device["icon"],
              usage,
              device["description"],
            );
          }).toList();
          energyData = List.generate(7, (index) {
            return EnergyData(
              DateFormat('EEE').format(DateTime.now().subtract(Duration(days: 6 - index))),
              deviceUsage.values.isNotEmpty ? deviceUsage.values.reduce((a, b) => a + b) / 7 : 0.0,
            );
          });
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        totalEnergyConsumption = 0.0;
        deviceConsumptions = initialDevices.map((device) => DeviceConsumption(
              device["category"],
              0.0,
              device["icon"],
              0.0,
              device["description"],
            )).toList();
        energyData = List.generate(7, (index) {
          return EnergyData(DateFormat('EEE').format(DateTime.now().subtract(Duration(days: 6 - index))), 0.0);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bolt,
                      color: Color(0xFF5857AA),
                      size: 50,
                      fill: 0.0,
                      weight: 700,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "${totalEnergyConsumption.toStringAsFixed(1)} kWh",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  dateRange,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: energyData.asMap().entries.map((entry) {
                            return FlSpot(entry.key.toDouble(), entry.value.consumption);
                          }).toList(),
                          isCurved: false,
                          color: Color(0xFF5857AA),
                          barWidth: 2,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: 4,
                                  color: const Color.fromARGB(255, 220, 119, 238),
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  energyData[value.toInt()].day,
                                  style: TextStyle(fontSize: 12, color: Colors.black),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            interval: 50,
                            getTitlesWidget: (value, meta) {
                              if (value >= 0 && value <= 350) {
                                return Text(
                                  "${value.toInt()} kWh",
                                  style: TextStyle(fontSize: 12, color: Colors.black),
                                );
                              }
                              return Container();
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true),
                      minY: 0,
                      maxY: 350,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Divider(
                  color: const Color.fromARGB(255, 146, 146, 146),
                  thickness: 2,
                ),
                SizedBox(height: 16),
                Column(
                  children: deviceConsumptions.asMap().entries.map((entry) {
                    var device = entry.value;
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(device.icon, color: Color(0xFF5857AA), size: 40),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        device.deviceCategory,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        "${device.percentage.toStringAsFixed(1)}%",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    device.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: LinearProgressIndicator(
                                      value: device.percentage / 100,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(const Color.fromARGB(255, 220, 119, 238)),
                                      minHeight: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (entry.key < deviceConsumptions.length - 1) ...[
                          SizedBox(height: 16),
                          Divider(
                            color: const Color.fromARGB(255, 172, 171, 171),
                            thickness: 2,
                          ),
                        ],
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}