import 'package:flutter/widgets.dart';
import '../models/game_stats.dart';
import '../services/game_stats_repository.dart';

class GameStatsProvider extends InheritedNotifier<GameStatsNotifier> {
  final GameStatsRepository repository;

  GameStatsProvider({
    super.key,
    required Widget child,
    required this.repository,
  }) : super(notifier: GameStatsNotifier(), child: child) {
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
    if (isWin == isLoss) return; // Either both false (tie) or invalid state
    final current = notifier!.value;
    final updated = isWin
        ? await repository.incrementWin(current)
        : await repository.incrementLoss(current);
    notifier!.value = updated;
  }

  @override
  bool updateShouldNotify(
    covariant InheritedNotifier<GameStatsNotifier> oldWidget,
  ) => true;
}
