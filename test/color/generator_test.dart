import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hue_hunt/color/distance.dart';
import 'package:hue_hunt/color/generator.dart';
import 'package:hue_hunt/color/rgb.dart';
import 'package:hue_hunt/config/game_config.dart';

void main() {
  late ColorGenerator generator;

  setUp(() {
    generator = ColorGenerator(random: Random(42));
  });

  test('generated base color is in gamut and away from background', () {
    for (var i = 0; i < 40; i++) {
      final base = generator.generateBaseColor();
      expect(base.inGamut, isTrue);
      expect(
        rgbOklabDistance(base, GameConfig.backgroundColor),
        greaterThanOrEqualTo(GameConfig.minBackgroundDistance),
      );
    }
  });

  test('round colors stay valid across difficulty deltas', () {
    const deltas = [0.18, 0.11, 0.07, 0.04, 0.029, 0.025];
    for (final delta in deltas) {
      for (var i = 0; i < 12; i++) {
        final pair = generator.generateRoundColors(delta);
        expect(pair.base.inGamut, isTrue);
        expect(pair.different.inGamut, isTrue);
        expect(pair.base == pair.different, isFalse);
        expect(
          rgbOklabDistance(pair.base, GameConfig.backgroundColor),
          greaterThanOrEqualTo(GameConfig.minBackgroundDistance),
        );
        expect(
          rgbOklabDistance(pair.different, GameConfig.backgroundColor),
          greaterThanOrEqualTo(GameConfig.minBackgroundDistance),
        );
        expect(
          rgbOklabDistance(pair.base, pair.different),
          greaterThan(0),
        );
      }
    }
  });

  test('different index candidates stay in box range for a round', () {
    final pair = generator.generateRoundColors(0.12);
    expect(pair.base, isA<Rgb>());
    expect(pair.different, isA<Rgb>());
  });
}
