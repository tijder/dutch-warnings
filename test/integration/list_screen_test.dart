import 'package:dutch_warnings/models/alert.dart';
import 'package:dutch_warnings/screens/list_screen.dart';
import 'package:dutch_warnings/widgets/alert_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/fixtures.dart';
import 'helpers.dart';

void main() {
  group('ListScreen', () {
    testWidgets('shows alert cards after loading', (tester) async {
      final api = FakeApiService.singlePage([
        makeActiveAlert(id: 'a1'),
        makeInactiveAlert(id: 'i1'),
      ]);

      await tester.pumpWidget(testApp(const ListScreen(), api: api));
      await tester.pumpAndSettle();

      expect(find.byType(AlertCard), findsNWidgets(2));
    });

    testWidgets('shows active alert count in header', (tester) async {
      final api = FakeApiService.singlePage([
        makeActiveAlert(id: 'a1'),
        makeActiveAlert(id: 'a2'),
        makeInactiveAlert(id: 'i1'),
      ]);

      await tester.pumpWidget(testApp(const ListScreen(), api: api));
      await tester.pumpAndSettle();

      expect(find.text('2 actieve NL-Alerts'), findsOneWidget);
    });

    testWidgets('shows singular form for exactly one active alert', (tester) async {
      final api = FakeApiService.singlePage([makeActiveAlert(id: 'a1')]);

      await tester.pumpWidget(testApp(const ListScreen(), api: api));
      await tester.pumpAndSettle();

      expect(find.text('1 actief NL-Alert'), findsOneWidget);
    });

    testWidgets('shows empty-state message when no alerts found', (tester) async {
      final api = FakeApiService.empty();

      await tester.pumpWidget(testApp(const ListScreen(), api: api));
      await tester.pumpAndSettle();

      expect(find.text('Geen NL-Alerts gevonden'), findsOneWidget);
    });

    testWidgets('shows offline icon when API is unreachable', (tester) async {
      final cache = FakeCacheService();
      await cache.saveAlerts([makeActiveAlert(id: 'cached')]);
      final api = _ThrowingApiService();

      await tester.pumpWidget(
        testApp(const ListScreen(), api: api, cache: cache),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.byType(AlertCard), findsOneWidget);
    });

    testWidgets('shows location chip when user is in alert area', (tester) async {
      final api = FakeApiService.singlePage([
        makeActiveAlert(id: 'a1', area: kAmsterdamPolygon),
      ]);

      await tester.pumpWidget(
        testApp(const ListScreen(), api: api, location: kAmsterdamCenter),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Dit waarschuwingsgebied geldt voor uw locatie'),
        findsOneWidget,
      );
    });

    testWidgets('does not show location chip when user is outside area', (tester) async {
      final api = FakeApiService.singlePage([
        makeActiveAlert(id: 'a1', area: kAmsterdamPolygon),
      ]);

      await tester.pumpWidget(
        testApp(const ListScreen(), api: api, location: kSeaLocation),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Dit waarschuwingsgebied geldt voor uw locatie'),
        findsNothing,
      );
    });

    testWidgets('shows footer when all alerts are loaded', (tester) async {
      // Pre-populate cache so alerts are non-empty; empty API → hasMore=false.
      final cache = FakeCacheService();
      await cache.saveAlerts([makeActiveAlert(id: 'a1')]);
      final api = FakeApiService.empty();

      await tester.pumpWidget(testApp(const ListScreen(), api: api, cache: cache));
      await tester.pumpAndSettle();

      expect(find.text('Alle berichten geladen'), findsOneWidget);
    });
  });
}

class _ThrowingApiService extends FakeApiService {
  _ThrowingApiService() : super.empty();

  @override
  Future<List<Alert>> fetchAlerts({String? after}) =>
      Future.error(Exception('offline'));
}
