/// Ağaç boyunca ayar ve çeviri erişimi.
///
/// [languageCode] widget alanına kopyalanır; aksi halde InheritedWidget
/// aynı [SettingsStore] referansında değişikliği göremez.
library;

import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'settings/settings_store.dart';

class AppScope extends InheritedWidget {
  AppScope({
    required this.settings,
    required super.child,
    super.key,
  })  : languageCode = settings.languageCode,
        colorBlindMode = settings.colorBlindMode,
        soundEnabled = settings.soundEnabled,
        hapticEnabled = settings.hapticEnabled;

  final SettingsStore settings;
  final String languageCode;
  final bool colorBlindMode;
  final bool soundEnabled;
  final bool hapticEnabled;

  /// Çeviri sözlüğü [AppStrings] içindedir. Anahtar olarak [AppStringKey] kullan.
  String t(String key) => AppStrings.translate(languageCode, key);

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return languageCode != oldWidget.languageCode ||
        colorBlindMode != oldWidget.colorBlindMode ||
        soundEnabled != oldWidget.soundEnabled ||
        hapticEnabled != oldWidget.hapticEnabled;
  }
}
