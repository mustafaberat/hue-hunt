/// Ana CTA ve ikincil (ghost) buton. Yükseklik / radius [AppDimens] üzerinden.
library;

import 'package:flutter/material.dart';

import '../config/app_config.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.primary = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final background = primary ? AppColors.accent : AppColors.surface;
    final foreground = primary ? AppColors.background : AppColors.text;

    return Opacity(
      opacity: onPressed == null ? AppDimens.disabledOpacity : 1,
      child: SizedBox(
        width: double.infinity,
        height: AppDimens.buttonHeight,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
            child: Center(
              child: Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foreground,
                  letterSpacing: AppType.buttonTracking,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
