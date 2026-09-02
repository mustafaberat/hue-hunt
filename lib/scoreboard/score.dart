/// Skor kaydı ve tablo kuralları. HTTP bilmez.
///
/// Site `Score` modeli ile aynı anlam: isim + ulaşılan seviye, top-5.
library;

import '../config/app_config.dart';

class ScoreEntry {
  const ScoreEntry({required this.name, required this.level});

  final String name;
  final int level;

  factory ScoreEntry.fromJson(Map<String, dynamic> json) {
    return ScoreEntry(
      name: json[ScoreJson.name] as String,
      level: (json[ScoreJson.level] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    ScoreJson.name: name,
    ScoreJson.level: level,
  };
}

/// POST sonrası sunucu cevabı. [accepted] false ise tablo değişmemiş demektir.
class ScoreSubmitResult {
  const ScoreSubmitResult({required this.scores, required this.accepted});

  final List<ScoreEntry> scores;
  final bool accepted;
}

/// Kaydet: önce yerel tablo, sunucu teyidi ayrı Future.
class ScoreSave {
  const ScoreSave({required this.board, required this.synced});

  final List<ScoreEntry> board;
  final Future<List<ScoreEntry>?> synced;
}

abstract final class ScoreRules {
  static String? parseName(String raw) {
    final name = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (name.length < GameConfig.scoreNameMin ||
        name.length > GameConfig.scoreNameMax) {
      return null;
    }
    if (!GameConfig.scoreNameOk.hasMatch(name)) {
      return null;
    }
    return name;
  }

  /// Dolu değilse herkes; doluysa yalnızca 5. sıradan yüksek level.
  static bool qualifies(List<ScoreEntry> board, int level) {
    if (board.length < GameConfig.scoreboardSize) {
      return true;
    }
    return level > board.last.level;
  }

  /// POST beklemeden tabloya bas: level desc, top-N.
  static List<ScoreEntry> place(List<ScoreEntry> board, ScoreEntry entry) {
    final next = [...board, entry]..sort((a, b) => b.level.compareTo(a.level));
    if (next.length <= GameConfig.scoreboardSize) {
      return next;
    }
    return next.sublist(0, GameConfig.scoreboardSize);
  }
}
