/// Tüm kullanıcıya görünen metinler.
///
/// Ekranda string literal yazılmaz. Yeni dil eklemek = [AppLanguages.supported]
/// + [AppStrings.translations] içine aynı anahtar setini eklemek.
library;

import 'tokens.dart';

/// Desteklenen diller. Kodlar hem prefs hem [AppStrings.translations] anahtarıdır.
abstract final class AppLanguages {
  static const String tr = 'tr';
  static const String en = 'en';
  static const String fallback = en;

  static const Map<String, String> supported = {tr: 'Türkçe', en: 'English'};
}

/// Çeviri anahtarları. `t('play')` yerine `t(AppStringKey.play)` kullanılır.
abstract final class AppStringKey {
  static const String appName = 'appName';
  static const String tagline = 'tagline';
  static const String play = 'play';
  static const String settings = 'settings';
  static const String language = 'language';
  static const String colorBlindMode = 'colorBlindMode';
  static const String colorBlindModeHint = 'colorBlindModeHint';
  static const String sound = 'sound';
  static const String haptic = 'haptic';
  static const String gameOver = 'gameOver';
  static const String reachedLevel = 'reachedLevel';
  static const String playAgain = 'playAgain';
  static const String home = 'home';
  static const String about = 'about';
  static const String developedBy = 'developedBy';
  static const String version = 'version';
  static const String game = 'game';
  static const String level = 'level';
  static const String turkish = 'turkish';
  static const String english = 'english';
  static const String scoreboard = 'scoreboard';
  static const String yourName = 'yourName';
  static const String saveScore = 'saveScore';
  static const String scoreboardEmpty = 'scoreboardEmpty';

  /// Dil kodu → o dilin kendi adının çeviri anahtarı.
  static const Map<String, String> languageNameKeys = {
    AppLanguages.tr: turkish,
    AppLanguages.en: english,
  };
}

abstract final class AppStrings {
  static const Map<String, Map<String, String>> translations = {
    AppLanguages.tr: {
      AppStringKey.appName: AppIdentity.appName,
      AppStringKey.tagline: 'Farklı rengi bul!',
      AppStringKey.play: 'Oyna',
      AppStringKey.settings: 'Ayarlar',
      AppStringKey.language: 'Dil',
      AppStringKey.colorBlindMode: 'Renk körü modu',
      AppStringKey.colorBlindModeHint:
          'Kırmızı-yeşil karışmayan, ayırt edilebilir renkler',
      AppStringKey.sound: 'Ses',
      AppStringKey.haptic: 'Titreşim',
      AppStringKey.gameOver: 'Oyun bitti',
      AppStringKey.reachedLevel: 'Ulaşılan seviye',
      AppStringKey.playAgain: 'Tekrar oyna',
      AppStringKey.home: 'Ana sayfa',
      AppStringKey.about: 'Hakkında',
      AppStringKey.developedBy: 'Geliştiren',
      AppStringKey.version: 'Sürüm',
      AppStringKey.game: 'Oyun',
      AppStringKey.level: 'Seviye',
      AppStringKey.turkish: 'Türkçe',
      AppStringKey.english: 'English',
      AppStringKey.scoreboard: 'Skor tablosu',
      AppStringKey.yourName: 'İsmin',
      AppStringKey.saveScore: 'Kaydet',
      AppStringKey.scoreboardEmpty: 'Henüz skor yok',
    },
    AppLanguages.en: {
      AppStringKey.appName: AppIdentity.appName,
      AppStringKey.tagline: 'Find the different color!',
      AppStringKey.play: 'Play',
      AppStringKey.settings: 'Settings',
      AppStringKey.language: 'Language',
      AppStringKey.colorBlindMode: 'Color blind mode',
      AppStringKey.colorBlindModeHint:
          'Picks colors a red-green color-blind player can tell apart',
      AppStringKey.sound: 'Sound',
      AppStringKey.haptic: 'Haptics',
      AppStringKey.gameOver: 'Game over',
      AppStringKey.reachedLevel: 'Reached level',
      AppStringKey.playAgain: 'Play again',
      AppStringKey.home: 'Home',
      AppStringKey.about: 'About',
      AppStringKey.developedBy: 'Developed by',
      AppStringKey.version: 'Version',
      AppStringKey.game: 'Game',
      AppStringKey.level: 'Level',
      AppStringKey.turkish: 'Türkçe',
      AppStringKey.english: 'English',
      AppStringKey.scoreboard: 'Scoreboard',
      AppStringKey.yourName: 'Your name',
      AppStringKey.saveScore: 'Save',
      AppStringKey.scoreboardEmpty: 'No scores yet',
    },
  };

  /// Eksik anahtarda fallback dile, o da yoksa anahtarın kendisine düşer.
  static String translate(String languageCode, String key) {
    return translations[languageCode]?[key] ??
        translations[AppLanguages.fallback]?[key] ??
        key;
  }
}
