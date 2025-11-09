import 'package:flutter/material.dart';
import 'constants.dart' as constants;
import 'components/Drawer/app_drawer.dart';
import 'package:rpc_app/route_generator.dart';

class BaseApp extends StatelessWidget {
  const BaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: constants.appTitle,
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text(constants.appTitle)),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                constants.welcomeMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(constants.descriptionMessage, textAlign: TextAlign.center),
            ],
          ),
        ),
        drawer: const AppDrawer(),
      ),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
