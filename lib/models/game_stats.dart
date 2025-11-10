import 'package:flutter/foundation.dart';

class GameStats {
  final int wins;
  final int losses;

  const GameStats({required this.wins, required this.losses});

  GameStats copyWith({int? wins, int? losses}) =>
      GameStats(wins: wins ?? this.wins, losses: losses ?? this.losses);

  Map<String, dynamic> toMap({
    required String winsKey,
    required String lossesKey,
  }) => {winsKey: wins, lossesKey: losses};

  static GameStats fromMap(
    Map<String, dynamic>? map, {
    required String winsKey,
    required String lossesKey,
  }) {
    if (map == null) return const GameStats(wins: 0, losses: 0);
    return GameStats(
      wins: (map[winsKey] as int?) ?? 0,
      losses: (map[lossesKey] as int?) ?? 0,
    );
  }

  @override
  String toString() => 'GameStats(wins: $wins, losses: $losses)';
}

/// Simple notifier wrapper to allow listeners.
class GameStatsNotifier extends ValueNotifier<GameStats> {
  GameStatsNotifier() : super(const GameStats(wins: 0, losses: 0));
}
