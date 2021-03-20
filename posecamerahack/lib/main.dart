import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CameraApp();
  }
}
class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String imagePath;
  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {

      cameras = availableCameras;
      if (cameras.length > 0) {
        setState(() {
          // 2
          selectedCameraIdx = 1;
        });

        _initCameraController(cameras[selectedCameraIdx]).then((void v) {});
      }else{
        print("No camera available");
      }
    }).catchError((err) {
      // 3
      print('Error: $err.code\nError Message: $err.message');
    });
  }
  Future _initCameraController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    // 3
    controller = CameraController(cameraDescription, ResolutionPreset.high);
    // If the controller is updated then update the UI.
    // 4
    controller.addListener(() {
      // 5
      if (mounted) {
        setState(() {});
      }
      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });
    // 6
    try {
      await controller.initialize();
    } on CameraException catch (e) {
      print("Error");
    }

    if (mounted) {
      setState(() {});
    }
  }
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: CameraPreview(controller),
    );
  }
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
  void _onCapturePressed(context) async {
    try {
      // 1
      final path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.mp4',
      );
      // 2
      await controller.startVideoRecording();
      // 3
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => print(context.size),
      //   ),
      // );
    } catch (e) {
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: Stack(
        children: [
          CameraPreview(controller),
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(onPressed: (){
              _onCapturePressed(context);
            },),
          )
        ],
      ),
    );
  }
}
