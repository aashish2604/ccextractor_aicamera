import 'dart:io';

import 'package:ccextractor_zoom/screens/gallery.dart';
import 'package:ccextractor_zoom/screens/preview_image.dart';
import 'package:ccextractor_zoom/services/image_processing.dart';
import 'package:ccextractor_zoom/services/zoom_smoothener.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

typedef Callback = void Function(List<dynamic> list, int h, int w);

class CameraFeed extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final String object;
  const CameraFeed(this.cameras, this.setRecognitions,
      {super.key, required this.object});

  @override
  State<CameraFeed> createState() => _CameraFeedState();
}

class _CameraFeedState extends State<CameraFeed> {
  CameraController? controller;
  bool isDetecting = false;
  List<double> zoomLevels = [];
  late double finalSmoothenedZoomFactor;
  Image? previewImage;

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
    bool isObjectCentered = x > 0.06 &&
        (x + width) < 0.94 &&
        y > 0.06 &&
        (y + height) < 0.94 &&
        (y + height) > 0.45;
    if (true) {
      if (boxAspectRatio > screenAspectRatio) {
        zoomFactor = 0.85 / width;
      } else {
        zoomFactor = 0.85 / height;
      }
      zoomFactor = math.max(1.0, zoomFactor);
      zoomFactor = math.min(maxZoom, zoomFactor);
      print(zoomFactor);
      zoomLevels.add(zoomFactor);
      double smoothedZoomFactor = smoothZoomLevel(zoomLevels);
      print(smoothedZoomFactor);
      finalSmoothenedZoomFactor = smoothedZoomFactor;
      return smoothedZoomFactor;
    } else {
      return 1.0;
    }
  }

  void initializeCamera() {
    finalSmoothenedZoomFactor = 1.0;
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
        await controller!.setFlashMode(FlashMode.off);
        previewImage = await ImageProcessing().getPreviewImage();
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
                    if (recognitions[i]['detectedClass'] == widget.object) {
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
                    double zoomLevel =
                        getZoomFactor(recognitions[recognitionIndex], maxZoom);
                    controller!.setZoomLevel(zoomLevel);
                  } else {
                    controller!.setZoomLevel(1.0);
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
  void initState() {
    initializeCamera();
    super.initState();
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

    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: OverflowBox(
            maxHeight: screenRatio > previewRatio
                ? screenH
                : screenW / previewW * previewH,
            maxWidth: screenRatio > previewRatio
                ? screenH / previewH * previewW
                : screenW,
            child: CameraPreview(controller!),
          ),
        ),
        Positioned(
          left: 20.0,
          bottom: 20.0,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .push(
                      MaterialPageRoute(builder: (context) => const Gallery()))
                  .then((value) => initializeCamera());
            },
            child: SizedBox(
              height: 60,
              width: 60,
              child: previewImage,
            ),
          ),
        ),
        Positioned(
          bottom: 15,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.black,
                ),
                onPressed: () async {
                  print('taking image');
                  try {
                    // await controller!.initialize();
                    await controller!.stopImageStream();
                    // await controller!.lockCaptureOrientation();
                    await controller!.takePicture().then((value) {
                      // controller!.dispose();
                      // controller!.setFlashMode(FlashMode.off);
                      // controller!.setZoomLevel(finalSmoothenedZoomFactor);
                      File imageFile = File(value.path);
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) =>
                                  PreviewImage(previewImageFile: imageFile)))
                          .then((value) => initializeCamera());
                    });
                  } on CameraException catch (e) {
                    print(e.description);
                  }
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}
