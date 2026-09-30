/// Uygulamanın gerçek rotalarına bağlı alt gezinme çubuğu.
library;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../config/app_config.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({required this.selectedIndex, super.key});

  final int selectedIndex;

  void _go(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushNamed(context, AppRoutes.game);
    } else if (index == 1 && selectedIndex != 1) {
      Navigator.pushReplacementNamed(context, AppRoutes.scoreboard);
    } else if (index == 2 && selectedIndex != 2) {
      Navigator.pushReplacementNamed(context, AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).t;
    final items = [
      (Icons.play_arrow_rounded, t(AppStringKey.play)),
      (Icons.leaderboard_rounded, t(AppStringKey.scoreboard)),
      (Icons.tune_rounded, t(AppStringKey.settings)),
    ];

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xF2181A1F),
        border: Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 16,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: items[i].$1,
                    label: items[i].$2,
                    selected: selectedIndex == i,
                    onTap: () => _go(context, i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.background : AppColors.textMuted;
    return Material(
      color: selected ? AppColors.logoAccent : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 21, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.35,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}