/// Dil, renk körü, ses ve titreşim. Yalnızca bu dört alan kalıcıdır.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import 'tile_shape.dart';

class SettingsStore extends ChangeNotifier {
  SharedPreferences? _prefs;

  String languageCode = AppLanguages.fallback;
  bool gameIntroSeen = false;
  int bestLevel = 0;
  bool colorBlindMode = false;
  bool soundEnabled = true;
  bool hapticEnabled = true;
  TileShape tileShape = TileShape.square;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final storedLanguage = _prefs?.getString(AppPrefsKeys.language);
    languageCode =
        AppLanguages.supported.containsKey(storedLanguage)
            ? storedLanguage!
            : _deviceLanguage();
    gameIntroSeen = _prefs?.getBool(AppPrefsKeys.gameIntroSeen) ?? false;
    bestLevel = _prefs?.getInt(AppPrefsKeys.bestLevel) ?? 0;
    colorBlindMode = _prefs?.getBool(AppPrefsKeys.colorBlindMode) ?? false;
    soundEnabled = _prefs?.getBool(AppPrefsKeys.sound) ?? true;
    hapticEnabled = _prefs?.getBool(AppPrefsKeys.haptic) ?? true;
    tileShape = tileShapeFromStorage(_prefs?.getString(AppPrefsKeys.tileShape));
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

  Future<void> setGameIntroSeen() async {
    if (gameIntroSeen) {
      return;
    }
    gameIntroSeen = true;
    await _prefs?.setBool(AppPrefsKeys.gameIntroSeen, true);
    notifyListeners();
  }

  Future<void> recordBestLevel(int level) async {
    if (level <= bestLevel) {
      return;
    }
    bestLevel = level;
    await _prefs?.setInt(AppPrefsKeys.bestLevel, level);
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

  Future<void> setTileShape(TileShape value) async {
    if (tileShape == value) {
      return;
    }
    tileShape = value;
    await _prefs?.setString(AppPrefsKeys.tileShape, value.name);
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
