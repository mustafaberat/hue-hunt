/// Can göstergesi. Dolu/boş sayı [GameConfig.initialLives] kadar kalp çizer.
library;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../config/app_config.dart';

class Hearts extends StatelessWidget {
  const Hearts({required this.lives, super.key});

  final int lives;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppScope.of(context)
          .t(AppStringKey.gameLives)
          .replaceAll('{count}', '$lives'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < GameConfig.initialLives; i++)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.spaceTiny,
              ),
              child: ExcludeSemantics(
                child: AnimatedSwitcher(
                  duration: AppMotion.heartChange,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Icon(
                    key: ValueKey(i < lives),
                    Icons.favorite_rounded,
                    color: i < lives ? AppColors.heart : AppColors.heartLost,
                    size: AppDimens.iconHeart,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
