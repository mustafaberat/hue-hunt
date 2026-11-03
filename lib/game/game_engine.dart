/// Girdi → yeni [GameState]. Flutter / animasyon bilmez.
///
/// Yanlış seçimde round resetlenmez. Doğru seçimde [nextLevel] yeni renk üretir
/// ama can aynı kalır — session boyunca can yalnızca azalır, geri dolmaz.
/// Can yalnızca [start] / [restart] ile [GameConfig.initialLives]'e döner.
library;

import 'dart:math';

import '../color/generator.dart';
import '../config/app_config.dart';
import 'game_state.dart';

class GameEngine {
  GameEngine({
    Random? random,
    ColorGenerator? generator,
    this.colorBlindSafe = false,
  }) : _random = random ?? Random(),
       _generator = generator ?? ColorGenerator(random: random);

  final Random _random;
  final ColorGenerator _generator;

  /// Ayarlardan gelir. Sonraki round üretimini etkiler, mevcut round'u değil.
  bool colorBlindSafe = false;

  /// Son round'ların farklı-kutu index'leri; aynı yere yapışmayı keser.
  final List<int> _recentIndexes = [];

  GameState start({int level = 1}) {
    _recentIndexes.clear();
    return _roundFor(level, lives: GameConfig.initialLives);
  }

  GameState restart() => start();

  SelectionResult selectBox(GameState state, int index) {
    if (!state.acceptsInput) {
      return SelectionResult(state, SelectionOutcome.ignored);
    }
    if (index < 0 || index >= state.boxCount) {
      return SelectionResult(state, SelectionOutcome.ignored);
    }
    if (state.wrongIndexes.contains(index)) {
      return SelectionResult(state, SelectionOutcome.ignored);
    }

    if (index == state.differentIndex) {
      return SelectionResult(
        state.copyWith(
          status: GameStatus.success,
          correctCount: state.correctCount + 1,
          currentStreak: state.currentStreak + 1,
          bestStreak: max(
            state.bestStreak,
            state.currentStreak + 1,
          ),
        ),
        SelectionOutcome.correct,
      );
    }

    final lives = max(0, state.lives - 1);
    if (lives == 0) {
      return SelectionResult(
        state.copyWith(
          lives: 0,
          status: GameStatus.gameOver,
          wrongIndexes: {...state.wrongIndexes, index},
          wrongCount: state.wrongCount + 1,
          currentStreak: 0,
        ),
        SelectionOutcome.gameOver,
      );
    }

    return SelectionResult(
      state.copyWith(
        lives: lives,
        status: GameStatus.playing,
        wrongIndexes: {...state.wrongIndexes, index},
        wrongCount: state.wrongCount + 1,
        currentStreak: 0,
      ),
      SelectionOutcome.wrong,
    );
  }

  GameState nextLevel(GameState state) {
    return _roundFor(
      state.level + 1,
      lives: state.lives,
      correctCount: state.correctCount,
      wrongCount: state.wrongCount,
      currentStreak: state.currentStreak,
      bestStreak: state.bestStreak,
    );
  }

  GameState _roundFor(
    int level, {
    required int lives,
    int correctCount = 0,
    int wrongCount = 0,
    int currentStreak = 0,
    int bestStreak = 0,
  }) {
    _generator.colorBlindSafe = colorBlindSafe;
    final spec = GameConfig.specForLevel(level);
    final colors = _generator.generateRoundColors(spec.delta);
    final index = _pickIndex(spec.boxCount);

    return GameState(
      level: spec.level,
      lives: lives,
      columns: spec.columns,
      rows: spec.rows,
      baseColor: colors.base,
      differentColor: colors.different,
      differentIndex: index,
      status: GameStatus.playing,
      correctCount: correctCount,
      wrongCount: wrongCount,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
    );
  }

  int _pickIndex(int boxCount) {
    final all = List<int>.generate(boxCount, (i) => i);
    final candidates =
        all.where((index) => !_recentIndexes.contains(index)).toList();
    final pool = candidates.isEmpty ? all : candidates;
    final index = pool[_random.nextInt(pool.length)];
    _recentIndexes.add(index);
    if (_recentIndexes.length > GameConfig.recentIndexHistory) {
      _recentIndexes.removeAt(0);
    }
    return index;
  }
}
