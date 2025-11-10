import 'package:localstore/localstore.dart';
import '../constants.dart' as constants;
import '../models/game_stats.dart';

class GameStatsRepository {
  final Localstore _db = Localstore.instance;

  Future<GameStats> load() async {
    final data = await _db
        .collection(constants.statsCollection)
        .doc(constants.statsDocId)
        .get();
    return GameStats.fromMap(
      data,
      winsKey: constants.statsFieldWins,
      lossesKey: constants.statsFieldLosses,
    );
  }

  Future<GameStats> save(GameStats stats) async {
    await _db
        .collection(constants.statsCollection)
        .doc(constants.statsDocId)
        .set(
          stats.toMap(
            winsKey: constants.statsFieldWins,
            lossesKey: constants.statsFieldLosses,
          ),
        );
    return stats;
  }

  Future<GameStats> incrementWin(GameStats current) async {
    final updated = current.copyWith(wins: current.wins + 1);
    return save(updated);
  }

  Future<GameStats> incrementLoss(GameStats current) async {
    final updated = current.copyWith(losses: current.losses + 1);
    return save(updated);
  }
}
