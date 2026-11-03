/// İlk ekran: logo, ad, tek satır açıklama, Oyna, Ayarlar.
library;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../components/app_button.dart';
import '../components/app_bottom_nav.dart';
import '../components/app_logo.dart';
import '../config/app_config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).t;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF151923), AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.pagePadding,
              vertical: AppDimens.pagePaddingTight,
            ),
            child: Column(
              children: [
                const Spacer(flex: AppDimens.homeTopFlex),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.86, end: 1),
                  duration: AppMotion.homeReveal,
                  curve: Curves.easeOutBack,
                  builder:
                      (context, value, child) => Opacity(
                        opacity: value.clamp(0, 1),
                        child: Transform.scale(scale: value, child: child),
                      ),
                  child: const AppLogo(),
                ),
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: AppType.tagline),
                ),
                const Spacer(flex: AppDimens.homeMidFlex),
                AppButton(
                  label: t(AppStringKey.play),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.game),
                ),
                const Spacer(flex: AppDimens.homeBottomFlex),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 0),
    );
  }
}
