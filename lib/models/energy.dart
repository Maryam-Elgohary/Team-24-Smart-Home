class EnergyConsumption {
  final String deviceId; 
  final String deviceName; 
  final double kWh; 
  final double percentage; 
  final DateTime timestamp; 

  EnergyConsumption({
    required this.deviceId,
    required this.deviceName,
    required this.kWh,
    required this.percentage,
    required this.timestamp,
  });

  factory EnergyConsumption.fromJson(Map<String, dynamic> json) {
    return EnergyConsumption(
      deviceId: json['device_id'],
      deviceName: json['device_name'],
      kWh: json['kwh'].toDouble(),
      percentage: json['percentage'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'kwh': kWh,
      'percentage': percentage,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class EnergySummary {
  final double totalKWh; // الإجمالي
  final List<EnergyConsumption> devices; // قائمة الأجهزة

  EnergySummary({
    required this.totalKWh,
    required this.devices,
  });

  factory EnergySummary.fromJson(Map<String, dynamic> json) {
    return EnergySummary(
      totalKWh: json['total'].toDouble(),
      devices: (json['devices'] as List)
          .map((device) => EnergyConsumption.fromJson(device))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': totalKWh,
      'devices': devices.map((device) => device.toJson()).toList(),
    };
  }
}