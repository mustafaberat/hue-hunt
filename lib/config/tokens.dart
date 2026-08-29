/// Hue Hunt — tüm görünür ve yapısal sabitlerin tek kaynağı.
///
/// Padding, renk, süre, rota, kimlik gibi değerler UI dosyalarına
/// yazılmaz. Bir token değişince uygulama genelinde yayılır.
///
/// Arka planı değiştirmek için yalnızca [AppColors.backgroundR/G/B] yeter.
library;

import 'package:flutter/material.dart';

import '../color/rgb.dart';

// ---------------------------------------------------------------------------
// Kimlik
// ---------------------------------------------------------------------------

/// Mağaza / native kimlik. Ekran metinleri [AppStrings] üzerinden gelir.
abstract final class AppIdentity {
  static const String appName = 'Hue Hunt';
  static const String developer = 'ARU SOFT';
  static const String packageId = 'com.arusoft.huehunt';
  /// pubspec `version` ile aynı X.Y.Z (Play +CODE hariç).
  static const String version = '3.0.1';
}

// ---------------------------------------------------------------------------
// Rotalar ve kayıt anahtarları
// ---------------------------------------------------------------------------

abstract final class AppRoutes {
  static const String home = '/';
  static const String game = '/game';
  static const String settings = '/settings';
}

/// SharedPreferences anahtarları. Metin içeriği değil, depolama id'si.
abstract final class AppPrefsKeys {
  static const String language = 'language';
  static const String colorBlindMode = 'color_blind_mode';
  static const String sound = 'sound';
  static const String haptic = 'haptic';
}

// ---------------------------------------------------------------------------
// Renkler — RGB kanalları tek kaynaktır
// ---------------------------------------------------------------------------

abstract final class AppColors {
  /// Oyun arka planı (#101114). UI Color ve OKLab generator aynı kanalları kullanır.
  static const int backgroundR = 0x10;
  static const int backgroundG = 0x11;
  static const int backgroundB = 0x14;
  static const int overlayAlpha = 0xCC;

  /// Generator çökerse kullanılan güvenli çift. Logo da aynı RGB'yi kullanır.
  static const int fallbackBaseR = 0x3A;
  static const int fallbackBaseG = 0x8A;
  static const int fallbackBaseB = 0x9A;
  static const int fallbackDifferentR = 0x4A;
  static const int fallbackDifferentG = 0x9C;
  static const int fallbackDifferentB = 0x84;

  static const Color background = Color.fromARGB(
    255,
    backgroundR,
    backgroundG,
    backgroundB,
  );
  static const Color overlay = Color.fromARGB(
    overlayAlpha,
    backgroundR,
    backgroundG,
    backgroundB,
  );
  static const Color surface = Color(0xFF181A1F);
  static const Color text = Color(0xFFF4F5F7);
  static const Color textMuted = Color(0xFF9AA0AB);
  static const Color accent = text;
  static const Color heart = Color(0xFFFF5A70);
  static const Color heartLost = Color(0x33FF5A70);
  static const Color wrongBorder = Color(0xE6FF5A70);
  static const Color correctBorder = text;
  static const Color divider = Color(0x14FFFFFF);
  static const Color chipIdle = Color(0x14FFFFFF);
  static const Color transparent = Color(0x00000000);

  /// OKLab generator'ın kullandığı arka plan (aynı RGB kanallar).
  static const Rgb backgroundRgb = Rgb.from8Bit(
    backgroundR,
    backgroundG,
    backgroundB,
  );
  static const Rgb fallbackBaseRgb = Rgb.from8Bit(
    fallbackBaseR,
    fallbackBaseG,
    fallbackBaseB,
  );
  static const Rgb fallbackDifferentRgb = Rgb.from8Bit(
    fallbackDifferentR,
    fallbackDifferentG,
    fallbackDifferentB,
  );

  static const Color logoBase = Color.fromARGB(
    255,
    fallbackBaseR,
    fallbackBaseG,
    fallbackBaseB,
  );
  static const Color logoAccent = Color.fromARGB(
    255,
    fallbackDifferentR,
    fallbackDifferentG,
    fallbackDifferentB,
  );
}

/// Oyun kutusu rengi Flutter [Color]'a burada dönüşür.
extension RgbToColor on Rgb {
  Color toColor() => Color.fromARGB(255, r8, g8, b8);
}

// ---------------------------------------------------------------------------
// Boyutlar / boşluklar
// ---------------------------------------------------------------------------

abstract final class AppDimens {
  static const double pagePadding = 24;
  static const double pagePaddingTight = 16;
  static const double pagePaddingXTight = 8;
  static const double headerTopPadding = 8;
  static const double headerBottomPadding = 16;
  static const double settingsHeaderStart = 8;
  static const double settingsHeaderTop = 4;
  static const double settingsHeaderEndGap = 8;
  static const double settingsListTop = 8;
  static const double settingsListBottom = 24;
  static const double cardPadding = 18;
  static const double cardRadius = 20;
  static const double overlayMaxWidth = 360;
  static const double overlayInset = 8;
  static const double overlayInnerTop = 32;
  static const double overlayInner = 24;

  static const double spaceTiny = 3;
  static const double spaceXXSmall = 4;
  static const double spaceXSmall = 8;
  static const double spaceSmall = 10;
  static const double spaceMedium = 12;
  static const double spaceRegular = 14;
  static const double spaceLarge = 20;
  static const double spaceXLarge = 28;

  static const double minTouchTarget = 44;
  static const double headerHeight = 48;
  static const double buttonHeight = 56;
  static const double languageChipHeight = 48;
  static const double buttonRadius = 18;
  static const double languageChipRadius = 14;
  static const double dividerHeight = 1;
  static const double toggleRowVertical = 6;
  static const double metaRowVertical = 10;

  static const double boxGap = 12;
  static const double boxRadius = 18;
  static const double boxRadiusMin = 6;
  static const double boxRadiusFactor = 0.22;
  static const double boxCorrectBorderWidth = 3;
  static const double boxWrongBorderWidth = 2;
  static const double boxIdleBorderWidth = 0;
  static const double boxSuccessScale = 1.04;
  static const double boxIdleScale = 1.0;
  static const double shakeAmplitude = 6;

  static const double logoSize = 132;
  static const double logoGap = 10;
  static const int logoGrid = 2;

  static const double iconSettings = 18;
  static const double iconSection = 20;
  static const double iconHeart = 22;
  static const double iconClose = 24;

  static const int homeTopFlex = 3;
  static const int homeMidFlex = 3;
  static const int homeBottomFlex = 1;
}

// ---------------------------------------------------------------------------
// Tipografi
// ---------------------------------------------------------------------------

abstract final class AppType {
  static const double display = 42;
  static const double title = 22;
  static const double body = 16;
  static const double bodyMuted = 15;
  static const double tagline = 17;
  static const double button = 18;

  static const double displayHeight = 1.05;
  static const double displayTracking = 4;
  static const double titleTracking = 0.4;
  static const double buttonTracking = 1.6;
  static const double overlayTracking = 1.4;
  static const double settingsLinkTracking = 0.4;

  static const FontWeight displayWeight = FontWeight.w800;
  static const FontWeight titleWeight = FontWeight.w700;
  static const FontWeight bodyWeight = FontWeight.w500;
  static const FontWeight buttonWeight = FontWeight.w800;
  static const FontWeight settingsLinkWeight = FontWeight.w600;
  static const FontWeight chipWeight = FontWeight.w700;
}

// ---------------------------------------------------------------------------
// Süreler / animasyon
// ---------------------------------------------------------------------------

abstract final class AppMotion {
  static const Duration wrongFeedback = Duration(milliseconds: 160);
  static const Duration correctFeedback = Duration(milliseconds: 180);
  static const Duration gameOverReveal = Duration(milliseconds: 700);

  /// Doğru kutunun kısa parlaması; ardından [gridRebirth] başlar.
  static const Duration levelAdvanceDelay = Duration(milliseconds: 80);

  /// Her seviye atlayışında kutular söner, yeniden doğar, yerine hizalanır.
  static const Duration gridRebirth = Duration(milliseconds: 240);
  static const Cubic gridRebirthCurve = Cubic(0.2, 0.0, 0.0, 1.0);

  /// 0–split eski grid söner; split–1 yeni grid doğar.
  static const double gridRebirthSplit = 0.36;
  static const double gridRebirthOutScale = 0.84;
  static const double gridRebirthInScale = 0.82;

  /// Yeni kutular merkeze biraz yakın doğar, slotlarına kayar.
  static const double gridRebirthAlign = 0.14;

  /// Köşe kutular aynı süre içinde biraz geç doğar.
  static const double gridRebirthStagger = 0.20;

  static const int shakeOscillations = 6;
}
