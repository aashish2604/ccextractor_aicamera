import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ccextractor_zoom/services/image_processing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class PreviewImage extends StatelessWidget {
  final File previewImageFile;
  const PreviewImage({super.key, required this.previewImageFile});

  @override
  Widget build(BuildContext context) {
    Image previewImage = Image.file(
      previewImageFile,
      fit: BoxFit.contain,
    );
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: previewImage,
            ),
          ),
          Positioned(
            bottom: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Discard')),
                  TextButton(
                      onPressed: () async {
                        ImageProcessing()
                            .storeImage(previewImageFile)
                            .then((value) => Navigator.of(context).pop());
                      },
                      child: const Text('Save')),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
