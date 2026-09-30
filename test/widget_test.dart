import 'package:flutter_test/flutter_test.dart';
import 'package:hue_hunt/app.dart';
import 'package:hue_hunt/components/color_box.dart';
import 'package:hue_hunt/settings/settings_store.dart';

void main() {
  testWidgets('home shows play and opens a 4-box level', (tester) async {
    await tester.pumpWidget(HueHuntApp(settings: SettingsStore()));

    expect(find.text('HUE HUNT'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);

    await tester.tap(find.text('PLAY'));
    await tester.pumpAndSettle();

    expect(find.byType(ColorBox), findsNWidgets(4));
    expect(find.textContaining('Level'), findsOneWidget);
    expect(find.text('Find the different one'), findsOneWidget);

    await tester.tap(find.text('GOT IT, START'));
    await tester.pumpAndSettle();

    expect(find.text('Find the different one'), findsNothing);
  });

  testWidgets('settings can switch language', (tester) async {
    await tester.pumpWidget(HueHuntApp(settings: SettingsStore()));

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Türkçe'));
    await tester.pumpAndSettle();

    expect(find.text('Ayarlar'), findsWidgets);
    expect(find.text('Renk körü modu'), findsOneWidget);
  });
}
