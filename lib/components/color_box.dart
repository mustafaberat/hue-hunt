/// Tek renk kutusu. Feedback (yanlış shake, doğru scale/border) UI state'tir.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/app_config.dart';

enum BoxFeedback { none, wrong, correct, revealed }

class ColorBox extends StatelessWidget {
  const ColorBox({
    required this.color,
    required this.onTap,
    this.radius = AppDimens.boxRadius,
    this.feedback = BoxFeedback.none,
    this.enabled = true,
    super.key,
  });

  final Color color;
  final VoidCallback? onTap;
  final BoxFeedback feedback;
  final double radius;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final borderColor = switch (feedback) {
      BoxFeedback.wrong => AppColors.wrongBorder,
      BoxFeedback.correct || BoxFeedback.revealed => AppColors.correctBorder,
      BoxFeedback.none => AppColors.transparent,
    };
    final borderWidth = switch (feedback) {
      BoxFeedback.correct ||
      BoxFeedback.revealed =>
        AppDimens.boxCorrectBorderWidth,
      BoxFeedback.wrong => AppDimens.boxWrongBorderWidth,
      BoxFeedback.none => AppDimens.boxIdleBorderWidth,
    };
    final scale = feedback == BoxFeedback.correct ||
            feedback == BoxFeedback.revealed
        ? AppDimens.boxSuccessScale
        : AppDimens.boxIdleScale;

    Widget box = AnimatedScale(
      scale: scale,
      duration: AppMotion.correctFeedback,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: AppMotion.wrongFeedback,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: const SizedBox.expand(),
      ),
    );

    if (feedback == BoxFeedback.wrong) {
      box = _Shake(child: box);
    }

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(radius),
        child: box,
      ),
    );
  }
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
        final offset = math.sin(value * math.pi * AppMotion.shakeOscillations) *
            (1 - value) *
            AppDimens.shakeAmplitude;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: child,
    );
  }
}
