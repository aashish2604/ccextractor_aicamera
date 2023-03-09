import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

typedef Callback = void Function(List<dynamic> list, int h, int w);

class CameraFeed extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  const CameraFeed(this.cameras, this.setRecognitions, {super.key});

  @override
  State<CameraFeed> createState() => _CameraFeedState();
}

class _CameraFeedState extends State<CameraFeed> {
  CameraController? controller;
  bool isDetecting = false;

  double getZoomFactor(dynamic re, double maxZoom) {
    double screenH = MediaQuery.of(context).size.height;
    double screenW = MediaQuery.of(context).size.width;
    double x = re['rect']['x'];
    double y = re['rect']['y'];
    double width = re['rect']['w'];
    double height = re['rect']['h'];
    double boxAspectRatio = width / height;
    double screenAspectRatio = screenW / screenH;
    double zoomFactor = 1.0;
    if (boxAspectRatio > screenAspectRatio) {
      if (x > 0.06 && ((x + width) < 0.94)) zoomFactor = 0.85 / width;
    } else {
      if (y > 0.06 && ((y + height) < 0.94)) zoomFactor = 0.85 / height;
    }
    zoomFactor = math.max(1.0, zoomFactor);
    zoomFactor = math.min(maxZoom, zoomFactor);
    print(zoomFactor);
    return zoomFactor;
  }

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isEmpty) {
      Fluttertoast.showToast(msg: "No cameras found!");
    } else {
      controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
      );
      double maxZoom = 1.0;
      controller!.initialize().then((_) async {
        maxZoom = await controller!.getMaxZoomLevel();
        print(maxZoom);
        if (!mounted) {
          return;
        }
        setState(() {});

        controller!.startImageStream((CameraImage img) {
          try {
            if (!isDetecting) {
              isDetecting = true;
              Tflite.detectObjectOnFrame(
                bytesList: img.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                model: "SSDMobileNet",
                imageHeight: img.height,
                imageWidth: img.width,
                imageMean: 127.5,
                imageStd: 127.5,
                numResultsPerClass: 1,
                threshold: 0.4,
              ).then((recognitions) {
                if (recognitions != null) {
                  bool isfound = false;
                  int recognitionIndex = -1;
                  for (int i = 0; i < recognitions.length; i++) {
                    if (recognitions[i]['detectedClass'] == 'book') {
                      isfound = true;
                      recognitionIndex = i;
                      print(recognitions[i]);
                    }
                  }
                  if (isfound) {
                    widget.setRecognitions(
                        recognitionIndex != -1
                            ? [recognitions[recognitionIndex]]
                            : [],
                        img.height,
                        img.width);
                    double x = recognitions[recognitionIndex]['rect']['x'];
                    double y = recognitions[recognitionIndex]['rect']['y'];
                    double width = recognitions[recognitionIndex]['rect']['w'];
                    double height = recognitions[recognitionIndex]['rect']['h'];
                    double zoomLevel =
                        getZoomFactor(recognitions[recognitionIndex], maxZoom);
                    print('found');
                    controller!.setZoomLevel(zoomLevel);
                  } else {
                    controller!.setZoomLevel(1.0);
                    print('not found');
                    widget.setRecognitions([], img.height, img.width);
                  }

                  isDetecting = false;
                }
              });
            }
          } on CameraException catch (e) {
            Fluttertoast.showToast(msg: e.description ?? "Some error occured");
          }
        });
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller!.value.previewSize!;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller!),
    );
  }
}