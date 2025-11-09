import 'package:flutter/material.dart';
import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final Map<String, dynamic> cameraParams = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: <Widget>[
              Container(
                width: 300,
                height: 400,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: AndroidView(
                  viewType: 'cameraView',
                  layoutDirection: TextDirection.ltr,
                  creationParams: cameraParams,
                  creationParamsCodec: const StandardMessageCodec(),
                ),
              ),
            ],
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
