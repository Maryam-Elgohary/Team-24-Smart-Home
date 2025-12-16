import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:updated_smart_home/services/ha-api.dart';

class FaceIdLoginScreen extends StatefulWidget {
  const FaceIdLoginScreen({super.key});

  @override
  _FaceIdLoginScreenState createState() => _FaceIdLoginScreenState();
}

class _FaceIdLoginScreenState extends State<FaceIdLoginScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String recognitionStatus = "Position your face in the frame";
  Color borderColor = Colors.green; // اللون الافتراضي للحدود
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      _initializeCamera();
    } else {
      setState(() {
        recognitionStatus =
            "Camera permission denied. Please enable it in settings.";
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          recognitionStatus = "No cameras available on this device.";
        });
        return;
      }

      // البحث عن الكاميرا الأمامية
      CameraDescription? frontCamera;
      for (var camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      if (frontCamera == null) {
        setState(() {
          recognitionStatus = "No front camera available.";
        });
        return;
      }

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
      );
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      setState(() {
        recognitionStatus = "Error initializing camera: $e";
      });
    }
  }

  Future<void> _captureAndSendImage() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
      recognitionStatus = "Processing...";
      borderColor = Colors.green; // إعادة تعيين اللون لحد ما يتم التحقق
    });

    try {
      final image = await _cameraController!.takePicture();
      // محاكاة التحقق من الوجه باستخدام HomeAssistantApi
      // استبدلي 'userId' و'image.path' بالقيم الحقيقية
      final response = await HomeAssistantApi.registerFaceId(
        'userId',
        image.path,
      );

      if (response['status'] == 'success') {
        setState(() {
          recognitionStatus = "100% Recognized. Welcome back";
          borderColor = Colors.green;
        });
        // الانتقال للصفحة التالية بعد النجاح (مثلاً الـ HomePage)
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/home');
        });
      } else {
        setState(() {
          recognitionStatus = "Not Recognized, Please try again";
          borderColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        recognitionStatus = "Not Recognized, Please try again";
        borderColor = Colors.red;
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isCameraInitialized
              ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  ),
                )
              : const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            recognitionStatus,
            style: TextStyle(
              color: borderColor, // نستخدم نفس لون الحدود للنص
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isProcessing ? null : _captureAndSendImage,
            child: const Text("Scan Face"),
          ),
        ],
      ),
    );
  }
}
