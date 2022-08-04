import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'main.dart';
import 'ai.dart';
import 'package:image/image.dart' as img;

class CameraBox extends StatefulWidget {
  static bool paused = false;
  static CameraController? controller;
  const CameraBox({Key? key}) : super(key: key);

  static Future<File> takePic() async {
    XFile f = await controller!.takePicture();
    var path = f.path;
    return File(path);
  }

  static Future initController() async {
    controller = CameraController(cameras[1], ResolutionPreset.medium);
    await controller!.initialize();
  }

  @override
  _CameraBoxState createState() => _CameraBoxState();
}

class _CameraBoxState extends State<CameraBox> {
  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  void dispose() {
    CameraBox.controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!CameraBox.controller!.value.isInitialized) {
      return Container();
    }
    return CameraPreview(CameraBox.controller!);
  }
}
