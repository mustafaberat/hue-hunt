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
    return Text(
      '${t(AppStringKey.level)} $level',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.text,
            letterSpacing: AppType.titleTracking,
          ),
    );
  }
}
