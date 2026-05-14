import 'package:dutch_warnings/models/alert.dart';
import 'package:dutch_warnings/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/fixtures.dart';
import 'helpers.dart';

void main() {
  group('StatsScreen', () {
    testWidgets('shows loading body while not all alerts are fetched',
        (tester) async {
      final api = _SlowApiService([makeActiveAlert(id: 'a1')]);

      await tester.pumpWidget(testApp(const StatsScreen(), api: api));
      // Two pumps: init completes, postFrameCallback fires, loadAll starts.
      await tester.pump();
      await tester.pump();

      expect(find.text('Alle alerts worden geladen…'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      api.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('shows progress count while loading', (tester) async {
      final api = _SlowApiService([makeActiveAlert(id: 'a1')]);

      await tester.pumpWidget(testApp(const StatsScreen(), api: api));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('alerts geladen'), findsOneWidget);

      api.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('shows all four chart titles after loading', (tester) async {
      final api = FakeApiService.singlePage([
        makeActiveAlert(id: 'a1'),
        makeInactiveAlert(id: 'i1'),
      ]);

      await tester.pumpWidget(testApp(const StatsScreen(), api: api));
      await tester.pumpAndSettle();

      expect(find.text('Alerts per maand'), findsOneWidget);
      expect(find.text('Alerts over tijd'), findsOneWidget);
      expect(find.text('Duur van alerts'), findsOneWidget);
      expect(find.text('Alerts per uur'), findsOneWidget);
    });

    testWidgets('each chart card has an info icon', (tester) async {
      final api = FakeApiService.singlePage([makeActiveAlert(id: 'a1')]);

      await tester.pumpWidget(testApp(const StatsScreen(), api: api));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.info_outline), findsNWidgets(4));
    });

    testWidgets('tapping info icon opens description dialog', (tester) async {
      final api = FakeApiService.singlePage([makeActiveAlert(id: 'a1')]);

      await tester.pumpWidget(testApp(const StatsScreen(), api: api));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.info_outline).first);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Klaar'), findsOneWidget);
    });

    testWidgets('info dialog can be dismissed with Klaar button', (tester) async {
      final api = FakeApiService.singlePage([makeActiveAlert(id: 'a1')]);

      await tester.pumpWidget(testApp(const StatsScreen(), api: api));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.info_outline).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Klaar'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('shows screen title in app bar', (tester) async {
      final api = FakeApiService.singlePage([makeActiveAlert(id: 'a1')]);

      await tester.pumpWidget(testApp(const StatsScreen(), api: api));
      await tester.pumpAndSettle();

      expect(find.text('Statistieken'), findsOneWidget);
    });
  });
}

/// Blocks the second API call until [complete()] is called, so the loading
/// state can be observed in tests before [pumpAndSettle].
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
