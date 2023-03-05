import 'package:camera/camera.dart';
import 'package:ccextractor_zoom/realtime/bounding_box.dart';
import 'package:ccextractor_zoom/realtime/camera.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:tflite/tflite.dart';

class LiveFeed extends StatefulWidget {
  final List<CameraDescription> cameras;
  const LiveFeed({super.key, required this.cameras});
  @override
  State<LiveFeed> createState() => _LiveFeedState();
}

class _LiveFeedState extends State<LiveFeed> {
  List<dynamic>? _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  initCameras() async {}
  loadTfModel() async {
    await Tflite.loadModel(
      model: "assets/models/ssd_mobilenet.tflite",
      labels: "assets/models/labels.txt",
    );
  }

  @override
  void initState() {
    super.initState();
    loadTfModel();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Zoom Cam"),
        ),
        body: Center(
          child: const Text('Checking model load'),
        ));
  }
}
