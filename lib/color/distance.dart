/// OKLab Euclidean mesafe. Difficulty ve background-safe kontrolü bunu kullanır.
library;

import 'dart:math' as math;

import 'oklab.dart';
import 'rgb.dart';

double oklabDistance(Oklab a, Oklab b) {
  final dl = a.l - b.l;
  final da = a.a - b.a;
  final db = a.b - b.b;
  return math.sqrt(dl * dl + da * da + db * db);
}

double rgbOklabDistance(Rgb a, Rgb b) {
  return oklabDistance(rgbToOklab(a), rgbToOklab(b));
}
