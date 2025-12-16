import 'package:updated_smart_home/models/device.dart';
class User {
  final String id; // معرف فريد للمستخدم
  final String email;
  final String username;
  final String password;
  final String role; // "member" or "admin"
  final String fullName;
  final String? phoneNumber;
  final String? faceId;
  final String? address;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final List<Device>? devices; // قائمة الأجهزة المرتبطة بالمستخدم

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.password,
    required this.role,
    required this.fullName,
    this.phoneNumber,
    this.faceId,
    this.address,
    this.profilePicture,
    required this.createdAt,
    this.lastLogin,
    this.devices,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'password': password,
      'role': role,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'faceId': faceId,
      'address': address,
      'profilePicture': profilePicture,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'devices': devices?.map((device) => device.toJson()).toList(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      role: json['role'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      faceId: json['faceId'] as String?,
      address: json['address'] as String?,
      profilePicture: json['profilePicture'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin'] as String) : null,
      devices: json['devices'] != null
          ? (json['devices'] as List).map((deviceJson) => Device.fromJson(deviceJson)).toList()
          : null,
    );
  }
}