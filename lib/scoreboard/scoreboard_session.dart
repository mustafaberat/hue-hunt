/// Bir oyun turunun skorboard oturumu. Ağ yoksa [top] null kalır.
///
/// [prefetch] son can veya Game Over'da bir kez. Overlay [top]'u dinler.
library;

import 'package:flutter/foundation.dart';

import 'score.dart';
import 'scoreboard_api.dart';

class ScoreboardSession extends ChangeNotifier {
  Future<List<ScoreEntry>>? _top;
  Future<void>? _inflight;

  /// Null = tablo yok (offline veya henüz prefetch yok).
  Future<List<ScoreEntry>>? get top => _top;

  Future<void> prefetch() async {
    if (_top != null) {
      return;
    }
    if (_inflight != null) {
      await _inflight;
      return;
    }

    final task = _openIfOnline();
    _inflight = task;
    await task;

    // Offline kaldıysa Game Over tekrar deneyebilir.
    if (_top == null) {
      _inflight = null;
    }
    notifyListeners();
  }

  Future<void> _openIfOnline() async {
    if (!await ScoreboardApi.isOnline()) {
      return;
    }
    _top = ScoreboardApi.fetchTop();
  }

  void reset() {
    _top = null;
    _inflight = null;
    notifyListeners();
  }

  /// Formu hemen kapatmak için [ScoreSave.board]; POST [synced] içinde.
  ScoreSave save({
    required List<ScoreEntry> board,
    required String name,
    required int level,
  }) {
    final entry = ScoreEntry(name: name, level: level);
    return ScoreSave(
      board: ScoreRules.place(board, entry),
      synced: _confirm(entry),
    );
  }

  static Future<List<ScoreEntry>?> _confirm(ScoreEntry entry) async {
    if (!await ScoreboardApi.isOnline()) {
      return null;
    }
    try {
      final result = await ScoreboardApi.submit(entry);
      return result.accepted ? result.scores : null;
    } catch (_) {
      return null;
    }
  }
}
