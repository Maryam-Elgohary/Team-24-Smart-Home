import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:updated_smart_home/core/helps%20functions/getUserData.dart';

class HomeAssistantService {
  final String baseUrl;
  final String token;

  HomeAssistantService({required this.baseUrl, required this.token});

  Future<List<Map<String, dynamic>>> fetchRooms() async {
    final url = Uri.parse('${getUser().ha_url}/api/states');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${getUser().ha_token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      // فلترة الأجهزة الخاصة بالمستخدم، مثلاً entities اللي نوعها light أو switch
      List<Map<String, dynamic>> rooms = [];
      for (var entity in data) {
        if (entity['entity_id'].startsWith('light.') ||
            entity['entity_id'].startsWith('switch.')) {
          rooms.add({
            'name':
                entity['attributes']['friendly_name'] ?? entity['entity_id'],
            'entity_id': entity['entity_id'],
            'state': entity['state'],
          });
        }
      }

      return rooms;
    } else {
      throw Exception('Failed to load rooms: ${response.statusCode}');
    }
  }
}
