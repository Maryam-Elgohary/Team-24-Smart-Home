import 'package:flutter/foundation.dart' show kIsWeb; // للتحقق إذا كنا على الـ Web
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart'; // مكتبة تسجيل الصوت
import 'package:permission_handler/permission_handler.dart'; // لإدارة الأذونات

class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  _VoicePageState createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  bool _isRecording = false;
  bool _isKeyboardOpen = false; // متغير عشان نتحكم في إظهار حقل الكتابة
  final TextEditingController _chatController = TextEditingController(); // تحكم في حقل النص
  final FocusNode _chatFocusNode = FocusNode(); // للتحكم في فتح الكيبورد
  FlutterSoundRecorder? _recorder; // كائن لتسجيل الصوت
  List<double> _waveHeights = List.generate(10, (index) => 150.0); // ارتفاعات المستطيلات

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      // تهيئة المسجل فقط لو مش على الـ Web
      _recorder = FlutterSoundRecorder();
      _initRecorder();
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatFocusNode.dispose();
    if (!kIsWeb) {
      _recorder?.closeRecorder();
      _recorder = null;
    }
    super.dispose();
  }

  // تهيئة المسجل وطلب إذن الميكروفون
  Future<void> _initRecorder() async {
    await _recorder!.openRecorder();
    await Permission.microphone.request(); // طلب إذن استخدام الميكروفون
  }

  // بدء التسجيل
  Future<void> _startRecording() async {
    if (_isKeyboardOpen) {
      setState(() {
        _isKeyboardOpen = false;
        _chatFocusNode.unfocus(); // إغلاق الكيبورد
      });
    }

    setState(() {
      _isRecording = true;
      _waveHeights = List.generate(10, (index) => 150.0); // إعادة تعيين الارتفاعات
    });

    if (kIsWeb) {
      // لو على الـ Web، هنعرض المستطيلات بدون تسجيل فعلي
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording is not supported on Web')),
      );
    } else {
      // لو مش على الـ Web، هنسجل فعليًا
      await _recorder!.startRecorder();

      // استقبال بيانات الصوت (Amplitude) وتحديث المستطيلات
      _recorder!.onProgress!.listen((event) {
        if (event.decibels != null) {
          double amplitude = event.decibels!; // مستوى الصوت بالديسيبل
          // تحويل الديسيبل إلى ارتفاع بين 50 و 300
          double height = (amplitude - 40) * 5; // ضبط النطاق بناءً على القيم النموذجية للديسيبل
          height = height.clamp(50, 300); // تحديد الحد الأدنى والأقصى للارتفاع

          setState(() {
            // تحديث ارتفاع المستطيلات بناءً على مستوى الصوت
            _waveHeights = List.generate(10, (index) => height + (index % 2 == 0 ? 50 : 0));
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording...')),
      );
    }
  }

  // إيقاف التسجيل
  Future<void> _stopRecording() async {
    if (_isRecording) {
      if (!kIsWeb) {
        await _recorder!.stopRecorder();
      }
      setState(() {
        _isRecording = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording stopped')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          const Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Text(
              'Hello, Ann',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5857AA),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Text(
              'How Can I Help?',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF5857AA),
              ),
            ),
          ),
          const Spacer(),
          Center(
            child: Column(
              children: [
                // موجات الصوت (تظهر فقط لو الكيبورد مش مفتوح والتسجيل شغال)
                if (!_isKeyboardOpen && _isRecording)
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        10,
                        (index) => Container(
                          width: 40,
                          height: _waveHeights[index], // ارتفاع بناءً على مستوى الصوت
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 221, 220, 220),
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
                // حقل الكتابة (يظهر لما نضغط على أيقونة لو pequحة المفاتيح)
                if (_isKeyboardOpen)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            focusNode: _chatFocusNode, // ربط الـ FocusNode بالـ TextField
                            decoration: InputDecoration(
                              hintText: '',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            if (_chatController.text.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Message sent: ${_chatController.text}'),
                                ),
                              );
                              _chatController.clear();
                              _chatFocusNode.unfocus(); // إغلاق الكيبورد بعد الإرسال
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF5857AA),
                            ),
                            child: const Icon(
                              Icons.send,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // أيقونة الميكروفون (تظهر لما الشات مش مفتوح)
                if (!_isKeyboardOpen)
                  GestureDetector(
                    onTap: _startRecording, // بدء التسجيل
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF5857AA),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic,
                        size: 40,
                        color: Color(0xFF5857AA),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Spacer(),
          // أيقونات Stop ولوحة المفاتيح
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // أيقونة Stop
                GestureDetector(
                  onTap: _stopRecording, // إيقاف التسجيل
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: const Icon(
                      Icons.stop,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                // أيقونة لوحة المفاتيح
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isKeyboardOpen = !_isKeyboardOpen; // فتح/قفل الشات
                      _isRecording = false; // إيقاف التسجيل لو كان شغال
                      if (_isRecording) {
                        _stopRecording(); // إيقاف التسجيل لو شغال
                      }
                      if (_isKeyboardOpen) {
                        _chatFocusNode.requestFocus(); // فتح الكيبورد
                      } else {
                        _chatFocusNode.unfocus(); // إغلاق الكيبورد
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: const Icon(
                      Icons.keyboard,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}