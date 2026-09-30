/// Kare oyun tahtası. Dış kutu her level'da aynı boyutta kalır; hücre küçülür.
///
/// Seviye atlayınca (doğru cevap) kutular [GridRebirthTick] ile sönüp
/// yeniden doğar. Süre: [AppMotion.gridRebirth].
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../animation/grid_rebirth.dart';
import '../color/rgb.dart';
import '../config/app_config.dart';
import '../settings/tile_shape.dart';
import 'color_box.dart';

class GameGrid extends StatefulWidget {
  const GameGrid({
    required this.columns,
    required this.rows,
    required this.baseColor,
    required this.differentColor,
    required this.differentIndex,
    required this.wrongIndexes,
    required this.onSelect,
    required this.enabled,
    this.revealed = false,
    this.successIndex,
    this.tileShape = TileShape.square,
    super.key,
  });

  final int columns;
  final int rows;
  final Rgb baseColor;
  final Rgb differentColor;
  final int differentIndex;
  final Set<int> wrongIndexes;
  final ValueChanged<int> onSelect;
  final bool enabled;
  final bool revealed;
  final int? successIndex;
  final TileShape tileShape;

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid> {
  /// Sönme fazında hâlâ eski round renkleri çizilsin diye.
  late Rgb _fromBase;
  late Rgb _fromDifferent;
  late int _fromDifferentIndex;

  Object get _roundToken => Object.hash(
    widget.columns,
    widget.rows,
    widget.baseColor,
    widget.differentColor,
    widget.differentIndex,
  );

  @override
  void initState() {
    super.initState();
    _captureFrom(widget);
  }

  @override
  void didUpdateWidget(GameGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.columns != widget.columns ||
        oldWidget.baseColor != widget.baseColor ||
        oldWidget.differentColor != widget.differentColor ||
        oldWidget.differentIndex != widget.differentIndex) {
      _fromBase = oldWidget.baseColor;
      _fromDifferent = oldWidget.differentColor;
      _fromDifferentIndex = oldWidget.differentIndex;
    }
  }

  void _captureFrom(GameGrid source) {
    _fromBase = source.baseColor;
    _fromDifferent = source.differentColor;
    _fromDifferentIndex = source.differentIndex;
  }

  double _radiusFor(double cell) {
    return (cell * AppDimens.boxRadiusFactor).clamp(
      AppDimens.boxRadiusMin,
      AppDimens.boxRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSide = math.min(constraints.maxWidth, constraints.maxHeight);
        final gap = _gapFor(boardSide);
        final translate = AppScope.of(context).t;

        return Center(
          child: SizedBox(
            width: boardSide,
            height: boardSide,
            child: GridRebirthTick(
              token: _roundToken,
              columns: widget.columns,
              builder: (context, t, animating, fromN) {
                final poses = GridRebirthMath.poses(
                  t: t,
                  fromN: fromN,
                  toN: widget.columns,
                  board: boardSide,
                  gap: gap,
                  tileShape: widget.tileShape,
                );
                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    for (final pose in poses)
                      Positioned(
                        left: pose.x,
                        top: pose.y,
                        width: pose.size,
                        height: pose.size,
                        child: Opacity(
                          opacity: pose.opacity,
                          child: Transform.scale(
                            scale: pose.scale,
                            child: ColorBox(
                              color: _colorAt(pose),
                              radius: _radiusFor(pose.size),
                              feedback:
                                  pose.outgoing
                                      ? BoxFeedback.none
                                      : _feedbackFor(pose.index),
                              shape: widget.tileShape,
                              semanticLabel: translate(
                                AppStringKey.gameTile,
                              ).replaceAll(
                                '{index}',
                                '${pose.index + 1}',
                              ),
                              enabled:
                                  widget.enabled &&
                                  !animating &&
                                  !pose.outgoing,
                              onTap: () => widget.onSelect(pose.index),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  double _gapFor(double boardSide) {
    if (widget.tileShape == TileShape.hexagon || widget.columns <= 1) {
      return 0;
    }

    final gapForMinimumTarget =
        (boardSide - widget.columns * AppDimens.minTouchTarget) /
        (widget.columns - 1);
    return math.min(AppDimens.boxGap, math.max(0, gapForMinimumTarget));
  }

  Color _colorAt(GridCellPose pose) {
    final base = pose.outgoing ? _fromBase : widget.baseColor;
    final different = pose.outgoing ? _fromDifferent : widget.differentColor;
    final index = pose.outgoing ? _fromDifferentIndex : widget.differentIndex;
    return (pose.index == index ? different : base).toColor();
  }

  BoxFeedback _feedbackFor(int index) {
    if (widget.successIndex == index) {
      return BoxFeedback.correct;
    }
    if (widget.revealed && index == widget.differentIndex) {
      return BoxFeedback.revealed;
    }
    if (widget.wrongIndexes.contains(index)) {
      return BoxFeedback.wrong;
    }
    return BoxFeedback.none;
  }
}
