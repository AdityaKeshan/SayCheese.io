import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:posecamerahack/BaseModel.dart';
import 'package:posecamerahack/mine.dart';
import 'package:retrofit/retrofit.dart';
import 'dart:io' as Io;
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
  Dio dio;
  ApiClient apiClient;
  int selectedCameraIdx;
  String imagePath;
  bool rec=false;
  @override
  void initState() {
    super.initState();
    dio=new Dio();
    apiClient=new ApiClient(dio);
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      selectedCameraIdx=0;
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
        setState(() {

        });
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
    super.dispose();
    controller.dispose();
  }
  void _onCapturePressed(context) async {
    try {
      // 1
      final path = join(
        (await getExternalCacheDirectories())[0].path,
        '${DateTime.now()}.jpeg',
      );

      // 2

      XFile image=await controller.takePicture();
      await image.saveTo(path);
      Fluttertoast.showToast(msg: "Saving Image");
      final bytes = Io.File(path).readAsBytesSync();

      String img64 = base64Encode(bytes);
      print("BASE64"+img64);
      String response;
      try{
      response=await apiClient.getInfo(new Post(img:img64 ));
      Fluttertoast.showToast(msg: response);
      }
      catch (error, stacktrace) {
        print("Exception occured: $error stackTrace: $stacktrace");
        Fluttertoast.showToast(msg: "Error occured");
      }


      // Future<BaseModel<String>> ans=await apiClient.getInfo(@Body() new Post(img: img64));
      // image = (await FlutterExifRotation.rotateImage(path: path)) as XFile;
      // Fluttertoast.showToast(msg: "Saving Rotated Image");
      // await image.saveTo(path);

      // 3
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => print(context.size),
      //   ),
      // );
    } catch (e) {

    }
  }
  void buttonpressed(context)
  {
    if(stringButton=='START')
      {
        setState(() {
          stringButton="STOP";
          col=Colors.red;
          k=true;
          Timer.periodic(Duration(seconds:1),(Timer t)=>handleTime(t,context));
        });

      }
    else{
      setState(() {
        stringButton="START";
        col=Colors.blue;
        k=false;
        setState(() {
          time=10;
        });
      });
    }
  }
  bool k=false;//to check if stopped has been pressed
  int time=10;//time for reclicking
  void handleTime(Timer t,context) async
  {
    if(k==false)
      {
        t.cancel();
        return;
      }
    setState(() {
      if(time!=0)
        {
          time=time-1;
        }
      else
        {
          setState(() {
            time=10;
          });
          _onCapturePressed(context);
        }
    });
  }
  Color col=Colors.blue;
  String stringButton="START";
  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: Stack(
        children: [
          CameraPreview(controller),
          Align(alignment:Alignment.topCenter,child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(time.toString(),style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),),
          ),),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ButtonStyle(backgroundColor:MaterialStateProperty.all<Color>(col) ),
                child:Padding(
                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                  child: Text(stringButton
                  ,style: TextStyle(fontSize: 25),),
                )
              ,onPressed: (){
                  buttonpressed(context);
                // capturePressed(context);
              },),
            ),
          )
        ],
      ),
    );
  }
}
