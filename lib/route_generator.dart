import 'package:flutter/material.dart';
import 'package:rpc_app/home_app.dart';
import 'package:rpc_app/pages/game_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeApp());
      case '/gamePage':
        return MaterialPageRoute(builder: (_) => const GamePage());
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
