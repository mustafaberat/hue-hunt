import 'package:flutter_test/flutter_test.dart';
import 'package:hue_hunt/color/oklab.dart';
import 'package:hue_hunt/color/distance.dart';
import 'package:hue_hunt/color/rgb.dart';

void main() {
  group('oklab conversion', () {
    test('rgbToOklab and oklabToRgb roundtrip in-gamut colors', () {
      const samples = [
        Rgb(0, 0, 0),
        Rgb(1, 1, 1),
        Rgb(1, 0, 0),
        Rgb(0, 1, 0),
        Rgb(0, 0, 1),
        Rgb(0.2, 0.4, 0.6),
        Rgb(0.5, 0.5, 0.5),
        Rgb.from8Bit(0x10, 0x11, 0x14),
      ];

      for (final rgb in samples) {
        final restored = oklabToRgb(rgbToOklab(rgb));
        expect((restored.r - rgb.r).abs(), lessThan(1e-4), reason: '$rgb r');
        expect((restored.g - rgb.g).abs(), lessThan(1e-4), reason: '$rgb g');
        expect((restored.b - rgb.b).abs(), lessThan(1e-4), reason: '$rgb b');
      }
    });

    test('white is near L=1 and black is near L=0', () {
      expect(rgbToOklab(const Rgb(1, 1, 1)).l, closeTo(1.0, 0.01));
      expect(rgbToOklab(const Rgb(0, 0, 0)).l, closeTo(0.0, 0.01));
    });
  });

  group('oklabDistance', () {
    test('identical colors have zero distance', () {
      const color = Rgb(0.3, 0.5, 0.7);
      expect(oklabDistance(rgbToOklab(color), rgbToOklab(color)), 0);
      expect(rgbOklabDistance(color, color), 0);
    });

    test('different colors have positive distance', () {
      const a = Rgb(1, 0, 0);
      const b = Rgb(0, 0, 1);
      expect(rgbOklabDistance(a, b), greaterThan(0.1));
    });
  });
}
