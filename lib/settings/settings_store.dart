/// Dil, renk körü, ses ve titreşim. Yalnızca bu dört alan kalıcıdır.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class SettingsStore extends ChangeNotifier {
  SharedPreferences? _prefs;

  String languageCode = AppLanguages.fallback;
  bool colorBlindMode = false;
  bool soundEnabled = true;
  bool hapticEnabled = true;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final storedLanguage = _prefs?.getString(AppPrefsKeys.language);
    languageCode = AppLanguages.supported.containsKey(storedLanguage)
        ? storedLanguage!
        : _deviceLanguage();
    colorBlindMode = _prefs?.getBool(AppPrefsKeys.colorBlindMode) ?? false;
    soundEnabled = _prefs?.getBool(AppPrefsKeys.sound) ?? true;
    hapticEnabled = _prefs?.getBool(AppPrefsKeys.haptic) ?? true;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    if (!AppLanguages.supported.containsKey(code) || languageCode == code) {
      return;
    }
    languageCode = code;
    await _prefs?.setString(AppPrefsKeys.language, code);
    notifyListeners();
  }

  Future<void> setColorBlindMode(bool value) async {
    if (colorBlindMode == value) {
      return;
    }
    colorBlindMode = value;
    await _prefs?.setBool(AppPrefsKeys.colorBlindMode, value);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    if (soundEnabled == value) {
      return;
    }
    soundEnabled = value;
    await _prefs?.setBool(AppPrefsKeys.sound, value);
    notifyListeners();
  }

  Future<void> setHapticEnabled(bool value) async {
    if (hapticEnabled == value) {
      return;
    }
    hapticEnabled = value;
    await _prefs?.setBool(AppPrefsKeys.haptic, value);
    notifyListeners();
  }

  /// Cihaz dili desteklenmiyorsa [AppLanguages.fallback] (İngilizce).
  String _deviceLanguage() {
    final code = PlatformDispatcher.instance.locale.languageCode;
    return AppLanguages.supported.containsKey(code)
        ? code
        : AppLanguages.fallback;
  }
}
