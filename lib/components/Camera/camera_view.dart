import 'package:flutter/material.dart';
import "dart:io";
import "package:flutter/services.dart";
import 'dart:async';

class CameraView extends StatefulWidget {
  final Function(String gesture, double confidence) onGestureDetected;

  const CameraView({super.key, required this.onGestureDetected});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final Map<String, dynamic> cameraParams = <String, dynamic>{};
  EventChannel? _eventChannel;
  StreamSubscription? _gestureSubscription;

  // @override
  // void dispose() {
  //   _gestureSubscription?.cancel();
  //   super.dispose();
  // }

  void _onPlatformViewCreated(int id) {
    _eventChannel = EventChannel('gesture_recognition_stream_$id');

    // Listen to gesture stream and capture first valid gesture
    _gestureSubscription = _eventChannel!.receiveBroadcastStream().listen((
      dynamic event,
    ) {
      if (event is Map) {
        final gestureName = event['gestureName'] as String?;
        final confidence = event['confidence'] as double?;

        if (gestureName != null && gestureName != 'None') {
          // Notify parent widget about detected gesture
          widget.onGestureDetected(gestureName, confidence ?? 0.0);

          // Cancel subscription immediately after receiving first valid gesture
          // _gestureSubscription?.cancel();
          // _gestureSubscription = null;
        }
      }
    }, onError: (error) {});
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? Container(
            width: 900,
            height: 1600,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent),
            ),
            child: AndroidView(
              viewType: 'cameraView',
              layoutDirection: TextDirection.ltr,
              creationParams: cameraParams,
              creationParamsCodec: const StandardMessageCodec(),
              onPlatformViewCreated: _onPlatformViewCreated,
            ),
          )
        : Center(
            child: Text(
              'Camera view is only available on Android devices.',
              style: TextStyle(fontSize: 18, color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
          );
  }
}
