/// Kırmızı-yeşil renk körlüğü simülasyonu (Machado, Oliveira, Fernandes 2009).
///
/// Matrisler linear sRGB üzerinedir, severity = 1 (tam dikromasi).
/// Tritanopia (~%0.008) yok: "renk körü" neredeyse her zaman deutan/protan.
library;

import 'distance.dart';
import 'oklab.dart';
import 'rgb.dart';

enum CvdType { deuteranopia, protanopia }

/// Machado 2009, tam deuteranopia / protanopia. Satır-major 3×3.
const Map<CvdType, List<double>> _machado = {
  CvdType.deuteranopia: [
    0.367322,
    0.860646,
    -0.227968,
    0.280085,
    0.672501,
    0.047413,
    -0.011820,
    0.042940,
    0.968881,
  ],
  CvdType.protanopia: [
    0.152286,
    1.052583,
    -0.204868,
    0.114503,
    0.786281,
    0.099216,
    -0.003882,
    -0.048116,
    1.051998,
  ],
};

Rgb simulateCvd(Rgb encoded, CvdType type) {
  final linear = srgbToLinearRgb(encoded);
  final m = _machado[type]!;
  final simulated = Rgb(
    m[0] * linear.r + m[1] * linear.g + m[2] * linear.b,
    m[3] * linear.r + m[4] * linear.g + m[5] * linear.b,
    m[6] * linear.r + m[7] * linear.g + m[8] * linear.b,
  );
  return linearRgbToSrgb(simulated.clamped());
}

double cvdOklabDistance(Rgb a, Rgb b, CvdType type) {
  return rgbOklabDistance(simulateCvd(a, type), simulateCvd(b, type));
}

/// Çift, kırmızı-yeşil CVD simülasyonunda [minDistance] kadar ayrışıyor mu.
bool isPairColorBlindSafe(Rgb base, Rgb different, double minDistance) {
  for (final type in CvdType.values) {
    if (cvdOklabDistance(base, different, type) < minDistance) {
      return false;
    }
  }
  return true;
}
