/// Seri başarısını oyun tahtasının merkezinde gösteren kısa geri bildirim.
library;

import 'package:flutter/material.dart';

import '../config/app_config.dart';

class StreakOverlay extends StatelessWidget {
  const StreakOverlay({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.72, end: 1),
          duration: AppMotion.streakFeedback,
          curve: Curves.easeOutBack,
          builder: (context, scale, child) => Opacity(
            opacity: scale.clamp(0.0, 1.0),
            child: Transform.scale(scale: scale, child: child),
          ),
          child: Material(
            color: AppColors.surface.withValues(alpha: 0.96),
            elevation: 12,
            shadowColor: AppColors.logoAccent.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.spaceLarge,
                vertical: AppDimens.spaceMedium,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
                border: Border.all(
                  color: AppColors.logoAccent.withValues(alpha: 0.8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.logoAccent,
                    size: 22,
                  ),
                  const SizedBox(width: AppDimens.spaceXSmall),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}