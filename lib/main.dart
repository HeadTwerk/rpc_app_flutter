import 'package:flutter/material.dart';
import 'home_app.dart';
import 'state/game_stats_provider.dart';
import 'services/game_stats_repository.dart';

void main() {
  final repo = GameStatsRepository();
  runApp(GameStatsProvider(repository: repo, child: const HomeApp()));
}
