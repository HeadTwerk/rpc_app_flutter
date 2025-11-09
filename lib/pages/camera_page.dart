import 'package:flutter/material.dart';
import "dart:io";
import "package:flutter/services.dart";
import 'package:rpc_app/components/CameraComponents/camera_view.dart';
// import 'package:permission_handler/permission_handler.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  // var _cameraPermissionGranted = false;
  static const cameraPermissionChannel = MethodChannel('camera_permission');
  bool _cameraPermissionGranted = Platform.isAndroid ? false : true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _requestCameraPermission();
    }
  }

  // Future<void> _requestCameraPermission() async {
  //   var status = await Permission.camera.status;
  //   if (!status.isGranted) {
  //     await Permission.camera.request();
  //   }
  //   status = await Permission.camera.status;
  //   setState(() {
  //     _cameraPermissionGranted = status.isGranted;
  //   });
  // }

  Future<void> _requestCameraPermission() async {
    try {
      final bool granted = await cameraPermissionChannel.invokeMethod(
        'getCameraPermission',
      );
      if (granted) {
        setState(() {
          _cameraPermissionGranted = true;
        });
      } else {
        setState(() {
          _cameraPermissionGranted = false;
        });
        debugPrint('Camera permission not granted.');
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to get camera permission: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Page')),
      body: _cameraPermissionGranted
          ? SafeArea(child: const CameraView())
          : SafeArea(
              child: Center(child: Text('Camera permission not granted.')),
            ),
    );
  }
}
