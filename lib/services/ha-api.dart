import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:updated_smart_home/core/helps%20functions/getUserData.dart';
import 'package:updated_smart_home/models/family.dart';

class HomeAssistantApi {
  HomeAssistantApi();

  static Map<String, String> get _headers => {
    'Authorization': 'Bearer ${getUser().ha_token}',
    'Content-Type': 'application/json',
    'Origin': 'http://localhost',
  };

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${getUser().ha_url}/api/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'token': data['token']};
      } else if (response.statusCode == 403) {
        return {'locked': true};
      } else if (response.statusCode == 401) {
        return {'invalidCredentials': true};
      } else {
        throw Exception('فشل تسجيل الدخول: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ في تسجيل الدخول: $e');
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(String otp) async {
    try {
      final response = await http
          .post(
            Uri.parse('${getUser().ha_url}/api/verify-otp'),
            headers: _headers,
            body: jsonEncode({'otp': otp}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': 'success',
          'message': data['message'] ?? 'تم التحقق من الرمز بنجاح',
        };
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        return {'status': 'error', 'message': 'رمز OTP غير صحيح'};
      } else {
        throw Exception(
          'فشل التحقق من الرمز: ${response.statusCode}\n${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ في التحقق من الرمز: $e');
    }
  }

  static Future<Map<String, dynamic>> signUp(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${getUser().ha_url}/api/signup'),
            headers: _headers,
            body: jsonEncode({
              'username': username,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'status': 'success', 'user': data['user']};
      } else {
        throw Exception('فشل التسجيل: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<Map<String, dynamic>> registerFaceId(
    String userId,
    String faceData,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${getUser().ha_url}/api/faceid/register'),
            headers: _headers,
            body: jsonEncode({'userId': userId, 'faceData': faceData}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'message': 'تم تسجيل بصمة الوجه بنجاح للمستخدم $userId',
        };
      } else {
        throw Exception('فشل تسجيل بصمة الوجه: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<Map<String, dynamic>> addLocation(
    String locationName,
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${getUser().ha_url}/api/locations'),
            headers: _headers,
            body: jsonEncode({
              'name': locationName,
              'latitude': latitude,
              'longitude': longitude,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'status': 'success', 'location': data['location']};
      } else {
        throw Exception('فشل إضافة الموقع: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<Map<String, dynamic>> uploadContacts(
    List<Map<String, String>> contacts,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${getUser().ha_url}/api/contacts'),
            headers: _headers,
            body: jsonEncode({'contacts': contacts}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'message': 'تم رفع ${contacts.length} جهة اتصال بنجاح',
        };
      } else {
        throw Exception('فشل رفع جهات الاتصال: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<Map<String, dynamic>> addRoom(String roomName) async {
    try {
      final response = await http
          .post(
            Uri.parse('${getUser().ha_url}/api/rooms'),
            headers: _headers,
            body: jsonEncode({'name': roomName}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'status': 'success', 'room': data['room']};
      } else {
        throw Exception('فشل إضافة الغرفة: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<List<Map<String, String>>> fetchRooms() async {
    try {
      final response = await http
          .get(Uri.parse('${getUser().ha_url}/api/rooms'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map(
              (room) => {
                'name': room['name'].toString(),
                'id': room['id'].toString(),
              },
            )
            .toList();
      } else {
        throw Exception('فشل جلب الغرف: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<void> addDeviceToRoom(
    String roomId,
    Map<String, dynamic> deviceData,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${getUser().ha_url}/api/rooms/$roomId/devices'),
            headers: _headers,
            body: jsonEncode(deviceData),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw Exception(
          'فشل إضافة الجهاز إلى الغرفة: ${response.statusCode}\n${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<List<dynamic>> getDevices(String roomId) async {
    try {
      final response = await http
          .get(Uri.parse('${getUser().ha_url}/api/states'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        List<dynamic> entities = jsonDecode(response.body);
        return entities
            .where((entity) => entity['attributes']['roomId'] == roomId)
            .toList();
      } else {
        throw Exception(
          'فشل جلب الأجهزة: ${response.statusCode}\n${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  // دالة لجلب كل الأجهزة (fetchAllDevices)
  static Future<List<dynamic>> fetchAllDevices() async {
    try {
      final response = await http
          .get(Uri.parse('${getUser().ha_url}/api/states'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data
            .where(
              (device) =>
                  device['entity_id'].startsWith('light') ||
                  device['entity_id'].startsWith('switch') ||
                  device['entity_id'].startsWith('fan') ||
                  device['entity_id'].startsWith('climate') ||
                  device['entity_id'].startsWith('thermostat') ||
                  device['entity_id'].startsWith('tv') ||
                  device['entity_id'].startsWith('lock') ||
                  device['entity_id'].startsWith('blinds') ||
                  device['entity_id'].startsWith('speaker') ||
                  device['entity_id'].startsWith('coffee_maker') ||
                  device['entity_id'].startsWith('camera') ||
                  device['entity_id'].startsWith('microwave') ||
                  device['entity_id'].startsWith('kettle') ||
                  device['entity_id'].startsWith('dishwasher') ||
                  device['entity_id'].startsWith('refrigerator') ||
                  device['entity_id'].startsWith('oven') ||
                  device['entity_id'].startsWith('air_fryer') ||
                  device['entity_id'].startsWith('dryer') ||
                  device['entity_id'].startsWith('washing_machine') ||
                  device['entity_id'].startsWith('water_heater'),
            )
            .toList();
      } else {
        throw Exception(
          'فشل جلب الأجهزة: ${response.statusCode}\n${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<void> toggleDevice(String entityId, bool turnOn) async {
    try {
      String domain;
      if (entityId.startsWith('light')) {
        domain = 'light';
      } else if (entityId.startsWith('switch')) {
        domain = 'switch';
      } else if (entityId.startsWith('fan')) {
        domain = 'fan';
      } else if (entityId.startsWith('climate')) {
        domain = 'climate';
      } else {
        throw Exception('نوع الجهاز غير مدعوم: $entityId');
      }

      final service = turnOn ? 'turn_on' : 'turn_off';
      final response = await http
          .post(
            Uri.parse('${getUser().ha_url}/api/services/$domain/$service'),
            headers: _headers,
            body: jsonEncode({'entity_id': entityId}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'فشل التحكم في الجهاز: ${response.statusCode}\n${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<void> adjustLight(String entityId, int brightness) async {
    try {
      if (!entityId.startsWith('light')) {
        throw Exception('هذا الجهاز ليس مصباحًا: $entityId');
      }

      final response = await http
          .post(
            Uri.parse('${getUser().ha_url}/api/services/light/turn_on'),
            headers: _headers,
            body: jsonEncode({'entity_id': entityId, 'brightness': brightness}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'فشل ضبط النور: ${response.statusCode}\n${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<Map<String, dynamic>> addUser(
    String username,
    String email,
    String role,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${getUser().ha_url}/api/users'),
            headers: _headers,
            body: jsonEncode({
              'username': username,
              'email': email,
              'role': role,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'status': 'success', 'user': data['user']};
      } else {
        throw Exception('فشل إضافة المستخدم: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${getUser().ha_url}/api/users/$userId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'message': 'تم حذف المستخدم $userId بنجاح',
        };
      } else {
        throw Exception('فشل حذف المستخدم: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<Map<String, dynamic>> registerVoice(
    String userId,
    String voiceData,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${getUser().ha_url}/api/voice/register'),
            headers: _headers,
            body: jsonEncode({'userId': userId, 'voiceData': voiceData}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'message': 'تم تسجيل الصوت بنجاح للمستخدم $userId',
        };
      } else {
        throw Exception('فشل تسجيل الصوت: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  // static Future<List<AppNotification>> getNotifications(String userId) async {
  //   try {
  //     final response = await http
  //         .get(
  //           Uri.parse('${getUser().ha_url}/api/notifications?userId=$userId'),
  //           headers: _headers,
  //         )
  //         .timeout(const Duration(seconds: 15));

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = jsonDecode(response.body);
  //       return data.map((json) => AppNotification.fromJson(json)).toList();
  //     } else {
  //       throw Exception('فشل جلب الإشعارات: ${response.statusCode}');
  //     }
  //   } on TimeoutException {
  //     throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
  //   } catch (e) {
  //     throw Exception('خطأ: $e');
  //   }
  // }

  static Future<List<FamilyMember>> getFamilyMembers() async {
    try {
      final response = await http
          .get(Uri.parse('${getUser().ha_url}/api/users'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => FamilyMember.fromJson(json)).toList();
      } else {
        throw Exception('فشل جلب أفراد العائلة: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<Map<String, dynamic>> lockUser(String userId) async {
    try {
      final response = await http
          .post(
            Uri.parse('${getUser().ha_url}/api/users/$userId/lock'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'message': 'تم قفل حساب المستخدم $userId بنجاح',
        };
      } else {
        throw Exception('فشل قفل الحساب: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<Map<String, dynamic>> checkUserStatus(String userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${getUser().ha_url}/api/users/$userId/status'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'status': 'success', 'isLocked': data['isLocked'] ?? false};
      } else {
        throw Exception('فشل التحقق من حالة المستخدم: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getPendingRequests() async {
    try {
      final response = await http
          .get(Uri.parse('${getUser().ha_url}/api/requests'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map(
              (request) => {
                'id': request['id'].toString(),
                'name': request['name'] ?? '',
                'email': request['email'] ?? '',
                'role': request['role'] ?? 'Member',
                'date': request['date'] ?? '',
              },
            )
            .toList();
      } else {
        throw Exception('فشل جلب طلبات الانضمام: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<Map<String, dynamic>> approveRequest(String requestId) async {
    try {
      final response = await http
          .post(
            Uri.parse('${getUser().ha_url}/api/requests/$requestId/approve'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {'status': 'success', 'message': 'تم الموافقة على الطلب بنجاح'};
      } else {
        throw Exception('فشل الموافقة على الطلب: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<Map<String, dynamic>> declineRequest(String requestId) async {
    try {
      final response = await http
          .post(
            Uri.parse('${getUser().ha_url}/api/requests/$requestId/decline'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {'status': 'success', 'message': 'تم رفض الطلب بنجاح'};
      } else {
        throw Exception('فشل رفض الطلب: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<List<Map<String, String>>> scanDevices() async {
    try {
      final response = await http
          .get(
            Uri.parse('${getUser().ha_url}/api/devices/scan'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, String>>.from(
          data.map(
            (device) => {
              'id': device['id'].toString(),
              'name': device['name'].toString(),
              'type': device['type'].toString(),
            },
          ),
        );
      } else {
        throw Exception(
          'فشل السكان للأجهزة: ${response.statusCode}\n${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<void> connectDevice(String deviceId, String roomId) async {
    try {
      final response = await http
          .post(
            Uri.parse('${getUser().ha_url}/api/devices/connect'),
            headers: _headers,
            body: jsonEncode({'device_id': deviceId, 'room_id': roomId}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        await addDeviceToRoom(roomId, {
          'device_id': deviceId,
          'name': 'Device $deviceId',
          'type': 'unknown',
        });
      } else {
        throw Exception(
          'فشل توصيل الجهاز: ${response.statusCode}\n${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<void> blockDevice(String deviceId) async {
    try {
      final response = await http
          .post(
            Uri.parse('${getUser().ha_url}/api/devices/block'),
            headers: _headers,
            body: jsonEncode({'device_id': deviceId}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'فشل منع الجهاز: ${response.statusCode}\n${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<int?> getLightCountForRoom(String room) async {
    try {
      final response = await http
          .get(
            Uri.parse('${getUser().ha_url}/api/states?room=$room'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        List<dynamic> entities = jsonDecode(response.body);
        return entities
            .where((e) => e['entity_id'].startsWith('light.'))
            .length;
      }
      return 0;
    } catch (e) {
      print("Error getting light count: $e");
      return 0;
    }
  }

  static Future<Map<String, dynamic>?> getLightSettings(
    String room,
    int lightNumber,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '${getUser().ha_url}/api/states/light.${room.toLowerCase().replaceAll(' ', '_')}_$lightNumber',
            ),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Error getting light settings: $e");
      return null;
    }
  }

  static Future<void> updateLightState(
    String room,
    int lightNumber,
    bool state,
  ) async {
    try {
      await http
          .post(
            Uri.parse(
              '${getUser().ha_url}/api/services/light/turn_${state ? 'on' : 'off'}',
            ),
            headers: _headers,
            body: jsonEncode({
              'entity_id':
                  'light.${room.toLowerCase().replaceAll(' ', '_')}_$lightNumber',
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      print("Error updating light state: $e");
    }
  }

  static Future<void> updateLightSettings(
    String room,
    int lightNumber,
    Map<String, dynamic> settings,
  ) async {
    try {
      await http
          .post(
            Uri.parse('${getUser().ha_url}/api/services/light/set_attributes'),
            headers: _headers,
            body: jsonEncode({
              'entity_id':
                  'light.${room.toLowerCase().replaceAll(' ', '_')}_$lightNumber',
              'attributes': settings,
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      print("Error updating light settings: $e");
    }
  }

  static Future<void> saveLightSettings(
    String room,
    int lightNumber,
    Map<String, dynamic> settings,
  ) async {
    try {
      await http
          .post(
            Uri.parse('${getUser().ha_url}/api/services/light/save_state'),
            headers: _headers,
            body: jsonEncode({
              'entity_id':
                  'light.${room.toLowerCase().replaceAll(' ', '_')}_$lightNumber',
              'state': settings,
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      print("Error saving light settings: $e");
    }
  }

  static Future<void> scheduleAutomationPause(
    List<String> days,
    TimeOfDay startTime,
    TimeOfDay endTime,
  ) async {
    try {
      final startTimeStr =
          '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
      final endTimeStr =
          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

      final response = await http
          .post(
            Uri.parse('${getUser().ha_url}/api/automation/schedule-pause'),
            headers: _headers,
            body: jsonEncode({
              'days': days,
              'start_time': startTimeStr,
              'end_time': endTimeStr,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'فشل حفظ جدول الأتمتة: ${response.statusCode}\n${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الانتظار: الخادم لم يستجب');
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  static Future<List<dynamic>> getStates() async {
    final res = await http.get(
      Uri.parse('${getUser().ha_url}/api/states'),
      headers: _headers,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch states');
    }

    return jsonDecode(res.body);
  }

  static Future<List<Map<String, dynamic>>> getUserEntities({
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

    final List<dynamic> decoded = jsonDecode(res.body);
    // تحويل كل عنصر إلى Map<String, dynamic>
    return decoded
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<void> callService({
    required String domain,
    required String service,
    required String entityId,
  }) async {
    final res = await http.post(
      Uri.parse('${getUser().ha_url}/api/services/$domain/$service'),
      headers: _headers,
      body: jsonEncode({'entity_id': entityId}),
    );

    if (res.statusCode != 200) {
      throw Exception('Service call failed');
    }
  }

  static Future<void> sendNotification({
    required String haUrl,
    required String haToken,
    required String title,
    required String message,
  }) async {
    final url = Uri.parse('$haUrl/api/services/notify/mobile_app_sm_a566b');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $haToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'title': title, 'message': message}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send notification');
    }
  }

  /// جلب عدد الأجهزة اللي متصلة بالحساب
  Future<int> fetchDeviceCount() async {
    try {
      final response = await http
          .get(
            Uri.parse('${getUser().ha_url}/api/states'),
            headers: {
              'Authorization': 'Bearer ${getUser().ha_token}',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        // تصفية الأجهزة اللي عايزة تحسبيها
        final filtered = data.where((e) {
          final domain = e['entity_id'].split('.').first;
          return [
            'light',
            'switch',
            'climate',
            'media_player',
            'lock',
            'fan',
            'input_boolean',
            'input_button',
          ].contains(domain);
        }).toList();
        return filtered.length;
      } else {
        throw Exception('Failed to fetch devices: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching device count: $e');
      return 0;
    }
  }

  static Future<Map<String, dynamic>> getDevice(String entityId) async {
    final response = await http.get(
      Uri.parse('${getUser().ha_url}/api/states/$entityId'),
      headers: {
        'Authorization': 'Bearer ${getUser().ha_token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to fetch device $entityId: ${response.statusCode}',
      );
    }
  }

  static Future<List<dynamic>> getHistory({required String start}) async {
    final url = Uri.parse('${getUser().ha_url}/history/period/$start');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${getUser().ha_token}'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch history: ${response.body}');
    }
  }

  // تجيب history لجهاز واحد
  static Future<List<dynamic>> getEntityHistory({
    required String entityId,
    required String start,
  }) async {
    final url = Uri.parse(
      '${getUser().ha_url}/history/period/$start?filter_entity_id=$entityId',
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${getUser().ha_token}'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch entity history: ${response.body}');
    }
  }
}
