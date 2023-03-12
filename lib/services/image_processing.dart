import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

class ImageProcessing {
  Future<void> storeImage(File file) async {
    try {
      final fileName = file.path.split('/').last;
      var directory = await getApplicationDocumentsDirectory();
      final File destinationFile = File('${directory.path}/$fileName');
      await file.copy(destinationFile.path);
      Fluttertoast.showToast(msg: 'Image saved successfully');
    } on Exception catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: 'Error occured in saving the image');
    }
  }

  Future<Image?> getPreviewImage() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      int i = 0;
      await directory.list().forEach((element) {
        if (element.path.split('/').last.contains('.')) i++;
      });
      if (i > 0) {
        final fetchedFile = await directory.list().last;
        if (fetchedFile.path.split('/').last.contains('.')) {
          File file = File(fetchedFile.path);
          Image image = Image.file(
            file,
            fit: BoxFit.fill,
          );
          return image;
        }
      }
      return null;
    } on Exception catch (e) {
      Fluttertoast.showToast(msg: "Nothing found");
      return null;
    }
  }
}
