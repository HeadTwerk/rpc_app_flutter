import 'package:flutter/widgets.dart';
import '../models/game_stats.dart';
import '../services/game_stats_repository.dart';
import 'dart:developer' as dev;

class GameStatsProvider extends InheritedNotifier<GameStatsNotifier> {
  final GameStatsRepository repository;

  GameStatsProvider({super.key, required super.child, required this.repository})
    : super(notifier: GameStatsNotifier()) {
    _init();
  }

  static GameStatsProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GameStatsProvider>();
  }

  GameStats get stats => notifier!.value;

  Future<void> _init() async {
    final loaded = await repository.load();
    notifier!.value = loaded; // seed initial stats
  }

  Future<void> recordResult({required bool isWin, required bool isLoss}) async {
    // Guard: ignore ties if both false or both true erroneously
    if (isWin == isLoss) return; // tie or invalid
    final current = notifier!.value;
    try {
      final updated = isWin
          ? await repository.incrementWin(current)
          : await repository.incrementLoss(current);
      notifier!.value = updated;
    } catch (e, st) {
      dev.log(
        'Failed to persist game stats (no in-memory fallback applied): $e',
        stackTrace: st,
        name: 'GameStatsProvider',
      );
    }
  }

  @override
  bool updateShouldNotify(
    covariant InheritedNotifier<GameStatsNotifier> oldWidget,
  ) => true;
}
