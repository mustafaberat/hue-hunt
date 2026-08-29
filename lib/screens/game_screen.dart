/// Oyun turu. Engine saf; bu dosya gecikme, overlay ve feedback çalar.
///
/// Doğru seçimde kısa parlama, sonra next level + grid rebirth (can aynı).
/// Can 0'da doğru kutu gösterilir, ardından Game Over kartı açılır.
library;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../components/app_button.dart';
import '../components/game_grid.dart';
import '../components/hearts.dart';
import '../components/level_indicator.dart';
import '../config/app_config.dart';
import '../feedback/player_feedback.dart';
import '../game/game_engine.dart';
import '../game/game_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameEngine _engine;
  late GameState _state;
  bool _started = false;
  bool _showGameOver = false;

  /// Doğru kutunun kısa "success" animasyonu bitene kadar input kilitli.
  int? _successIndex;

  @override
  void initState() {
    super.initState();
    _engine = GameEngine();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _engine.colorBlindSafe = AppScope.of(context).colorBlindMode;
    if (!_started) {
      _state = _engine.start();
      _started = true;
    }
  }

  bool get _inputEnabled =>
      _state.acceptsInput && !_showGameOver && _successIndex == null;

  void _onSelect(int index) {
    if (!_inputEnabled) {
      return;
    }

    final result = _engine.selectBox(_state, index);
    final scope = AppScope.of(context);

    if (result.outcome == SelectionOutcome.ignored) {
      return;
    }

    PlayerFeedback.play(
      correct: result.outcome == SelectionOutcome.correct,
      sound: scope.soundEnabled,
      haptic: scope.hapticEnabled,
    );

    if (result.outcome == SelectionOutcome.correct) {
      setState(() {
        _state = result.state;
        _successIndex = index;
      });
      Future<void>.delayed(AppMotion.levelAdvanceDelay, () {
        if (!mounted) {
          return;
        }
        setState(() {
          _state = _engine.nextLevel(_state);
          _successIndex = null;
        });
      });
      return;
    }

    setState(() => _state = result.state);

    if (result.outcome == SelectionOutcome.gameOver) {
      Future<void>.delayed(AppMotion.gameOverReveal, () {
        if (!mounted) {
          return;
        }
        setState(() => _showGameOver = true);
      });
    }
  }

  void _playAgain() {
    setState(() {
      _state = _engine.restart();
      _showGameOver = false;
      _successIndex = null;
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
                      onSelect: _onSelect,
                    ),
                  ),
                ],
              ),
              if (_showGameOver)
                _GameOverOverlay(
                  level: _state.level,
                  onPlayAgain: _playAgain,
                  onHome: () => Navigator.pop(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({
    required this.level,
    required this.onPlayAgain,
    required this.onHome,
  });

  final int level;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).t;

    return ColoredBox(
      color: AppColors.overlay,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimens.overlayMaxWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.overlayInset,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.cardRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.overlayInner,
                  AppDimens.overlayInnerTop,
                  AppDimens.overlayInner,
                  AppDimens.overlayInner,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t(AppStringKey.gameOver).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        letterSpacing: AppType.overlayTracking,
                      ),
                    ),
                    const SizedBox(height: AppDimens.spaceMedium),
                    Text(
                      '${t(AppStringKey.reachedLevel)} $level',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppDimens.spaceXLarge),
                    AppButton(
                      label: t(AppStringKey.playAgain),
                      onPressed: onPlayAgain,
                    ),
                    const SizedBox(height: AppDimens.spaceMedium),
                    AppButton(
                      label: t(AppStringKey.home),
                      primary: false,
                      onPressed: onHome,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
