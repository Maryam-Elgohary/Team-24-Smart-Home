import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:updated_smart_home/screans/home/recodedcamera.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class CameraPage extends StatelessWidget {
  final List<String> cameraLocations = [
    "Living room",
    "Master room",
    "Children room",
    "Office",
    "Washing room",
    "Guest room",
    "Kitchen",
    "Front door",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
          ),
          itemCount: cameraLocations.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                border: Border(
                  right: index % 2 == 0 ? const BorderSide(color: Colors.black, width: 2) : BorderSide.none,
                  bottom: const BorderSide(color: Colors.black, width: 2),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Container(), // Placeholder for camera feed
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cameraLocations[index],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(
                            Icons.zoom_out_map,
                            color: Colors.black,
                            size: 16,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CameraViewPage(location: cameraLocations[index]),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class CameraViewPage extends StatefulWidget {
  final String location;

  const CameraViewPage({super.key, required this.location});

  @override
  _CameraViewPageState createState() => _CameraViewPageState();
}

class _CameraViewPageState extends State<CameraViewPage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  // ignore: unused_field
  String? _videoPath;
  String _statusMessage = "Starting camera...";

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    var cameraStatus = await Permission.camera.status;
    var microphoneStatus = await Permission.microphone.status;
    var storageStatus = await Permission.storage.status;

    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
    }
    if (!microphoneStatus.isGranted) {
      microphoneStatus = await Permission.microphone.request();
    }
    if (!storageStatus.isGranted) {
      storageStatus = await Permission.storage.request();
    }

    if (cameraStatus.isGranted && microphoneStatus.isGranted && storageStatus.isGranted) {
      _initializeCamera();
    } else {
      setState(() {
        _statusMessage = "Permissions denied. Please enable camera, microphone, and storage.";
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _statusMessage = "No cameras available on this device.";
        });
        return;
      }

      _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _statusMessage = "Camera ready.";
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error initializing camera: $e";
      });
    }
  }

  Future<void> _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _videoPath = path;
        _statusMessage = "Recording...";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Error starting recording: $e";
      });
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null || !_cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      final file = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _statusMessage = "Recording stopped.";
      });

      // Save the video to a permanent location
      final appDir = await getApplicationDocumentsDirectory();
      final savedPath = '${appDir.path}/recorded_videos/${DateTime.now().millisecondsSinceEpoch}.mp4';
      await Directory('${appDir.path}/recorded_videos').create(recursive: true);
      await File(file.path).copy(savedPath);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlaybackPage(videoPath: savedPath),
        ),
      );
    } catch (e) {
      setState(() {
        _statusMessage = "Error stopping recording: $e";
      });
    }
  }

  Future<void> _takeSnapshot() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/snapshots/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Directory('${directory.path}/snapshots').create(recursive: true);
      final image = await _cameraController!.takePicture();
      await File(image.path).copy(path);
      setState(() {
        _statusMessage = "Snapshot saved at $path";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Error taking snapshot: $e";
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
      appBar: AppBar(
        title: Text("Camera View - ${widget.location}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isCameraInitialized
              ? Container(
                  width: double.infinity,
                  height: 300,
                  child: CameraPreview(_cameraController!),
                )
              : Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
          const SizedBox(height: 16),
          Text(
            _statusMessage,
            style: const TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: () {
                    Navigator.pop(context); // Close the camera view
                  },
                  tooltip: "Close",
                ),
                IconButton(
                  icon: const Icon(Icons.camera, size: 24),
                  onPressed: _isCameraInitialized ? _takeSnapshot : null,
                  tooltip: "Snapshot",
                ),
                IconButton(
                  icon: const Icon(Icons.mic, size: 24),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MicrophonePage(),
                      ),
                    );
                  },
                  tooltip: "Microphone",
                ),
                IconButton(
                  icon: const Icon(Icons.video_library, size: 24),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecordedVideosPage(),
                      ),
                    );
                  },
                  tooltip: "Recorded Videos",
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isRecording ? _stopRecording : _startRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording ? Colors.red : Colors.grey,
                ),
                child: Text(_isRecording ? "Stop" : "Start"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VideoPlaybackPage extends StatefulWidget {
  final String videoPath;

  const VideoPlaybackPage({super.key, required this.videoPath});

  @override
  _VideoPlaybackPageState createState() => _VideoPlaybackPageState();
}

class _VideoPlaybackPageState extends State<VideoPlaybackPage> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _videoController = VideoPlayerController.file(File(widget.videoPath));
    await _videoController!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Playback"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _videoController != null && _videoController!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  )
                : const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                      setState(() {
                        _isPlaying = false;
                      });
                    } else {
                      _videoController!.play();
                      setState(() {
                        _isPlaying = true;
                      });
                    }
                  },
                  child: Text(_isPlaying ? "Pause" : "Play"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Close"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

