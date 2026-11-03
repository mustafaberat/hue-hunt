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
  static const String gameIntroTitle = 'gameIntroTitle';
  static const String gameIntroBody = 'gameIntroBody';
  static const String gameIntroLives = 'gameIntroLives';
  static const String gameIntroStart = 'gameIntroStart';
  static const String gameTile = 'gameTile';
  static const String gameLives = 'gameLives';
  static const String personalBest = 'personalBest';
  static const String statsCorrect = 'statsCorrect';
  static const String statsWrong = 'statsWrong';
  static const String statsAccuracy = 'statsAccuracy';
  static const String statsBestStreak = 'statsBestStreak';
  static const String streakMessage = 'streakMessage';
  static const String recordGap = 'recordGap';
  static const String turkish = 'turkish';
  static const String english = 'english';
  static const String scoreboard = 'scoreboard';
  static const String yourName = 'yourName';
  static const String saveScore = 'saveScore';
  static const String scoreboardEmpty = 'scoreboardEmpty';
  static const String scoreboardUnavailable = 'scoreboardUnavailable';
  static const String newRecord = 'newRecord';
  static const String scoreSaved = 'scoreSaved';
  static const String scoreboardNotEntered = 'scoreboardNotEntered';
  static const String scoreboardTopFive = 'scoreboardTopFive';
  static const String scoreboardChampions = 'scoreboardChampions';
  static const String scoreboardConnectedScores = 'scoreboardConnectedScores';
  static const String scoreboardGlobalStandings = 'scoreboardGlobalStandings';
  static const String tileShape = 'tileShape';
  static const String tileShapeHint = 'tileShapeHint';
  static const String tileShapeSquare = 'tileShapeSquare';
  static const String tileShapeHexagon = 'tileShapeHexagon';
  static const String tileShapeCircle = 'tileShapeCircle';

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
        AppStringKey.gameIntroTitle: 'Farklı olanı bul',
        AppStringKey.gameIntroBody:
          'Her seviyede diğerlerinden farklı olan renkli kutuya dokun.',
        AppStringKey.gameIntroLives: 'Yanlış seçim bir can götürür.',
        AppStringKey.gameIntroStart: 'Anladım, başla',
        AppStringKey.gameTile: 'Oyun kutusu {index}',
        AppStringKey.gameLives: '{count} can kaldı',
        AppStringKey.personalBest: 'Kişisel rekor: {level}',
        AppStringKey.statsCorrect: 'Doğru: {count}',
        AppStringKey.statsWrong: 'Yanlış: {count}',
        AppStringKey.statsAccuracy: 'İsabet: %{percent}',
        AppStringKey.statsBestStreak: 'En iyi seri: {count}',
        AppStringKey.streakMessage: '{count} doğru üst üste!',
        AppStringKey.recordGap: 'Rekoruna {count} seviye kaldı',
      AppStringKey.turkish: 'Türkçe',
      AppStringKey.english: 'English',
      AppStringKey.scoreboard: 'Skor tablosu',
      AppStringKey.yourName: 'İsmin',
      AppStringKey.saveScore: 'Kaydet',
      AppStringKey.scoreboardEmpty: 'Henüz skor yok',
      AppStringKey.scoreboardUnavailable: 'Skor tablosu şu an kullanılamıyor',
      AppStringKey.newRecord: 'Yeni rekor!',
      AppStringKey.scoreSaved: 'Skor tablosuna girdin!',
      AppStringKey.scoreboardNotEntered: 'Skor tablosuna giremedin',
      AppStringKey.scoreboardTopFive: 'İlk 5',
      AppStringKey.scoreboardChampions: 'RENK ŞAMPİYONLARI',
      AppStringKey.scoreboardConnectedScores: '{count} kayıtlı skor',
      AppStringKey.scoreboardGlobalStandings: 'GENEL SIRALAMA',
      AppStringKey.tileShape: 'Kutu şekli',
      AppStringKey.tileShapeHint: 'Oyun kutularının görünümünü seç',
      AppStringKey.tileShapeSquare: 'Kare',
      AppStringKey.tileShapeHexagon: 'Altıgen',
      AppStringKey.tileShapeCircle: 'Yuvarlak',
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
        AppStringKey.gameIntroTitle: 'Find the different one',
        AppStringKey.gameIntroBody:
          'Tap the colored tile that looks different from the others.',
        AppStringKey.gameIntroLives: 'A wrong choice costs one life.',
        AppStringKey.gameIntroStart: 'Got it, start',
        AppStringKey.gameTile: 'Game tile {index}',
        AppStringKey.gameLives: '{count} lives remaining',
        AppStringKey.personalBest: 'Personal best: {level}',
        AppStringKey.statsCorrect: 'Correct: {count}',
        AppStringKey.statsWrong: 'Wrong: {count}',
        AppStringKey.statsAccuracy: 'Accuracy: {percent}%',
        AppStringKey.statsBestStreak: 'Best streak: {count}',
        AppStringKey.streakMessage: '{count} correct in a row!',
        AppStringKey.recordGap: '{count} levels to your record',
      AppStringKey.turkish: 'Türkçe',
      AppStringKey.english: 'English',
      AppStringKey.scoreboard: 'Scoreboard',
      AppStringKey.yourName: 'Your name',
      AppStringKey.saveScore: 'Save',
      AppStringKey.scoreboardEmpty: 'No scores yet',
      AppStringKey.scoreboardUnavailable: 'Scoreboard is unavailable',
      AppStringKey.newRecord: 'New record!',
      AppStringKey.scoreSaved: 'You made the leaderboard!',
      AppStringKey.scoreboardNotEntered: 'You did not make the leaderboard',
      AppStringKey.scoreboardTopFive: 'Top 5',
      AppStringKey.scoreboardChampions: 'HUE CHAMPIONS',
      AppStringKey.scoreboardConnectedScores: '{count} connected scores',
      AppStringKey.scoreboardGlobalStandings: 'GLOBAL STANDINGS',
      AppStringKey.tileShape: 'Tile shape',
      AppStringKey.tileShapeHint: 'Choose how the game tiles look',
      AppStringKey.tileShapeSquare: 'Square',
      AppStringKey.tileShapeHexagon: 'Hexagon',
      AppStringKey.tileShapeCircle: 'Circle',
    },
  };

  /// Eksik anahtarda fallback dile, o da yoksa anahtarın kendisine düşer.
  static String translate(String languageCode, String key) {
    return translations[languageCode]?[key] ??
        translations[AppLanguages.fallback]?[key] ??
        key;
  }
}
