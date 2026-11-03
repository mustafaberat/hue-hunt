/// İlk oyunda kuralları ve can kaybını açıklayan kısa yönlendirme.
library;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../config/app_config.dart';
import 'app_button.dart';

class GameIntroOverlay extends StatelessWidget {
  const GameIntroOverlay({required this.onStart, super.key});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).t;

    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.overlay,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.overlayInset),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimens.overlayMaxWidth,
              ),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.cardRadius),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.overlayInner),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t(AppStringKey.gameIntroTitle),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppDimens.spaceMedium),
                      Text(
                        t(AppStringKey.gameIntroBody),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppDimens.spaceSmall),
                      Text(
                        t(AppStringKey.gameIntroLives),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppDimens.spaceLarge),
                      AppButton(
                        label: t(AppStringKey.gameIntroStart),
                        onPressed: onStart,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}