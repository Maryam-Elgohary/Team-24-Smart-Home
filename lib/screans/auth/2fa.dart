import 'dart:async';
import 'package:flutter/material.dart';
import 'package:updated_smart_home/screans/auth/OTPScreen.dart';
import 'package:updated_smart_home/services/ha-api.dart';
class TwoFactorPage extends StatefulWidget {
  const TwoFactorPage({super.key});

  @override
  _TwoFactorPageState createState() => _TwoFactorPageState();
}

class _TwoFactorPageState extends State<TwoFactorPage> {
  final TextEditingController _otpController = TextEditingController();
  String? message;
  Color? messageColor;
  bool _isButtonEnabled = true;
  int _countdown = 30;
  Timer? _timer;

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      setState(() {
        message = 'Please enter the code.';
        messageColor = Colors.red;
      });
      return;
    }

    setState(() {
      _isButtonEnabled = false;
      message = null;
    });

    try {
      // التحقق من الكود باستخدام HomeAssistantApi
      final response = await HomeAssistantApi.verifyOtp(otp);

      if (response['success'] == true) {
        setState(() {
          message = 'Access granted. Welcome back';
          messageColor = Colors.green;
        });
        // الانتقال لصفحة OtpVerificationPage بعد النجاح
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  OtpVerificationPage()),
          );
        });
      } else {
        setState(() {
          message = 'Oops! That code doesn’t seem right. please check and enter it again after 30 seconds.';
          messageColor = Colors.red;
        });
        // بدء العد التنازلي لمدة 30 ثانية
        _startCountdown();
      }
    } catch (e) {
      setState(() {
        message = 'Oops! That code doesn’t seem right. please check and enter it again after 30 seconds.';
        messageColor = Colors.red;
      });
      _startCountdown();
    }
  }

  void _startCountdown() {
    setState(() {
      _countdown = 30;
      _isButtonEnabled = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isButtonEnabled = true;
          message = null; // إعادة تعيين الرسالة بعد انتهاء العد التنازلي
        });
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
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
              'Two-Factor\nAuthentication',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter The Code Sent To\nYour Gmail         ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color.fromARGB(160, 0, 0, 0),
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: TextField(
                controller: _otpController,
                decoration: const InputDecoration(
                  hintText: ' code',
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 20),
            // عرض الرسالة إذا كانت موجودة
            if (message != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  message!,
                  style: TextStyle(
                    color: messageColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isButtonEnabled ? _verifyOtp : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5857AA),
                padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 19),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                _isButtonEnabled ? 'Login' : 'Wait $_countdown s',
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }
}