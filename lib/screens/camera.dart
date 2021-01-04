import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:slx_snitch/models/value.dart';

class CameraScreen extends StatefulWidget {
  final Value value;
  CameraScreen({this.value});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController cameraController;
  List cameras;
  int selectedCameraIndex;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();

    availableCameras().then((value) {
        cameras = value;
        if(cameras.length > 0) {
          selectedCameraIndex = 0;
          initCamera(cameras[selectedCameraIndex]).then((value) {
              _isReady = true;
              setState(() => {});
          });
        } else {
          print('No camera available');
        }
    }).catchError((e) {
        print('Error : $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) return new Container();

    return Scaffold(
      body: new Container(
        child: new CameraPreview(cameraController),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _isReady ? capture : null,
        child: const Icon(
          Icons.camera,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future initCamera(CameraDescription cameraDescription) async {
    if (cameraController != null) {
      await cameraController.dispose();
    }

    cameraController =
    CameraController(cameraDescription, ResolutionPreset.high);

    if (cameraController.value.hasError) {
      print('Camera Error ${cameraController.value.errorDescription}');
    }

    try {
      await cameraController.initialize();
    } catch (e) {
      String errorText = 'Error ${e.code} \nError message: ${e.description}';
    }
  }

  showCameraException(e) {
    String errorText = 'Error ${e.code} \nError message: ${e.description}';
  }

  void capture() {
    cameraController.takePicture().then((value) {
        Uint8List bytes = File(value.path).readAsBytesSync();
        String data = base64Encode(bytes);
        widget.value.update(data);
        Navigator.of(context).pop(false);
    });
  }
}
