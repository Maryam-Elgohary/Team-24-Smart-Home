import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:updated_smart_home/models/device.dart';
import 'package:updated_smart_home/models/notification.dart';
import 'package:updated_smart_home/models/user.dart';

class ApiService {
  static const String _baseUrl = 'https://api.smarthome.com';
  String? _token;

  String? get token => _token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<void> signUp(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/signup'),
        headers: _headers,
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201) {
        return;
      } else {
        throw Exception(
          'Failed to sign up: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error during sign up: $e');
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        return User.fromJson(data['user']);
      } else {
        throw Exception(
          'Failed to login: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  Future<User> getUser(String userId) async {
    if (_token == null) {
      throw Exception('No authentication token found. Please login first.');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          'Failed to fetch user: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    if (_token == null) {
      throw Exception('No authentication token found. Please login first.');
    }

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: _headers,
        body: jsonEncode(updates),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update user: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  Future<void> addDevice(Device device) async {
    if (_token == null) {
      throw Exception('No authentication token found. Please login first.');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/devices'),
        headers: _headers,
        body: jsonEncode(device.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception(
          'Failed to add device: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error adding device: $e');
    }
  }

  Future<List<Device>> getDevices(String userId) async {
    if (_token == null) {
      throw Exception('No authentication token found. Please login first.');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/devices?userId=$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Device.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to fetch devices: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching devices: $e');
    }
  }

  Future<List<Notification>> getNotifications(String userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/notifications?userId=$userId'),
      headers: {
        'Authorization': 'Bearer ${_token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Notification.fromJson(json)).toList();
    } else {
      throw Exception('فشل في جلب الإشعارات: ${response.statusCode}');
    }
  }

  Future<List<Map<String, String>>> fetchRooms() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/rooms'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, String>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch rooms');
    }
  }

  Future<void> updateDeviceStatus(String deviceId, bool isOn) async {
    if (_token == null) {
      throw Exception('No authentication token found. Please login first.');
    }

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/devices/$deviceId'),
        headers: _headers,
        body: jsonEncode({'isOn': isOn}),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update device: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error updating device: $e');
    }
  }

  void logout() {
    _token = null;
  }

  static isAuthenticated() {}
}
