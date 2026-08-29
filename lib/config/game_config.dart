/// Oyun kuralları ve renk üretimi eşikleri.
///
/// Grid boyutu, can, delta, OKLab güvenlik mesafesi burada durur.
/// UI boşlukları [AppDimens], palet [AppColors] içindedir — buraya kopyalanmaz.
library;

import 'tokens.dart';

/// Bir seviyenin kare grid'i ve perceptual renk farkı (OKLab delta).
class LevelSpec {
  const LevelSpec({
    required this.level,
    required this.grid,
    required this.delta,
  });

  final int level;

  /// Kare kenar: 2 → 2×2, 6 → 6×6. [GameConfig.maxGridSize] üstüne çıkılmaz.
  final int grid;

  /// Base ile farklı kutu arasındaki hedef OKLab mesafesi. Düştükçe zorlaşır.
  final double delta;

  int get columns => grid;
  int get rows => grid;
  int get boxCount => grid * grid;
}

abstract final class GameConfig {
  /// Session başındaki can. Level atlamak canı yenilemez; yalnızca restart eder.
  static const int initialLives = 3;
  static const int minBoxCount = 4;
  static const int minGridSize = 2;
  static const int maxGridSize = 6;

  /// Sonsuz döngü olmasın diye her üretim turu bu kadar deneme yapar.
  static const int maxColorGenerationAttempts = 100;

  /// Son N index tekrar seçilmesin diye tutulur.
  static const int recentIndexHistory = 3;

  /// 100 deneme yetmezse delta biraz düşürülüp yeniden denenir.
  static const int fallbackDeltaRetries = 3;
  static const double fallbackDeltaScale = 0.9;

  /// Kutu rengi arka plana bundan daha yakın olamaz (OKLab).
  static const double minBackgroundDistance = 0.18;

  /// İnsan gözünün pratikte ayırt edebileceği taban delta. Bunun altına inilmez.
  static const double minPlayableDelta = 0.025;

  /// Üretilen farkın hedef delta'ya ± bu oranda yakın olması gerekir.
  static const double deltaTolerance = 0.15;

  /// Renk körü modu: kırmızı-yeşil (OKLab a) ekseni kullanılmaz.
  /// Deuteranopia / protanopia bu ekseni göremez; L (parlaklık) ve
  /// b (mavi-sarı) ayırt edilebilir kalır.
  static const List<String> colorBlindDeltaAxes = ['L', 'b'];

  /// Simüle deuteranopia ve protanopia'da kalan OKLab mesafe, hedef
  /// delta'nın en az bu oranı olmalı. Altı = çift CVD'de erimiş.
  static const double colorBlindDistanceFactor = 0.55;

  /// Level 10+ için delta çarpanı: `delta * pow(decay, steps)`.
  static const double postLevelDecay = 0.82;

  static const double hueMin = 0;
  static const double hueMax = 360;
  static const double saturationMin = 0.45;
  static const double saturationMax = 0.90;
  static const double lightnessMin = 0.30;
  static const double lightnessMax = 0.75;

  /// Arka plan tek kaynaktan: [AppColors.backgroundR/G/B].
  static const backgroundColor = AppColors.backgroundRgb;
  static const fallbackBase = AppColors.fallbackBaseRgb;
  static const fallbackDifferent = AppColors.fallbackDifferentRgb;

  static const double minTouchTarget = AppDimens.minTouchTarget;
  static const double boxGap = AppDimens.boxGap;
  static const double boxRadius = AppDimens.boxRadius;

  static const Duration wrongFeedback = AppMotion.wrongFeedback;
  static const Duration correctFeedback = AppMotion.correctFeedback;
  static const Duration gameOverReveal = AppMotion.gameOverReveal;

  /// Level → kare grid. Dış oyun alanı sabit, kutu küçülür. Tavan 6×6.
  static const List<LevelSpec> levelSpecs = [
    LevelSpec(level: 1, grid: 2, delta: 0.18),
    LevelSpec(level: 2, grid: 2, delta: 0.14),
    LevelSpec(level: 3, grid: 3, delta: 0.11),
    LevelSpec(level: 4, grid: 3, delta: 0.085),
    LevelSpec(level: 5, grid: 4, delta: 0.070),
    LevelSpec(level: 6, grid: 4, delta: 0.055),
    LevelSpec(level: 7, grid: 5, delta: 0.045),
    LevelSpec(level: 8, grid: 5, delta: 0.038),
    LevelSpec(level: 9, grid: 6, delta: 0.032),
    LevelSpec(level: 10, grid: 6, delta: 0.029),
  ];

  /// Tablodaki son satırdan sonrası: grid 6×6 kalır, delta sönümlenir.
  static LevelSpec specForLevel(int level) {
    if (level <= 0) {
      return levelSpecs.first;
    }
    if (level <= levelSpecs.length) {
      return levelSpecs[level - 1];
    }

    final last = levelSpecs.last;
    final steps = level - last.level;
    final delta = (last.delta * powDecay(steps)).clamp(
      minPlayableDelta,
      last.delta,
    );

    return LevelSpec(level: level, grid: maxGridSize, delta: delta);
  }

  static double powDecay(int steps) {
    var value = 1.0;
    for (var i = 0; i < steps; i++) {
      value *= postLevelDecay;
    }
    return value;
  }
}
