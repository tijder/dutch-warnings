/// Integration screenshot tests — run on Linux desktop (real renderer, real fonts).
///
///   flutter test -d linux integration_test/screenshots_test.dart
///
/// Screenshots land in docs/screenshots/.
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:dutch_warnings/l10n/l10n.dart';
import 'package:dutch_warnings/models/alert.dart';
import 'package:dutch_warnings/providers/alerts_provider.dart';
import 'package:dutch_warnings/providers/location_provider.dart';
import 'package:dutch_warnings/providers/settings_provider.dart';
import 'package:dutch_warnings/screens/detail_screen.dart';
import 'package:dutch_warnings/screens/list_screen.dart';
import 'package:dutch_warnings/screens/map_overview_screen.dart';
import 'package:dutch_warnings/screens/settings_screen.dart';
import 'package:dutch_warnings/screens/stats_screen.dart';
import 'package:dutch_warnings/services/api_service.dart';
import 'package:dutch_warnings/services/cache_service.dart';
import 'package:dutch_warnings/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:latlong2/latlong.dart';

// ---------------------------------------------------------------------------
// Fake services (mirrors test/fixtures/fixtures.dart, kept inline to avoid
// cross-directory relative imports in the integration test build)
// ---------------------------------------------------------------------------

class _FakeApiService extends ApiService {
  _FakeApiService(this._pages);
  _FakeApiService.empty() : _pages = const [];

  final List<List<Alert>> _pages;
  int _callCount = 0;

  @override
  Future<List<Alert>> fetchAlerts({String? after}) async {
    if (_callCount >= _pages.length) return [];
    return _pages[_callCount++];
  }
}

class _FakeCacheService extends CacheService {
  final Map<String, Alert> _store = {};

  @override
  Future<void> saveAlerts(List<Alert> alerts) async {
    for (final a in alerts) {
      _store[a.id] = a;
    }
  }

  @override
  Future<List<Alert>> loadAlerts() async {
    final list = _store.values.toList()
      ..sort((a, b) => b.startAt.compareTo(a.startAt));
    return list;
  }

  @override
  Future<void> clear() async => _store.clear();
}

class _FakeSettingsService extends SettingsService {
  @override Future<String> getTileServerUrl() async => kDefaultTileServer;
  @override Future<void> setTileServerUrl(String url) async {}
  @override Future<void> resetTileServerUrl() async {}
  @override Future<bool> getAutoRefreshEnabled() async => false;
  @override Future<void> setAutoRefreshEnabled(bool v) async {}
  @override Future<int> getAutoRefreshInterval() async => 5;
  @override Future<void> setAutoRefreshInterval(int m) async {}
  @override Future<LocationMode> getLocationMode() async => LocationMode.automatic;
  @override Future<void> setLocationMode(LocationMode m) async {}
  @override Future<double?> getManualLatitude() async => null;
  @override Future<double?> getManualLongitude() async => null;
  @override Future<bool> getDebugInjectAlert() async => false;
  @override Future<void> setDebugInjectAlert(bool v) async {}
  @override Future<void> setManualCoordinates(double lat, double lng) async {}
}

// ---------------------------------------------------------------------------
// Test alert data
// ---------------------------------------------------------------------------

const _amsterdamPolygon =
    '52.3500,4.8500 52.4200,4.8500 52.4200,5.0000 52.3500,5.0000 52.3500,4.8500';
const _rotterdamPolygon =
    '51.8700,4.3000 51.9400,4.3000 51.9400,4.6000 51.8700,4.6000 51.8700,4.3000';
const _amsterdamCenter = LatLng(52.3700, 4.9000);

Alert _makeActive({
  required String id,
  String area = _amsterdamPolygon,
  required DateTime startAt,
}) =>
    Alert.fromJson({
      'id': id,
      'message': 'NL-Alert. Wateroverlast verwacht in de omgeving van Amsterdam. '
          'Vermijd laaggelegen gebieden en ondergrondse parkeergarages. '
          'Volg de aanwijzingen van de hulpdiensten op.'
          '***'
          'NL-Alert. Flooding expected in the area of Amsterdam. '
          'Avoid low-lying areas and underground car parks. '
          'Follow the instructions of the emergency services.',
      'type': 'nl-alert',
      'start_at': startAt.toIso8601String(),
      'stop_at': null,
      'area': [area],
      'resource_uri':
          'https://api.public-warning.app/api/v1/providers/nl-alert/alerts/$id',
    });

Alert _makeInactive({
  required String id,
  required DateTime startAt,
  required DateTime stopAt,
  String area = _rotterdamPolygon,
}) =>
    Alert.fromJson({
      'id': id,
      'message': 'NL-Alert. Brand in industriegebied Europoort te Rotterdam. '
          'Rook kan gevaarlijk zijn. Blijf binnen, sluit ramen en deuren.'
          '***'
          'NL-Alert. Fire in Europoort industrial area in Rotterdam. '
          'Smoke may be hazardous. Stay indoors, close windows and doors.',
      'type': 'nl-alert',
      'start_at': startAt.toIso8601String(),
      'stop_at': stopAt.toIso8601String(),
      'area': [area],
      'resource_uri':
          'https://api.public-warning.app/api/v1/providers/nl-alert/alerts/$id',
    });

// Realistic dataset: alerts spread across 2024–2025 for interesting charts.
final _allAlerts = [
  _makeActive(id: 'a1', startAt: DateTime.utc(2025, 5, 14, 9, 0)),
  _makeActive(id: 'a2', area: _rotterdamPolygon, startAt: DateTime.utc(2025, 5, 12, 14, 30)),
  _makeInactive(id: 'i1', startAt: DateTime.utc(2025, 3, 8, 11, 0), stopAt: DateTime.utc(2025, 3, 8, 15, 0)),
  _makeInactive(id: 'i2', startAt: DateTime.utc(2025, 1, 22, 7, 30), stopAt: DateTime.utc(2025, 1, 22, 9, 0)),
  _makeInactive(id: 'i3', startAt: DateTime.utc(2024, 11, 5, 13, 0), stopAt: DateTime.utc(2024, 11, 5, 20, 0)),
  _makeInactive(id: 'i4', startAt: DateTime.utc(2024, 9, 18, 8, 0), stopAt: DateTime.utc(2024, 9, 19, 8, 0)),
  _makeInactive(id: 'i5', startAt: DateTime.utc(2024, 7, 3, 10, 0), stopAt: DateTime.utc(2024, 7, 3, 12, 30)),
  _makeInactive(id: 'i6', area: _amsterdamPolygon, startAt: DateTime.utc(2024, 6, 20, 16, 0), stopAt: DateTime.utc(2024, 6, 21, 4, 0)),
  _makeInactive(id: 'i7', startAt: DateTime.utc(2024, 4, 11, 9, 30), stopAt: DateTime.utc(2024, 4, 11, 11, 0)),
  _makeInactive(id: 'i8', startAt: DateTime.utc(2024, 2, 28, 6, 0), stopAt: DateTime.utc(2024, 2, 28, 10, 0)),
];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _kScreenSize = Size(390, 844);

/// Captures the [RepaintBoundary] identified by [boundaryKey] as a PNG.
Future<void> _saveScreenshot(
  GlobalKey boundaryKey,
  double pixelRatio,
  String outputPath,
) async {
  final boundary =
      boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  final file = File(outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(byteData!.buffer.asUint8List());
}

/// Wraps [child] in a [RepaintBoundary] tagged with [key] so it can be captured.
Widget _captureRoot(GlobalKey key, Widget child) =>
    RepaintBoundary(key: key, child: child);

// ---------------------------------------------------------------------------
// Theme shared by all tests
// ---------------------------------------------------------------------------

final _theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFAE1C28),
    secondary: const Color(0xFFFF8C00),
  ),
  fontFamily: 'Roboto',
  useMaterial3: true,
  appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
  cardTheme: CardThemeData(
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

MaterialApp _shell(Widget home) => MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('nl'),
      theme: _theme,
      home: home,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('nl_NL');
  });

  Future<void> pump(
    WidgetTester tester,
    GlobalKey key,
    Widget child,
  ) async {
    tester.view.physicalSize = _kScreenSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_captureRoot(key, child));
    await tester.pumpAndSettle();
  }

  testWidgets('list_screen', (tester) async {
    final key = GlobalKey();
    final cache = _FakeCacheService();
    await cache.saveAlerts(_allAlerts);

    await pump(
      tester, key,
      ProviderScope(
        overrides: [
          alertsProvider.overrideWith(
            (ref) => AlertsNotifier(api: _FakeApiService.empty(), cache: cache),
          ),
          settingsProvider.overrideWith(
            (ref) => SettingsNotifier(_FakeSettingsService()),
          ),
          locationProvider.overrideWith((ref) async => _amsterdamCenter),
        ],
        child: _shell(const ListScreen()),
      ),
    );

    await _saveScreenshot(key, tester.view.devicePixelRatio,
        'docs/screenshots/list_screen.png');
  });

  testWidgets('detail_screen', (tester) async {
    final key = GlobalKey();
    final cache = _FakeCacheService();
    await cache.saveAlerts([_allAlerts.first]);

    await pump(
      tester, key,
      ProviderScope(
        overrides: [
          alertsProvider.overrideWith(
            (ref) => AlertsNotifier(api: _FakeApiService.empty(), cache: cache),
          ),
          settingsProvider.overrideWith(
            (ref) => SettingsNotifier(_FakeSettingsService()),
          ),
          locationProvider.overrideWith((ref) async => _amsterdamCenter),
        ],
        child: _shell(DetailScreen(alertId: _allAlerts.first.id)),
      ),
    );

    await _saveScreenshot(key, tester.view.devicePixelRatio,
        'docs/screenshots/detail_screen.png');
  });

  testWidgets('map_screen', (tester) async {
    final key = GlobalKey();
    final cache = _FakeCacheService();
    await cache.saveAlerts(_allAlerts.take(3).toList());

    await pump(
      tester, key,
      ProviderScope(
        overrides: [
          alertsProvider.overrideWith(
            (ref) => AlertsNotifier(api: _FakeApiService.empty(), cache: cache),
          ),
          settingsProvider.overrideWith(
            (ref) => SettingsNotifier(_FakeSettingsService()),
          ),
          locationProvider.overrideWith((ref) async => _amsterdamCenter),
        ],
        child: _shell(const MapOverviewScreen()),
      ),
    );

    await _saveScreenshot(key, tester.view.devicePixelRatio,
        'docs/screenshots/map_screen.png');
  });

  testWidgets('stats_screen', (tester) async {
    final key = GlobalKey();
    // Two-page fake: page 1 = all alerts, page 2 = empty → loadAll() finishes.
    final fakeCache = _FakeCacheService();

    await pump(
      tester, key,
      ProviderScope(
        overrides: [
          alertsProvider.overrideWith(
            (ref) => AlertsNotifier(
              api: _FakeApiService([_allAlerts, []]),
              cache: fakeCache,
            ),
          ),
          settingsProvider.overrideWith(
            (ref) => SettingsNotifier(_FakeSettingsService()),
          ),
          locationProvider.overrideWith((ref) async => null),
        ],
        child: _shell(const StatsScreen()),
      ),
    );

    await _saveScreenshot(key, tester.view.devicePixelRatio,
        'docs/screenshots/stats_screen.png');
  });

  testWidgets('settings_screen', (tester) async {
    final key = GlobalKey();

    await pump(
      tester, key,
      ProviderScope(
        overrides: [
          alertsProvider.overrideWith(
            (ref) =>
                AlertsNotifier(api: _FakeApiService.empty(), cache: _FakeCacheService()),
          ),
          settingsProvider.overrideWith(
            (ref) => SettingsNotifier(_FakeSettingsService()),
          ),
          locationProvider.overrideWith((ref) async => null),
        ],
        child: _shell(const SettingsScreen()),
      ),
    );

    await _saveScreenshot(key, tester.view.devicePixelRatio,
        'docs/screenshots/settings_screen.png');
  });
}
