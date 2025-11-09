import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Navigation Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('Camera Page'),
            onTap: () {
              Navigator.of(context).pushNamed('/camera');
            },
          ),
          // ListTile(
          //   title: const Text('Item 2'),
          //   onTap: () {
          //     Update the state of the app.
          //     ...
          //   },
        ],
      ),
    );
  }
}
