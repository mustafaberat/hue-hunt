/// İlk ekran: logo, ad, tek satır açıklama, Oyna, Ayarlar.
library;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../components/app_button.dart';
import '../components/app_logo.dart';
import '../config/app_config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).t;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.pagePadding,
            vertical: AppDimens.pagePaddingTight,
          ),
          child: Column(
            children: [
              const Spacer(flex: AppDimens.homeTopFlex),
              const AppLogo(),
              const SizedBox(height: AppDimens.spaceXLarge),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  t(AppStringKey.appName).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              const SizedBox(height: AppDimens.spaceMedium),
              Text(
                t(AppStringKey.tagline),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: AppType.tagline,
                    ),
              ),
              const Spacer(flex: AppDimens.homeMidFlex),
              AppButton(
                label: t(AppStringKey.play),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.game),
              ),
              const SizedBox(height: AppDimens.spaceRegular),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.settings),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                  minimumSize: const Size(
                    AppDimens.minTouchTarget,
                    AppDimens.minTouchTarget,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.settings_rounded,
                      size: AppDimens.iconSettings,
                    ),
                    const SizedBox(width: AppDimens.spaceXSmall),
                    Text(
                      t(AppStringKey.settings),
                      style: const TextStyle(
                        fontWeight: AppType.settingsLinkWeight,
                        letterSpacing: AppType.settingsLinkTracking,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: AppDimens.homeBottomFlex),
            ],
          ),
        ),
      ),
    );
  }
}
