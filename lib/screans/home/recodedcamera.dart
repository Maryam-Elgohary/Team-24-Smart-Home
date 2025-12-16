import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:updated_smart_home/screans/home/cameras_screen.dart';

class RecordedVideosPage extends StatefulWidget {
  @override
  _RecordedVideosPageState createState() => _RecordedVideosPageState();
}

class _RecordedVideosPageState extends State<RecordedVideosPage> {
  List<String> _videoPaths = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final appDir = await getApplicationDocumentsDirectory();
    final videoDir = Directory('${appDir.path}/recorded_videos');
    if (await videoDir.exists()) {
      final files = videoDir.listSync();
      setState(() {
        _videoPaths = files
            .where((file) => file.path.endsWith('.mp4'))
            .map((file) => file.path)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recorded Videos"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        itemCount: _videoPaths.length,
        itemBuilder: (context, index) {
          final videoPath = _videoPaths[index];
          final date = DateTime.fromMillisecondsSinceEpoch(
              int.parse(videoPath.split('/').last.replaceAll('.mp4', '')));
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlaybackPage(videoPath: videoPath),
                ),
              );
            },
            child: Container(
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.play_circle_filled, color: Colors.white, size: 48),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Text(
                      '${date.month}/${date.day}/${date.year}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MicrophonePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Microphone"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          "Microphone functionality to be implemented.",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}