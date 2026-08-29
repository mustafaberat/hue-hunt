/// Raster logo yok: 2×2 kutu, biri [AppColors.logoAccent] (fallback çift ile aynı RGB).
library;

import 'package:flutter/material.dart';

import '../config/app_config.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({this.size = AppDimens.logoSize, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    const colors = [
      AppColors.logoBase,
      AppColors.logoBase,
      AppColors.logoAccent,
      AppColors.logoBase,
    ];

    return SizedBox(
      width: size,
      height: size,
      child: GridView.count(
        crossAxisCount: AppDimens.logoGrid,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        mainAxisSpacing: AppDimens.logoGap,
        crossAxisSpacing: AppDimens.logoGap,
        children: [
          for (var i = 0; i < colors.length; i++)
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors[i],
                borderRadius: BorderRadius.circular(AppDimens.boxRadius),
              ),
            ),
        ],
      ),
    );
  }
}
