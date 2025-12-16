import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/energy.dart';

class EnergyChart extends StatelessWidget {
  final EnergySummary energySummary;

  const EnergyChart({super.key, required this.energySummary});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: energySummary.devices.asMap().entries.map((entry) {
            int index = entry.key;
            EnergyConsumption device = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: device.kWh,
                  color: Colors.primaries[index % Colors.primaries.length],
                  width: 15,
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }
}