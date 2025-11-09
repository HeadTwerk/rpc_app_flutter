import 'package:flutter/material.dart';
import "dart:io";
import 'dart:math';
import 'package:rpc_app/components/Game/result.dart';
import 'package:rpc_app/components/Game/reset_button.dart';
import 'package:rpc_app/components/Camera/camera_view.dart';
import 'package:rpc_app/constants.dart';

class GameArea extends StatefulWidget {
  const GameArea({super.key});

  @override
  State<GameArea> createState() => _GameAreaState();
}

class _GameAreaState extends State<GameArea> {
  String? _detectedGesture;
  double? _gestureConfidence;
  String? systemOutput;
  String? playerOutput;
  final Random _random = Random();

  void _resetGesture() {
    setState(() {
      _detectedGesture = null;
      _gestureConfidence = null;
    });
  }

  void _onGestureDetected(String gesture, double confidence) {
    setState(() {
      _detectedGesture = gesture;
      _gestureConfidence = confidence;
      // Map gesture to game choice
      playerOutput = gestureOutputMap[gesture] ?? 'Rock'; // Default to Rock
      // Generate random system choice
      systemOutput = systemChoices[_random.nextInt(systemChoices.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? _detectedGesture != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Result(
                      playeroOuput: playerOutput!,
                      systemOuput: systemOutput!,
                    ),
                    const SizedBox(height: 20),
                    // Show confidence
                    if (_gestureConfidence != null)
                      Text(
                        'Confidence: ${(_gestureConfidence! * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    const SizedBox(height: 30),
                    // Reset button
                    ResetButton(onPressed: _resetGesture),
                  ],
                )
              : CameraView(onGestureDetected: _onGestureDetected)
        : Center(
            child: Text(
              'Camera view is only available on Android devices.',
              style: TextStyle(fontSize: 18, color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
          );
  }
}
