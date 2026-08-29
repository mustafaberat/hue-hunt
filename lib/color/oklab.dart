/// OKLab dönüşümleri (Björn Ottosson). Dış renk kütüphanesi yok.
///
/// Akış: encoded sRGB → linear → LMS küp kök → OKLab
/// ve tersi. Gamut, linear RGB'nin [0,1] içinde kalmasıdır; clamp yok.
library;

import 'dart:math' as math;

import 'rgb.dart';

class Oklab {
  const Oklab(this.l, this.a, this.b);

  /// Lightness ~0–1.
  final double l;

  /// green ↔ red
  final double a;

  /// blue ↔ yellow
  final double b;
}

double _cbrt(double value) {
  if (value < 0) {
    return -math.pow(-value, 1 / 3).toDouble();
  }
  return math.pow(value, 1 / 3).toDouble();
}

/// Encoded sRGB → linear-light (CVD simülasyonu da bunu kullanır).
Rgb srgbToLinearRgb(Rgb encoded) =>
    Rgb(_linearize(encoded.r), _linearize(encoded.g), _linearize(encoded.b));

/// Linear-light → encoded sRGB.
Rgb linearRgbToSrgb(Rgb linear) =>
    Rgb(_delinearize(linear.r), _delinearize(linear.g), _delinearize(linear.b));

/// Encoded sRGB → linear-light.
double _linearize(double channel) {
  if (channel <= 0.04045) {
    return channel / 12.92;
  }
  return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
}

/// Linear-light → encoded sRGB.
double _delinearize(double channel) {
  if (channel <= 0.0031308) {
    return 12.92 * channel;
  }
  return 1.055 * math.pow(channel, 1 / 2.4).toDouble() - 0.055;
}

Oklab rgbToOklab(Rgb rgb) {
  final r = _linearize(rgb.r);
  final g = _linearize(rgb.g);
  final b = _linearize(rgb.b);

  final l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b;
  final m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b;
  final s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b;

  final l_ = _cbrt(l);
  final m_ = _cbrt(m);
  final s_ = _cbrt(s);

  return Oklab(
    0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
    1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
    0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_,
  );
}

/// OKLab → linear sRGB. [inGamut] bu değerler üzerinde bakılır.
Rgb oklabToLinearRgb(Oklab lab) {
  final l_ = lab.l + 0.3963377774 * lab.a + 0.2158037573 * lab.b;
  final m_ = lab.l - 0.1055613458 * lab.a - 0.0638541728 * lab.b;
  final s_ = lab.l - 0.0894841775 * lab.a - 1.2914855480 * lab.b;

  final l = l_ * l_ * l_;
  final m = m_ * m_ * m_;
  final s = s_ * s_ * s_;

  return Rgb(
    4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
    -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
    -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
  );
}

bool isOklabInGamut(Oklab lab) => oklabToLinearRgb(lab).inGamut;

Rgb oklabToRgb(Oklab lab) {
  final linear = oklabToLinearRgb(lab);
  return Rgb(
    _delinearize(linear.r),
    _delinearize(linear.g),
    _delinearize(linear.b),
  );
}

/// CSS HSL → encoded sRGB. Base renk üretimi kontrollü H/S/L aralığında.
Rgb hslToRgb(double hue, double saturation, double lightness) {
  final h = hue % 360;
  double channel(double n) {
    final k = (n + h / 30) % 12;
    final a = saturation * math.min(lightness, 1 - lightness);
    return lightness - a * math.max(-1, math.min(k - 3, math.min(9 - k, 1)));
  }

  return Rgb(channel(0), channel(8), channel(4));
}
