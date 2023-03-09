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

  double getZoomFactor(dynamic re) {
    // double screenH = MediaQuery.of(context).size.height;
    // double screenW = MediaQuery.of(context).size.width;
    // int previewH = math.max(imgHt, imgWt);
    // int previewW = math.min(imgHt, imgWt);
    // double xFactor = re['rect']['w'];
    // double yFactor = re['rect']['h'];
    // //add zoom factor by checking if the width and the height of the object correspond to magnified value
    // double reciFactor = math.max(xFactor, yFactor);
    // double zoomFactor = ((1.0 / reciFactor) * 0.8);
    // return zoomFactor >= 1.0 ? zoomFactor : 1.0;
    double x = re['rect']['x'];
    double y = re['rect']['y'];
    double width = re['rect']['w'];
    double height = re['rect']['h'];
    bool fitswd = (x > 0.06) && ((x + width) < 0.94);
    if (width > 0.85 || height > 0.85) return 1.0;
    if (fitswd) return 2.0;
    return 1.0;
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
      controller!.initialize().then((_) {
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
                  controller!.setZoomLevel(1.0);
                  int recognitionIndex = -1;
                  for (int i = 0; i < recognitions.length; i++) {
                    if (recognitions[i]['detectedClass'] == 'tv') {
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
                    double zoomingFactor =
                        getZoomFactor(recognitions[recognitionIndex]);
                    controller!.setZoomLevel(zoomingFactor);
                  } else {
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
