/// Oyun turu. Engine saf; bu dosya gecikme, overlay ve feedback çalar.
///
/// Doğru seçimde kısa parlama, sonra next level + grid rebirth (can aynı).
/// Yanlışta can 1 veya Game Over ise skorboard prefetch. Ağ yoksa tablo yok.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../components/game_grid.dart';
import '../components/game_intro_overlay.dart';
import '../components/game_over_overlay.dart';
import '../components/hearts.dart';
import '../components/level_indicator.dart';
import '../components/streak_overlay.dart';
import '../config/app_config.dart';
import '../feedback/player_feedback.dart';
import '../game/game_engine.dart';
import '../game/game_state.dart';
import '../scoreboard/scoreboard_session.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameEngine _engine;
  final _scoreboard = ScoreboardSession();
  late GameState _state;
  var _started = false;
  var _showIntro = false;
  var _showGameOver = false;
  var _bestBeforeGame = 0;
  int? _streakValue;

  /// Doğru kutunun kısa "success" animasyonu bitene kadar input kilitli.
  int? _successIndex;

  @override
  void initState() {
    super.initState();
    _engine = GameEngine();
  }

  @override
  void dispose() {
    _scoreboard.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _engine.colorBlindSafe = AppScope.of(context).colorBlindMode;
    if (!_started) {
      _bestBeforeGame = AppScope.of(context).settings.bestLevel;
      _state = _engine.start();
      _started = true;
      _showIntro = !AppScope.of(context).settings.gameIntroSeen;
    }
  }

  bool get _inputEnabled =>
      _state.acceptsInput && !_showIntro && !_showGameOver && _successIndex == null;

  void _startGame() {
    AppScope.of(context).settings.setGameIntroSeen();
    setState(() => _showIntro = false);
  }

  void _onSelect(int index) {
    if (!_inputEnabled) {
      return;
    }

    final result = _engine.selectBox(_state, index);
    if (result.outcome == SelectionOutcome.ignored) {
      return;
    }

    final scope = AppScope.of(context);
    PlayerFeedback.play(
      correct: result.outcome == SelectionOutcome.correct,
      sound: scope.soundEnabled,
      haptic: scope.hapticEnabled,
    );

    switch (result.outcome) {
      case SelectionOutcome.correct:
        _onCorrect(index, result.state);
      case SelectionOutcome.wrong:
      case SelectionOutcome.gameOver:
        _onMiss(result);
      case SelectionOutcome.ignored:
        break;
    }
  }

  void _onCorrect(int index, GameState state) {
    setState(() {
      _state = state;
      _successIndex = index;
      _streakValue =
          state.currentStreak >= 3 && state.currentStreak % 3 == 0
              ? state.currentStreak
              : null;
    });
    if (state.currentStreak >= 3 && state.currentStreak % 3 == 0) {
      Future<void>.delayed(AppMotion.streakVisible, () {
        if (!mounted || _streakValue != state.currentStreak) {
          return;
        }
        setState(() => _streakValue = null);
      });
    }
    Future<void>.delayed(AppMotion.levelAdvanceDelay, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _state = _engine.nextLevel(_state);
        _successIndex = null;
      });
    });
  }

  void _onMiss(SelectionResult result) {
    setState(() => _state = result.state);

    final lastLife = result.state.lives == 1;
    final over = result.outcome == SelectionOutcome.gameOver;
    if (lastLife || over) {
      unawaited(_scoreboard.prefetch());
    }
    if (over) {
      Future<void>.delayed(AppMotion.gameOverReveal, () {
        if (!mounted) {
          return;
        }
        unawaited(AppScope.of(context).settings.recordBestLevel(_state.level));
        setState(() => _showGameOver = true);
      });
    }
  }

  void _playAgain() {
    _scoreboard.reset();
    setState(() {
      _bestBeforeGame = AppScope.of(context).settings.bestLevel;
      _state = _engine.restart();
      _showGameOver = false;
      _successIndex = null;
      _streakValue = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pagePadding,
            AppDimens.headerTopPadding,
            AppDimens.pagePadding,
            AppDimens.headerBottomPadding,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: AppDimens.headerHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                            color: AppColors.textMuted,
                            tooltip: scope.t(AppStringKey.home),
                          ),
                        ),
                        LevelIndicator(level: _state.level),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: AppDimens.spaceXSmall,
                            ),
                            child: Hearts(lives: _state.lives),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.spaceLarge),
                  Expanded(
                    child: GameGrid(
                      columns: _state.columns,
                      rows: _state.rows,
                      baseColor: _state.baseColor,
                      differentColor: _state.differentColor,
                      differentIndex: _state.differentIndex,
                      wrongIndexes: _state.wrongIndexes,
                      enabled: _inputEnabled,
                      revealed: _state.status == GameStatus.gameOver,
                      successIndex: _successIndex,
                      tileShape: scope.tileShape,
                      onSelect: _onSelect,
                    ),
                  ),
                ],
              ),
              if (_showGameOver)
                GameOverOverlay(
                  level: _state.level,
                  bestLevel: scope.settings.bestLevel,
                  previousBestLevel: _bestBeforeGame,
                  correctCount: _state.correctCount,
                  wrongCount: _state.wrongCount,
                  accuracy: _state.accuracy,
                  bestStreak: _state.bestStreak,
                  scoreboard: _scoreboard,
                  onPlayAgain: _playAgain,
                  onHome: () => Navigator.pop(context),
                ),
              if (_showIntro) GameIntroOverlay(onStart: _startGame),
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: AppMotion.streakFeedback,
                  child:
                      _streakValue == null
                          ? const SizedBox.shrink(key: ValueKey('no-streak'))
                          : StreakOverlay(
                            key: ValueKey(_streakValue),
                            message: scope
                                .t(AppStringKey.streakMessage)
                                .replaceAll('{count}', '$_streakValue'),
                          ),
                ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
