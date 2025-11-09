import 'package:flutter/material.dart';
import 'package:rpc_app/base_app.dart';
import 'package:rpc_app/pages/camera_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const BaseApp());
      case '/camera':
        return MaterialPageRoute(builder: (_) => const CameraPage());
      // Add more cases for other routes as needed
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: Text('Error')),
          body: Center(child: Text('ERROR')),
        );
      },
    );
  }
}
