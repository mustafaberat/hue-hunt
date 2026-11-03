/// "Seviye N" — metin [AppStringKey.level] üzerinden gelir.
library;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../config/app_config.dart';

class LevelIndicator extends StatelessWidget {
  const LevelIndicator({required this.level, super.key});

  final int level;

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).t;
    return AnimatedSwitcher(
      duration: AppMotion.levelChange,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: Text(
        '${t(AppStringKey.level)} $level',
        key: ValueKey(level),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.text,
              letterSpacing: AppType.titleTracking,
            ),
      ),
    );
  }
}
