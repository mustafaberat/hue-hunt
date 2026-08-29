/// MaterialApp kabuğu: tema, rotalar ve ayar dinleyicisi.
///
/// Ayar değişince [MaterialApp] yeniden kurulmaz; [builder] içindeki
/// [AppScope] güncellenir ki navigator yığını (oyun ekranı) kaybolmasın.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_scope.dart';
import 'config/app_config.dart';
import 'screens/game_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'settings/settings_store.dart';

class HueHuntApp extends StatelessWidget {
  const HueHuntApp({required this.settings, super.key});

  final SettingsStore settings;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppIdentity.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      builder: (context, child) {
        return ListenableBuilder(
          listenable: settings,
          builder: (context, _) {
            return AppScope(
              settings: settings,
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.game: (_) => const GameScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
      },
    );
  }
}

/// Binding, kalıcı ayarlar ve sistem çubuğu renkleri hazır olduktan sonra runApp.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = SettingsStore();
  await settings.load();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      systemNavigationBarColor: AppColors.background,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(HueHuntApp(settings: settings));
}
