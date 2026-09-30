/// Tek renk kutusu. Feedback (yanlış shake, doğru scale/border) UI state'tir.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../settings/tile_shape.dart';

enum BoxFeedback { none, wrong, correct, revealed }

class ColorBox extends StatelessWidget {
  const ColorBox({
    required this.color,
    required this.onTap,
    this.radius = AppDimens.boxRadius,
    this.feedback = BoxFeedback.none,
    this.enabled = true,
    this.shape = TileShape.square,
    this.semanticLabel,
    super.key,
  });

  final Color color;
  final VoidCallback? onTap;
  final BoxFeedback feedback;
  final double radius;
  final bool enabled;
  final TileShape shape;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final borderColor = switch (feedback) {
      BoxFeedback.wrong => AppColors.wrongBorder,
      BoxFeedback.correct || BoxFeedback.revealed => AppColors.correctBorder,
      BoxFeedback.none => AppColors.transparent,
    };
    final borderWidth = switch (feedback) {
      BoxFeedback.correct ||
      BoxFeedback.revealed => AppDimens.boxCorrectBorderWidth,
      BoxFeedback.wrong => AppDimens.boxWrongBorderWidth,
      BoxFeedback.none => AppDimens.boxIdleBorderWidth,
    };
    final scale =
        feedback == BoxFeedback.correct || feedback == BoxFeedback.revealed
            ? AppDimens.boxSuccessScale
            : AppDimens.boxIdleScale;
    final glowColor = switch (feedback) {
      BoxFeedback.wrong => AppColors.wrongBorder,
      BoxFeedback.correct || BoxFeedback.revealed => AppColors.correctBorder,
      BoxFeedback.none => AppColors.transparent,
    };

    Widget box = AnimatedScale(
      scale: scale,
      duration: AppMotion.correctFeedback,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: AppMotion.wrongFeedback,
        decoration: BoxDecoration(
          color: color,
          borderRadius:
              shape == TileShape.circle ? null : BorderRadius.circular(radius),
          shape:
              shape == TileShape.circle ? BoxShape.circle : BoxShape.rectangle,
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: [
            if (feedback != BoxFeedback.none)
              BoxShadow(
                color: glowColor.withValues(alpha: 0.55),
                blurRadius: feedback == BoxFeedback.wrong ? 18 : 12,
                spreadRadius: feedback == BoxFeedback.wrong ? 2 : 1,
              ),
          ],
        ),
        child: const SizedBox.expand(),
      ),
    );

    if (shape == TileShape.hexagon) {
      box = ClipPath(clipper: _HexagonClipper(), child: box);
    }

    if (feedback == BoxFeedback.wrong) {
      box = _Shake(child: box);
    }

    final marker = switch (feedback) {
      BoxFeedback.wrong => Icons.close_rounded,
      BoxFeedback.revealed => Icons.check_rounded,
      BoxFeedback.correct || BoxFeedback.none => null,
    };

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              box,
              if (marker != null)
                Center(
                  child: Icon(
                    marker,
                    size: radius * 1.5,
                    color: AppColors.text,
                    shadows: const [
                      Shadow(color: AppColors.background, blurRadius: 8),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final inset = width * 0.25;
    return Path()
      ..moveTo(inset, 0)
      ..lineTo(width - inset, 0)
      ..lineTo(width, height / 2)
      ..lineTo(width - inset, height)
      ..lineTo(inset, height)
      ..lineTo(0, height / 2)
      ..close();
  }

  @override
  bool shouldReclip(covariant _HexagonClipper oldClipper) => false;
}

class _Shake extends StatelessWidget {
  const _Shake({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.wrongFeedback,
      builder: (context, value, child) {
        final offset =
            math.sin(value * math.pi * AppMotion.shakeOscillations) *
            (1 - value) *
            AppDimens.shakeAmplitude;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: child,
    );
  }
}
