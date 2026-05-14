import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'l10n/l10n.dart';
import 'router/app_router.dart';
import 'services/notification_service.dart';
import 'utils/url_strategy_stub.dart'
    if (dart.library.html) 'utils/url_strategy_web.dart';

final _appRouter = AppRouter();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();
  await Hive.initFlutter();
  await initializeDateFormatting('nl_NL');
  await NotificationService.instance.initialize();
  NotificationService.instance.onNotificationTap = (alertId) {
    _appRouter.push(DetailRoute(alertId: alertId));
  };
  runApp(const ProviderScope(child: DutchWarningsApp()));
}

class DutchWarningsApp extends StatelessWidget {
  const DutchWarningsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dutch Warnings',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('nl', 'NL'),
        Locale('en', 'US'),
      ],
      routerConfig: _appRouter.config(
        deepLinkBuilder: (deepLink) {
          final segments = Uri.parse(deepLink.path).pathSegments;
          if (segments.length == 2 && segments.first == 'warning') {
            return DeepLink([
              const MainRoute(),
              DetailRoute(alertId: segments[1]),
            ]);
          }
          if (segments.length == 1 && segments.first == 'settings') {
            return DeepLink([
              const MainRoute(),
              const SettingsRoute(),
            ]);
          }
          return deepLink;
        },
      ),
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFAE1C28),
          secondary: const Color(0xFFFF8C00),
          brightness: Brightness.light,
        ),
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFAE1C28),
          secondary: const Color(0xFFFF8C00),
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
