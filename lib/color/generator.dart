/// Round renk çifti. RGB delta kullanılmaz; fark OKLab ekseninde uygulanır.
///
/// [ColorGenerator.colorBlindSafe] açıkken kırmızı-yeşil (a) ekseni yok;
/// çift deuteranopia + protanopia simülasyonunda da ayırt edilir kalır.
/// Başarısız üretimde delta biraz düşer, yine olmazsa güvenli çifte düşülür.
/// Clamp yok — gamut dışına çıkan aday atılır.
library;

import 'dart:math';

import '../config/app_config.dart';
import 'cvd.dart';
import 'distance.dart';
import 'oklab.dart';
import 'rgb.dart';

class RoundColors {
  const RoundColors({
    required this.base,
    required this.different,
    required this.delta,
  });

  final Rgb base;
  final Rgb different;
  final double delta;
}

class ColorGenerator {
  ColorGenerator({
    Random? random,
    this.background = GameConfig.backgroundColor,
    this.colorBlindSafe = false,
  }) : _random = random ?? Random();

  final Random _random;

  /// Arka plan [AppColors.backgroundRgb] ile aynı kanallardır.
  final Rgb background;

  /// Açıkken fark L / b ekseninde üretilir ve deutan+protan simülasyonundan geçer.
  bool colorBlindSafe;

  RoundColors generateRoundColors(double delta) {
    var currentDelta = max(delta, GameConfig.minPlayableDelta);

    for (var pass = 0; pass < GameConfig.fallbackDeltaRetries; pass++) {
      for (
        var attempt = 0;
        attempt < GameConfig.maxColorGenerationAttempts;
        attempt++
      ) {
        final pair = _tryGenerate(currentDelta);
        if (pair != null) {
          return pair;
        }
      }
      currentDelta = max(
        GameConfig.minPlayableDelta,
        currentDelta * GameConfig.fallbackDeltaScale,
      );
    }

    return _fallbackPair(currentDelta);
  }

  Rgb generateBaseColor() {
    for (
      var attempt = 0;
      attempt < GameConfig.maxColorGenerationAttempts;
      attempt++
    ) {
      final candidate = _randomHslColor();
      if (_isSafeFromBackground(candidate)) {
        return candidate;
      }
    }
    return GameConfig.fallbackBase;
  }

  Rgb? generateDifferentColor(Rgb base, double delta) {
    return _applyDelta(rgbToOklab(base), delta);
  }

  RoundColors? _tryGenerate(double delta) {
    final base = generateBaseColor();
    final different = generateDifferentColor(base, delta);
    if (different == null) {
      return null;
    }
    if (!_isValidPair(base, different, delta)) {
      return null;
    }
    return RoundColors(base: base, different: different, delta: delta);
  }

  bool _isValidPair(Rgb base, Rgb different, double delta) {
    if (base == different) {
      return false;
    }
    if (!base.inGamut || !different.inGamut) {
      return false;
    }
    if (!_isSafeFromBackground(base) || !_isSafeFromBackground(different)) {
      return false;
    }

    final distance = rgbOklabDistance(base, different);
    final minDelta = delta * (1 - GameConfig.deltaTolerance);
    final maxDelta = delta * (1 + GameConfig.deltaTolerance);
    if (distance < minDelta || distance > maxDelta) {
      return false;
    }

    if (colorBlindSafe) {
      final minCvd = delta * GameConfig.colorBlindDistanceFactor;
      if (!isPairColorBlindSafe(base, different, minCvd)) {
        return false;
      }
    }
    return true;
  }

  bool _isSafeFromBackground(Rgb color) {
    return rgbOklabDistance(color, background) >=
        GameConfig.minBackgroundDistance;
  }

  Rgb _randomHslColor() {
    final hue =
        GameConfig.hueMin +
        _random.nextDouble() * (GameConfig.hueMax - GameConfig.hueMin);
    final saturation =
        GameConfig.saturationMin +
        _random.nextDouble() *
            (GameConfig.saturationMax - GameConfig.saturationMin);
    final lightness =
        GameConfig.lightnessMin +
        _random.nextDouble() *
            (GameConfig.lightnessMax - GameConfig.lightnessMin);
    return hslToRgb(hue, saturation, lightness).quantized();
  }

  /// Rastgele eksen ve işaret; L [0,1] dışına veya gamut dışına çıkarsa dene.
  /// Renk körü modunda a (kırmızı-yeşil) yok — deutan/protan onu göremez.
  Rgb? _applyDelta(Oklab base, double delta) {
    final axes = List<String>.from(
      colorBlindSafe ? GameConfig.colorBlindDeltaAxes : const ['L', 'a', 'b'],
    )..shuffle(_random);
    final directions = [1.0, -1.0]..shuffle(_random);

    for (final axis in axes) {
      for (final direction in directions) {
        final shifted = _shift(base, axis, direction * delta);
        if (axis == 'L' && (shifted.l < 0 || shifted.l > 1)) {
          continue;
        }
        if (!isOklabInGamut(shifted)) {
          continue;
        }
        return oklabToRgb(shifted).quantized();
      }
    }
    return null;
  }

  Oklab _shift(Oklab base, String axis, double amount) {
    switch (axis) {
      case 'L':
        return Oklab(base.l + amount, base.a, base.b);
      case 'a':
        return Oklab(base.l, base.a + amount, base.b);
      default:
        return Oklab(base.l, base.a, base.b + amount);
    }
  }

  RoundColors _fallbackPair(double delta) {
    final base = GameConfig.fallbackBase;
    if (colorBlindSafe) {
      final lab = rgbToOklab(base);
      final up = Oklab(lab.l + delta, lab.a, lab.b);
      final down = Oklab(lab.l - delta, lab.a, lab.b);
      final shifted = isOklabInGamut(up) ? up : down;
      return RoundColors(
        base: base,
        different: oklabToRgb(shifted).quantized(),
        delta: delta,
      );
    }
    final different =
        generateDifferentColor(base, delta) ?? GameConfig.fallbackDifferent;
    return RoundColors(base: base, different: different, delta: delta);
  }
}
