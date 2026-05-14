import 'package:dutch_warnings/models/alert.dart';
import 'package:dutch_warnings/screens/map_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/fixtures.dart';
import 'helpers.dart';

void main() {
  group('MapOverviewScreen', () {
    testWidgets('renders in current mode by default', (tester) async {
      final api = FakeApiService.singlePage([makeActiveAlert(id: 'a1')]);

      await tester.pumpWidget(testApp(const MapOverviewScreen(), api: api));
      await tester.pumpAndSettle();

      expect(find.text('Huidig'), findsOneWidget);
      expect(find.text('Historie'), findsOneWidget);
    });

    testWidgets('shows map overview title in app bar', (tester) async {
      final api = FakeApiService.empty();

      await tester.pumpWidget(testApp(const MapOverviewScreen(), api: api));
      await tester.pumpAndSettle();

      expect(find.text('Kaartoverzicht'), findsOneWidget);
    });

    testWidgets('current mode shows empty-state when no active alerts',
        (tester) async {
      final api = FakeApiService.singlePage([makeInactiveAlert(id: 'i1')]);

      await tester.pumpWidget(testApp(const MapOverviewScreen(), api: api));
      await tester.pumpAndSettle();

      expect(find.text('Geen actieve NL-Alerts'), findsOneWidget);
    });

    testWidgets('history mode shows loading card while hasMore is true',
        (tester) async {
      final api = _SlowApiService([makeActiveAlert(id: 'a1')]);

      await tester.pumpWidget(testApp(const MapOverviewScreen(), api: api));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Historie'));
      await tester.pump();

      expect(find.text('Alle alerts worden geladen…'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      api.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('history mode shows period picker when all alerts are loaded',
        (tester) async {
      final api = FakeApiService.singlePage([makeActiveAlert(id: 'a1')]);

      await tester.pumpWidget(testApp(const MapOverviewScreen(), api: api));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Historie'));
      await tester.pumpAndSettle();

      expect(find.text('Selecteer een periode'), findsOneWidget);
      expect(find.text('Periode kiezen'), findsOneWidget);
      expect(find.text('Laatste 30 dagen'), findsOneWidget);
    });

    testWidgets('history mode appbar shows date range button after mode switch',
        (tester) async {
      final api = FakeApiService.empty();

      await tester.pumpWidget(testApp(const MapOverviewScreen(), api: api));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Historie'));
      await tester.pumpAndSettle();

      // OutlinedButton with period label should appear in appbar.
      expect(find.text('Selecteer periode'), findsOneWidget);
    });
  });
}

class _SlowApiService extends FakeApiService {
  _SlowApiService(List<Alert> firstPage) : super([firstPage]);

  bool _released = false;

  void complete() => _released = true;

  @override
  Future<List<Alert>> fetchAlerts({String? after}) async {
    if (callCount == 0) return super.fetchAlerts(after: after);
    while (!_released) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    return [];
  }
}
