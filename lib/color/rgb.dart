/// Encoded sRGB (0–1). Generator gamut kontrolü ve 8-bit kuantizasyon burada.
library;

class Rgb {
  const Rgb(this.r, this.g, this.b);

  const Rgb.from8Bit(int r8, int g8, int b8)
    : r = r8 / 255.0,
      g = g8 / 255.0,
      b = b8 / 255.0;

  final double r;
  final double g;
  final double b;

  bool get inGamut => r >= 0 && r <= 1 && g >= 0 && g <= 1 && b >= 0 && b <= 1;

  /// CVD matris çıktısı gamut dışına kaçabilir; mesafede clamp edilir.
  Rgb clamped() => Rgb(r.clamp(0.0, 1.0), g.clamp(0.0, 1.0), b.clamp(0.0, 1.0));

  /// Ekranda görünen 8-bit değere yuvarla — doğrulama kuantize renk üzerinden yapılır.
  Rgb quantized() =>
      Rgb(_quantizeChannel(r), _quantizeChannel(g), _quantizeChannel(b));

  int get r8 => (r * 255).round().clamp(0, 255);
  int get g8 => (g * 255).round().clamp(0, 255);
  int get b8 => (b * 255).round().clamp(0, 255);

  static double _quantizeChannel(double channel) =>
      (channel * 255).round().clamp(0, 255) / 255.0;

  @override
  bool operator ==(Object other) =>
      other is Rgb && other.r == r && other.g == g && other.b == b;

  @override
  int get hashCode => Object.hash(r, g, b);

  @override
  String toString() => 'Rgb($r8, $g8, $b8)';
}
