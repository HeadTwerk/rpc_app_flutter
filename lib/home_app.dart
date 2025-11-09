import 'package:flutter/material.dart';
import 'constants.dart' as constants;
import 'components/Drawer/app_drawer.dart';
import 'package:rpc_app/route_generator.dart';
import 'state/game_stats_provider.dart';

class HomeApp extends StatelessWidget {
  const HomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: constants.appTitle,
      theme: ThemeData(useMaterial3: true),
      home: Builder(
        builder: (context) {
          final statsProvider = GameStatsProvider.of(context);
          final stats = statsProvider?.stats;
          return Scaffold(
            appBar: AppBar(title: const Text(constants.appTitle)),
            body: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    constants.welcomeMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    constants.descriptionMessage,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    constants.statsTitle,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  if (stats == null) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    const Text('Loading stats...'),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatCard(
                          label: constants.winsLabel,
                          value: stats.wins.toString(),
                          color: Colors.green,
                        ),
                        const SizedBox(width: 16),
                        _StatCard(
                          label: constants.lossesLabel,
                          value: stats.losses.toString(),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            drawer: const AppDrawer(),
          );
        },
      ),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6), width: 2),
        color: color.withOpacity(0.15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
