import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:updated_smart_home/screans/setup/constant.dart';

class EnergySavingPage extends StatefulWidget {
  const EnergySavingPage({super.key});

  @override
  _EnergySavingPageState createState() => _EnergySavingPageState();
}

class _EnergySavingPageState extends State<EnergySavingPage> {
  bool _isEcoModeActive = false;
  String _baseUrl = Constants.baseUrl; // استبدلي بـ IP و Port بتاع Home Assistant
  String _apiToken = Constants.token; // استبدلي بـ API Token من Home Assistant
  String _entityId = 'switch.eco_mode'; // استبدلي بـ entity_id الصحيح (مثلاً switch.eco_mode)

  Future<void> _toggleEcoMode(bool isActive) async {
    // التحقق إن الـ entity_id مش فارغ
    if (_entityId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: entity_id is not set. Please configure it.')),
      );
      return;
    }

    try {
      // تكوين الـ URL لتفعيل أو تعطيل الـ Switch
      final url = Uri.parse('$_baseUrl/api/services/switch/turn_${isActive ? 'on' : 'off'}');
      
      // تكوين الطلب
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'entity_id': _entityId, // التأكد إن الـ entity_id بيتبعت
        }),
      );

      // التحقق من الرد
      if (response.statusCode == 200) {
        setState(() {
          _isEcoModeActive = isActive;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ECO Mode ${isActive ? 'activated' : 'deactivated'} successfully')),
        );
      } else {
        // عرض تفاصيل الخطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to toggle ECO Mode. Status: ${response.statusCode}, Body: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      // عرض أي خطأ في الاتصال
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Saving'),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF232344)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Activate ECO Mode',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Switch(
                    value: _isEcoModeActive,
                    onChanged: (value) {
                      _toggleEcoMode(value);
                    },
                    activeColor: const Color(0xFF232344),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ECO Mode helps reduce energy consumption by automatically adjusting device settings like lighting, temperature and appliance usage based on your presence and activity. It ensures your home stays efficient without wasting energy when it isn’t needed.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}