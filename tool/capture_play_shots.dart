/// Play Console görselleri: gerçek Hue Hunt ekranlarını Play ölçülerinde PNG yazar.
///
/// Çalıştır: `scripts/generate_game_images.sh`
/// Çıktı: `play/gorseller/{ozellik-grafik,telefon,tablet,pc,chromebook}/`
library;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hue_hunt/app.dart';
import 'package:hue_hunt/components/app_logo.dart';
import 'package:hue_hunt/components/color_box.dart';
import 'package:hue_hunt/config/app_config.dart';
import 'package:hue_hunt/settings/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Play Console zorunlu / önerilen piksel ölçüleri (UI token değil).
const Size _featureSize = Size(1024, 500);
const Size _phoneSize = Size(1080, 1920);
const Size _tabletSize = Size(1440, 2560);
const Size _wideSize = Size(1920, 1080);

const String _outRoot = 'play/gorseller';

void main() {
  testWidgets('Play gorsellerini yaz', (tester) async {
    await tester.runAsync(_loadRealFonts);
    final shots = <String, Future<void> Function(WidgetTester, String)>{
      '01-anasayfa': _shotHome,
      '02-oyun': _shotGameEarly,
      '03-oyun-zor': _shotGameHard,
      '04-ayarlar': _shotSettings,
      '05-oyun-bitti': _shotGameOver,
    };

    _setView(tester, _featureSize);
    final featureKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: featureKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          home: const _FeatureGraphic(),
        ),
      ),
    );
    await _settle(tester);
    await _writePng(
      tester,
      featureKey,
      '$_outRoot/ozellik-grafik/hue-hunt-1024x500.png',
    );

    const devices = <String, Size>{
      'telefon': _phoneSize,
      'tablet': _tabletSize,
      'pc': _wideSize,
      'chromebook': _wideSize,
    };

    for (final device in devices.entries) {
      for (final shot in shots.entries) {
        _setView(tester, device.value);
        await shot.value(tester, '$_outRoot/${device.key}/${shot.key}.png');
      }
    }
  }, timeout: const Timeout(Duration(minutes: 4)));
}

/// Widget test varsayılanı Ahem (her harf kare). Play görseli için gerçek font.
Future<void> _loadRealFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  expect(root, isNotNull, reason: 'FLUTTER_ROOT yok');
  final dir = '$root/bin/cache/artifacts/material_fonts';

  Future<ByteData> bytes(String name) async {
    final data = await File('$dir/$name').readAsBytes();
    return ByteData.sublistView(data);
  }

  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final file in files) {
      loader.addFont(bytes(file));
    }
    await loader.load();
  }

  await load('Roboto', [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
    'Roboto-Black.ttf',
  ]);
  await load('MaterialIcons', ['MaterialIcons-Regular.otf']);
}

Future<void> _settle(WidgetTester tester) {
  return tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 5),
  );
}

void _setView(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding.zero;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
}

Future<SettingsStore> _readySettings() async {
  SharedPreferences.setMockInitialValues({
    AppPrefsKeys.language: AppLanguages.tr,
  });
  final settings = SettingsStore();
  await settings.load();
  return settings;
}

Future<GlobalKey> _pumpApp(WidgetTester tester) async {
  final settings = await _readySettings();
  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: HueHuntApp(settings: settings),
    ),
  );
  await _settle(tester);
  return key;
}

Future<void> _shotHome(WidgetTester tester, String path) async {
  final key = await _pumpApp(tester);
  await _writePng(tester, key, path);
}

Future<void> _shotGameEarly(WidgetTester tester, String path) async {
  final key = await _pumpApp(tester);
  await _openPlay(tester);
  await _writePng(tester, key, path);
}

Future<void> _shotGameHard(WidgetTester tester, String path) async {
  final key = await _pumpApp(tester);
  await _openPlay(tester);
  // Level 5 = 4×4. Her doğru seçimde rebirth bitsin.
  for (var i = 0; i < 4; i++) {
    await tester.tap(_oddBox());
    await tester.pump(AppMotion.levelAdvanceDelay);
    await _settle(tester);
  }
  await _writePng(tester, key, path);
}

Future<void> _shotSettings(WidgetTester tester, String path) async {
  final key = await _pumpApp(tester);
  await tester.tap(find.text(AppStrings.translate(AppLanguages.tr, AppStringKey.settings)));
  await _settle(tester);
  await _writePng(tester, key, path);
}

Future<void> _shotGameOver(WidgetTester tester, String path) async {
  final key = await _pumpApp(tester);
  await _openPlay(tester);
  for (var i = 0; i < 4; i++) {
    await tester.tap(_oddBox());
    await tester.pump(AppMotion.levelAdvanceDelay);
    await _settle(tester);
  }
  // Aynı kutuya tekrar basmak can yakmaz; her seferinde güncel ağaçtan yanlış seç.
  for (var i = 0; i < 3; i++) {
    await tester.tap(_majorityBox());
    await tester.pump();
    await tester.pump(AppMotion.wrongFeedback);
  }
  await tester.pump(AppMotion.gameOverReveal);
  await _settle(tester);
  await _writePng(tester, key, path);
}

Future<void> _openPlay(WidgetTester tester) async {
  final play = AppStrings.translate(AppLanguages.tr, AppStringKey.play).toUpperCase();
  await tester.tap(find.text(play));
  await _settle(tester);
}

Finder _oddBox() {
  final boxes = _colorBoxes();
  final freq = <Color, int>{};
  for (final box in boxes) {
    freq[box.color] = (freq[box.color] ?? 0) + 1;
  }
  final odd = freq.entries.singleWhere((e) => e.value == 1).key;
  return find.byWidgetPredicate((w) => w is ColorBox && w.color == odd);
}

Finder _majorityBox() {
  final boxes = _colorBoxes();
  final freq = <Color, int>{};
  for (final box in boxes) {
    freq[box.color] = (freq[box.color] ?? 0) + 1;
  }
  final majority = freq.entries.firstWhere((e) => e.value > 1).key;
  return find.byWidgetPredicate((w) {
    return w is ColorBox &&
        w.color == majority &&
        w.feedback != BoxFeedback.wrong &&
        w.enabled;
  }).first;
}

List<ColorBox> _colorBoxes() {
  return find.byType(ColorBox).evaluate().map((e) => e.widget as ColorBox).toList();
}

Future<void> _writePng(WidgetTester tester, GlobalKey key, String path) async {
  await tester.pump();
  final bytes = await tester.binding.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes!);
}

/// 1024×500 özellik grafiği — aynı arka plan, logo ve mağaza adı.
class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 168),
            const SizedBox(width: 40),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppIdentity.appName.toUpperCase(),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 56,
                        letterSpacing: 3,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.translate(AppLanguages.tr, AppStringKey.tagline),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 22,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
