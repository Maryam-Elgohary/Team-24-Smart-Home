import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:updated_smart_home/services/api_service.dart';

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ApiService _apiService = ApiService();
  bool _isListening = false;
  String _lastCommand = '';

  Future<bool> initialize() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );
    return available;
  }

  Future<String> listen() async {
    if (!_isListening) {
      bool available = await initialize();
      if (available) {
        _isListening = true;
        _speech.listen(
          onResult: (result) {
            _lastCommand = result.recognizedWords;
            print('Recognized command: $_lastCommand');
          },
          listenFor: const Duration(seconds: 10),
          pauseFor: const Duration(seconds: 5),
          localeId: 'en_US', // يمكنك تغيير اللغة حسب الحاجة
        );
      } else {
        throw Exception('Speech recognition not available');
      }
    }

    await Future.delayed(const Duration(seconds: 5));
    _isListening = false;
    _speech.stop();
    return _lastCommand;
  }

  Future<String> processCommand(String command) async {
    if (command.isEmpty) {
      return 'No command recognized';
    }

    command = command.toLowerCase();
    if (command.contains('turn on') && command.contains('lights')) {
      try {
        await _apiService.updateDeviceStatus('light_001', true);
        return 'Lights turned on';
      } catch (e) {
        return 'Failed to turn on lights: $e';
      }
    } else if (command.contains('turn off') && command.contains('lights')) {
      try {
        await _apiService.updateDeviceStatus('light_001', false);
        return 'Lights turned off';
      } catch (e) {
        return 'Failed to turn off lights: $e';
      }
    } else if (command.contains('turn on') && command.contains('thermostat')) {
      try {
        await _apiService.updateDeviceStatus('thermostat_001', true);
        return 'Thermostat turned on';
      } catch (e) {
        return 'Failed to turn on thermostat: $e';
      }
    } else if (command.contains('turn off') && command.contains('thermostat')) {
      try {
        await _apiService.updateDeviceStatus('thermostat_001', false);
        return 'Thermostat turned off';
      } catch (e) {
        return 'Failed to turn off thermostat: $e';
      }
    } else {
      return 'Command not recognized: $command';
    }
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }
}
