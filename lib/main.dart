import 'package:camera/camera.dart';
import 'package:ccextractor_zoom/screens/gallery.dart';
import 'package:ccextractor_zoom/screens/live_camera_feed.dart';
import 'package:ccextractor_zoom/utils/app_consts.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MaterialApp(
    home: const HomePage(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData.light(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? object;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CCExtractor AI Camera"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: DropdownButtonFormField(
                  value: object,
                  hint: const Text('Select object'),
                  validator: (value) => value == null ? "Required" : null,
                  items: kObjects
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    object = val.toString();
                  }),
            ),
            ButtonTheme(
              minWidth: 160,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  if (object != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LiveFeed(
                          cameras: cameras,
                          object: object!,
                        ),
                      ),
                    );
                  } else {
                    Fluttertoast.showToast(msg: "Select an object");
                  }
                },
                child: const Text(
                  "Open AI camera",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const Gallery()));
        },
        child: const Icon(Icons.image_outlined),
      ),
    );
  }
}
