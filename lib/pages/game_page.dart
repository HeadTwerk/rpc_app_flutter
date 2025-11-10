import 'package:flutter/material.dart';
import "dart:io";
import "package:flutter/services.dart";
import 'package:rpc_app/components/Game/game_area.dart';
// import 'package:permission_handler/permission_handler.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
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
      appBar: AppBar(title: const Text('Play Gesture Game')),
      body: _cameraPermissionGranted
          ? SafeArea(child: const GameArea())
          : SafeArea(
              child: Center(child: Text('Camera permission not granted.')),
            ),
    );
  }
}
