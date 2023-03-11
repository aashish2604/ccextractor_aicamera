import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class Gallery extends StatelessWidget {
  const Gallery({super.key});

  @override
  Widget build(BuildContext context) {
    Future<List<File>> getImages() async {
      try {
        List<File> images = [];
        Directory directory = await getApplicationDocumentsDirectory();
        await directory.list().forEach((element) {
          File file = File(element.path);
          // Image imageFile = Image.file(file);
          if (file.path.split('/').last.contains('.')) {
            images.add(file);
          }
        });
        // images.remove(images[0]);
        // images.remove(images[0]);
        return images;
      } on Exception catch (e) {
        Fluttertoast.showToast(msg: "Nothing found");
        return <File>[];
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Captured Images')),
      body: FutureBuilder(
          future: getImages(),
          builder: (context, AsyncSnapshot<List<File>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              final data = snapshot.data;
              if (data == null) {
                return const Center(
                  child: Text("Nothing found"),
                );
              } else {
                if (data.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20.0),
                    child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisExtent: 100.0,
                                mainAxisSpacing: 8),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              OpenFilex.open(data[index].path);
                            },
                            child: SizedBox(
                              child: Image.file(data[index]),
                            ),
                          );
                        }),
                  );
                } else {
                  return const Center(
                    child: Text("Nothing found"),
                  );
                }
              }
            }
            return const Center(
              child: Text('Error'),
            );
          }),
    );
  }
}
