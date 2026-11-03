/// Saf oyun durumu. Animasyon / seçili kutu UI katmanında kalır.
library;

import '../color/rgb.dart';

enum GameStatus { playing, success, failed, gameOver }

class GameState {
  const GameState({
    required this.level,
    required this.lives,
    required this.columns,
    required this.rows,
    required this.baseColor,
    required this.differentColor,
    required this.differentIndex,
    required this.status,
    this.wrongIndexes = const {},
    this.correctCount = 0,
    this.wrongCount = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
  });

  final int level;
  final int lives;
  final int columns;
  final int rows;
  final Rgb baseColor;
  final Rgb differentColor;

  /// Farklı rengin grid index'i. Her round yeniden random seçilir.
  final int differentIndex;
  final GameStatus status;

  /// Bu round'da yanlış basılan kutular. Aynı kutuya tekrar basmak can yakmaz.
  final Set<int> wrongIndexes;
  final int correctCount;
  final int wrongCount;
  final int currentStreak;
  final int bestStreak;

  int get totalAttempts => correctCount + wrongCount;

  double get accuracy =>
      totalAttempts == 0 ? 0 : correctCount / totalAttempts;

  int get boxCount => columns * rows;

  bool get acceptsInput => status == GameStatus.playing;

  Rgb colorAt(int index) =>
      index == differentIndex ? differentColor : baseColor;

  GameState copyWith({
    int? level,
    int? lives,
    int? columns,
    int? rows,
    Rgb? baseColor,
    Rgb? differentColor,
    int? differentIndex,
    GameStatus? status,
    Set<int>? wrongIndexes,
    int? correctCount,
    int? wrongCount,
    int? currentStreak,
    int? bestStreak,
  }) {
    return GameState(
      level: level ?? this.level,
      lives: lives ?? this.lives,
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      baseColor: baseColor ?? this.baseColor,
      differentColor: differentColor ?? this.differentColor,
      differentIndex: differentIndex ?? this.differentIndex,
      status: status ?? this.status,
      wrongIndexes: wrongIndexes ?? this.wrongIndexes,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }
}

enum SelectionOutcome { correct, wrong, gameOver, ignored }

class SelectionResult {
  const SelectionResult(this.state, this.outcome);

  final GameState state;
  final SelectionOutcome outcome;
}
