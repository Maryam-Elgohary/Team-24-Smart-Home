import 'package:flutter/material.dart';
import 'package:updated_smart_home/core/helps%20functions/getUserData.dart';
import 'package:updated_smart_home/screans/auth/login_screen.dart';
import 'package:updated_smart_home/services/ha-api.dart';

class OtpVerificationPage extends StatefulWidget {
  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    8,
    (index) => TextEditingController(),
  ); // Controllers لكل حقل OTP
  bool _isLoading = false; // متغير لعرض مؤشر التحميل أثناء الـ API call

  @override
  void initState() {
    super.initState();
    _validateApiConfig(); // التحقق من إعدادات الـ API عند بدء الصفحة
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // دالة للتحقق من إعدادات الـ API
  void _validateApiConfig() {
    if (getUser().ha_url == 'YOUR_BASE_URL' ||
        getUser().ha_token == 'YOUR_TOKEN') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please update YOUR_BASE_URL and YOUR_TOKEN in the code.',
            ),
          ),
        );
      });
    }
  }

  // دالة لتجميع رمز الـ OTP من الحقول
  String _getOtpCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  // دالة للتحقق من الـ OTP باستخدام الـ API
  Future<void> _verifyOtp() async {
    final otp = _getOtpCode();

    // التحقق من إن الرمز مش فاضي وطوله 8 أرقام
    if (otp.isEmpty || otp.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 8-digit OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // إظهار مؤشر التحميل
    });

    try {
      final result = await HomeAssistantApi.verifyOtp(otp);

      setState(() {
        _isLoading = false; // إخفاء مؤشر التحميل
      });

      if (result['status'] == 'success') {
        // التحقق نجح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP verified successfully!')),
        );
        // الانتقال إلى صفحة الـ Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else if (result['status'] == 'error') {
        // الرمز غلط
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
      }
    } catch (e) {
      print('OTP Verification Error: $e'); // طباعة الخطأ في الـ Console للتحقق
      setState(() {
        _isLoading = false; // إخفاء مؤشر التحميل
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5857AA)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Otp Verification',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter the Code send to Gmail',
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 45),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                8,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: SizedBox(
                    width: 40,
                    child: Container(
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF5857AA), // Blue glow
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller:
                            _otpControllers[index], // ربط الـ Controller بكل حقل
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white, // Ensure background is white
                        ),
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          // الانتقال للحقل التالي تلقائيًا بعد إدخال رقم
                          if (value.length == 1 && index < 7) {
                            FocusScope.of(context).nextFocus();
                          }
                          // العودة للحقل السابق إذا كان الحقل فاضي
                          if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
            const Text(
              "Don't resend OTP?",
              style: TextStyle(
                fontSize: 22,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            TextButton(
              onPressed: () {
                // Resend code action
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Code resent!')));
              },
              child: const Text(
                "Resend Code",
                style: TextStyle(
                  fontSize: 22,
                  color: Color.fromARGB(255, 59, 59, 114),
                ),
              ),
            ),
            const SizedBox(height: 60),
            _isLoading
                ? const CircularProgressIndicator() // إظهار مؤشر التحميل أثناء الـ API call
                : ElevatedButton(
                    onPressed: _verifyOtp, // استدعاء دالة التحقق
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 59, 59, 114),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 120,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Verify',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
