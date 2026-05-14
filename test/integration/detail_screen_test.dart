import 'package:dutch_warnings/screens/detail_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/fixtures.dart';
import 'helpers.dart';

void main() {
  group('DetailScreen', () {
    testWidgets('shows active status chip', (tester) async {
      final api = FakeApiService.singlePage([makeActiveAlert(id: 'a1')]);

      await tester.pumpWidget(testApp(DetailScreen(alertId: 'a1'), api: api));
      await tester.pumpAndSettle();

      expect(find.text('Actief'), findsOneWidget);
    });

    testWidgets('shows inactive status chip for past alert', (tester) async {
      final api = FakeApiService.singlePage([makeInactiveAlert(id: 'i1')]);

      await tester.pumpWidget(testApp(DetailScreen(alertId: 'i1'), api: api));
      await tester.pumpAndSettle();

      expect(find.text('Afgelopen'), findsOneWidget);
    });

    testWidgets('shows not-found message for unknown alert ID', (tester) async {
      final api = FakeApiService.singlePage([makeActiveAlert(id: 'other')]);

      await tester.pumpWidget(
        testApp(DetailScreen(alertId: 'nonexistent'), api: api),
      );
      await tester.pumpAndSettle();

      expect(find.text('Waarschuwing niet gevonden'), findsOneWidget);
    });

    testWidgets('shows Dutch and English message sections', (tester) async {
      final api = FakeApiService.singlePage([makeActiveAlert(id: 'a1')]);

      await tester.pumpWidget(testApp(DetailScreen(alertId: 'a1'), api: api));
      await tester.pumpAndSettle();

      expect(find.text('Nederlands'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('shows start time label', (tester) async {
      final api = FakeApiService.singlePage([makeActiveAlert(id: 'a1')]);

      await tester.pumpWidget(testApp(DetailScreen(alertId: 'a1'), api: api));
      await tester.pumpAndSettle();

      expect(find.text('Starttijd'), findsOneWidget);
    });

    testWidgets('shows location chip when user is within alert area', (tester) async {
      final api = FakeApiService.singlePage([
        makeActiveAlert(id: 'a1', area: kAmsterdamPolygon),
      ]);

      await tester.pumpWidget(
        testApp(DetailScreen(alertId: 'a1'), api: api, location: kAmsterdamCenter),
      );
      await tester.pumpAndSettle();

      expect(find.text('Geldt voor uw locatie'), findsOneWidget);
    });

    testWidgets('does not show location chip when user is outside area', (tester) async {
      final api = FakeApiService.singlePage([
        makeActiveAlert(id: 'a1', area: kAmsterdamPolygon),
      ]);

      await tester.pumpWidget(
        testApp(DetailScreen(alertId: 'a1'), api: api, location: kSeaLocation),
      );
      await tester.pumpAndSettle();

      expect(find.text('Geldt voor uw locatie'), findsNothing);
    });

    testWidgets('shows alert ID in detail view', (tester) async {
      final api = FakeApiService.singlePage([makeActiveAlert(id: 'test-id-xyz')]);

      await tester.pumpWidget(
        testApp(DetailScreen(alertId: 'test-id-xyz'), api: api),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('test-id-xyz'), findsWidgets);
    });
  });
}
