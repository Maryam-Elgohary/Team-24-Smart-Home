class Device {
  final String id;
  final String name;
  final String type; // e.g., "light", "thermostat"
  final bool isOn;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.isOn,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'isOn': isOn,
    };
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      isOn: json['isOn'] as bool,
    );
  }
}