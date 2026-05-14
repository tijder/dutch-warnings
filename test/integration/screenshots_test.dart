/// Golden-file screenshot tests.
///
/// These tests are NOT run as part of the normal test suite — they only
/// produce images. Run with:
///   flutter test --update-goldens test/integration/screenshots_test.dart
///
/// For realistic screenshots (real fonts, real renderer) use the integration
/// test instead:
///   flutter test -d linux integration_test/screenshots_test.dart
///
/// The resulting PNGs are saved to docs/screenshots/ and referenced from the
/// feature docs in docs/.

import 'package:dutch_warnings/screens/detail_screen.dart';
import 'package:dutch_warnings/screens/list_screen.dart';
import 'package:dutch_warnings/screens/map_overview_screen.dart';
import 'package:dutch_warnings/screens/settings_screen.dart';
import 'package:dutch_warnings/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/fixtures.dart';
import 'helpers.dart';

// Phone-like portrait dimensions for the captured images.
const _kScreenSize = Size(390, 844);

void _setPhoneSize(WidgetTester tester) {
  tester.view.physicalSize = _kScreenSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

// Golden files land in docs/screenshots/ relative to the project root.
// From test/integration/ that path is ../../docs/screenshots/.
String _golden(String name) => '../../docs/screenshots/$name.png';

void main() {
  group('Screenshots', () {
    testWidgets('list_screen – alerts loaded', (tester) async {
      _setPhoneSize(tester);

      final api = FakeApiService.singlePage([
        makeActiveAlert(id: 'a1'),
        makeActiveAlert(id: 'a2'),
        makeInactiveAlert(id: 'i1'),
      ]);

      await tester.pumpWidget(testApp(const ListScreen(), api: api));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(_golden('list_screen')),
      );
    });

    testWidgets('detail_screen – active alert', (tester) async {
      _setPhoneSize(tester);

      final api = FakeApiService.singlePage([
        makeActiveAlert(id: 'a1', area: kAmsterdamPolygon),
      ]);

      await tester.pumpWidget(
        testApp(DetailScreen(alertId: 'a1'), api: api,
            location: kAmsterdamCenter),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(_golden('detail_screen')),
      );
    });

    testWidgets('map_screen – current mode', (tester) async {
      _setPhoneSize(tester);

      final api = FakeApiService.singlePage([
        makeActiveAlert(id: 'a1', area: kAmsterdamPolygon),
      ]);

      await tester.pumpWidget(testApp(const MapOverviewScreen(), api: api));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(_golden('map_screen')),
      );
    });

    testWidgets('stats_screen – charts loaded', (tester) async {
      _setPhoneSize(tester);

      // Use a 2-page fake: first page has alerts, second is empty so
      // loadAll() terminates and the charts are rendered.
      final api = FakeApiService([
        [
          makeActiveAlert(
              id: 'a1', startAt: DateTime.utc(2024, 6, 15, 10, 30)),
          makeActiveAlert(
              id: 'a2', startAt: DateTime.utc(2024, 9, 3, 8, 0)),
          makeInactiveAlert(id: 'i1'),
        ],
        [], // second call returns empty → hasMore = false
      ]);

      await tester.pumpWidget(testApp(const StatsScreen(), api: api));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(_golden('stats_screen')),
      );
    });

    testWidgets('settings_screen', (tester) async {
      _setPhoneSize(tester);

      final api = FakeApiService.empty();

      await tester.pumpWidget(testApp(const SettingsScreen(), api: api));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(_golden('settings_screen')),
      );
    });
  });
}
