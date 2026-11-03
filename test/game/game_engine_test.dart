import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hue_hunt/config/game_config.dart';
import 'package:hue_hunt/game/game_engine.dart';
import 'package:hue_hunt/game/game_state.dart';

void main() {
  late GameEngine engine;
  late GameState state;

  setUp(() {
    engine = GameEngine(random: Random(7));
    state = engine.start();
  });

  test('game starts at level 1 with 4 boxes and 3 lives', () {
    expect(state.level, 1);
    expect(state.boxCount, 4);
    expect(state.lives, GameConfig.initialLives);
    expect(state.status, GameStatus.playing);
    expect(state.differentIndex, inInclusiveRange(0, 3));
    expect(state.baseColor == state.differentColor, isFalse);
  });

  test('wrong answer decreases life and keeps the same round', () {
    final wrong = _wrongIndex(state);
    final before = state;
    final result = engine.selectBox(state, wrong);

    expect(result.outcome, SelectionOutcome.wrong);
    expect(result.state.lives, before.lives - 1);
    expect(result.state.level, before.level);
    expect(result.state.differentIndex, before.differentIndex);
    expect(result.state.baseColor, before.baseColor);
    expect(result.state.status, GameStatus.playing);
    expect(result.state.wrongIndexes, contains(wrong));
    expect(result.state.wrongCount, 1);
    expect(result.state.currentStreak, 0);
  });

  test('tapping the same wrong box twice does not remove another life', () {
    final wrong = _wrongIndex(state);
    state = engine.selectBox(state, wrong).state;
    final result = engine.selectBox(state, wrong);
    expect(result.outcome, SelectionOutcome.ignored);
    expect(result.state.lives, GameConfig.initialLives - 1);
    expect(result.state.wrongCount, 1);
    expect(result.state.currentStreak, 0);
  });

  test('tracks accuracy and best streak across levels', () {
    var current = state;
    current = engine.selectBox(current, current.differentIndex).state;
    current = engine.nextLevel(current);
    current = engine.selectBox(current, current.differentIndex).state;

    expect(current.correctCount, 2);
    expect(current.wrongCount, 0);
    expect(current.currentStreak, 2);
    expect(current.bestStreak, 2);
    expect(current.accuracy, 1);
  });

  test('correct answer advances level without restoring lives', () {
    state = engine.selectBox(state, _wrongIndex(state)).state;
    expect(state.lives, GameConfig.initialLives - 1);

    final result = engine.selectBox(state, state.differentIndex);
    expect(result.outcome, SelectionOutcome.correct);
    expect(result.state.status, GameStatus.success);
    expect(result.state.lives, GameConfig.initialLives - 1);

    final next = engine.nextLevel(result.state);
    expect(next.level, 2);
    expect(next.lives, GameConfig.initialLives - 1);
    expect(next.status, GameStatus.playing);
    expect(next.wrongIndexes, isEmpty);
  });

  test('life cannot become negative and game over locks input', () {
    for (var i = 0; i < GameConfig.initialLives; i++) {
      state = engine.selectBox(state, _wrongIndex(state)).state;
    }

    expect(state.lives, 0);
    expect(state.status, GameStatus.gameOver);

    final locked = engine.selectBox(state, state.differentIndex);
    expect(locked.outcome, SelectionOutcome.ignored);
    expect(locked.state.lives, 0);
  });

  test('restart resets to level 1', () {
    engine.selectBox(state, state.differentIndex);
    final restarted = engine.restart();
    expect(restarted.level, 1);
    expect(restarted.lives, GameConfig.initialLives);
    expect(restarted.status, GameStatus.playing);
  });

  test('level 4 uses a 3x3 grid', () {
    var current = state;
    for (var i = 0; i < 3; i++) {
      current = engine.nextLevel(current);
    }
    expect(current.level, 4);
    expect(current.columns, 3);
    expect(current.rows, 3);
    expect(current.boxCount, 9);
  });

  test('grid never exceeds 6x6', () {
    var current = state;
    for (var i = 0; i < 20; i++) {
      current = engine.nextLevel(current);
    }
    expect(current.columns, GameConfig.maxGridSize);
    expect(current.rows, GameConfig.maxGridSize);
    expect(current.columns, lessThanOrEqualTo(GameConfig.maxGridSize));
  });
}

int _wrongIndex(GameState state) {
  return List<int>.generate(state.boxCount, (i) => i)
      .firstWhere((index) =>
          index != state.differentIndex &&
          !state.wrongIndexes.contains(index));
}
