import 'package:dutch_warnings/screens/settings_screen.dart';
import 'package:dutch_warnings/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/fixtures.dart';
import 'helpers.dart';

void main() {
  group('SettingsScreen', () {
    testWidgets('renders settings title', (tester) async {
      final api = FakeApiService.empty();

      await tester.pumpWidget(testApp(const SettingsScreen(), api: api));
      await tester.pumpAndSettle();

      expect(find.text('Instellingen'), findsOneWidget);
    });

    testWidgets('shows all section headers', (tester) async {
      final api = FakeApiService.empty();

      await tester.pumpWidget(testApp(const SettingsScreen(), api: api));
      await tester.pumpAndSettle();

      expect(find.text('Vernieuwen'), findsOneWidget);
      expect(find.text('Mijn locatie'), findsOneWidget);
      expect(find.text('Kaart'), findsOneWidget);
      expect(find.text('Gegevens'), findsOneWidget);
      expect(find.text('Over'), findsOneWidget);
    });

    testWidgets('auto-refresh toggle is off by default', (tester) async {
      final api = FakeApiService.empty();

      await tester.pumpWidget(testApp(const SettingsScreen(), api: api));
      await tester.pumpAndSettle();

      final sw = tester.widget<Switch>(find.byType(Switch).first);
      expect(sw.value, isFalse);
    });

    testWidgets('enabling auto-refresh reveals interval picker', (tester) async {
      final api = FakeApiService.empty();

      await tester.pumpWidget(testApp(const SettingsScreen(), api: api));
      await tester.pumpAndSettle();

      expect(find.text('Interval'), findsNothing);

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      expect(find.text('Interval'), findsOneWidget);
    });

    testWidgets('shows default tile server URL in text field', (tester) async {
      final api = FakeApiService.empty();

      await tester.pumpWidget(testApp(const SettingsScreen(), api: api));
      await tester.pumpAndSettle();

      // The tile URL TextField has the default URL as its controller value.
      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      final hasDefaultUrl = textFields.any(
        (tf) => tf.controller?.text == kDefaultTileServer,
      );
      expect(hasDefaultUrl, isTrue);
    });

    testWidgets('shows preset chips for tile servers', (tester) async {
      final api = FakeApiService.empty();

      await tester.pumpWidget(testApp(const SettingsScreen(), api: api));
      await tester.pumpAndSettle();

      expect(find.text('CartoDB Light'), findsOneWidget);
      expect(find.text('CartoDB Dark'), findsOneWidget);
      expect(find.text('OpenTopoMap'), findsOneWidget);
    });

    testWidgets('reset-defaults button is disabled when URL is already default',
        (tester) async {
      final api = FakeApiService.empty();

      await tester.pumpWidget(testApp(const SettingsScreen(), api: api));
      await tester.pumpAndSettle();

      final btn = tester.widget<TextButton>(
        find.ancestor(
          of: find.text('Standaard herstellen'),
          matching: find.byType(TextButton),
        ),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('shows location mode dropdown with GPS option', (tester) async {
      final api = FakeApiService.empty();

      await tester.pumpWidget(testApp(const SettingsScreen(), api: api));
      await tester.pumpAndSettle();

      expect(find.text('Locatiemodus'), findsOneWidget);
      expect(find.text('Automatisch (GPS)'), findsOneWidget);
    });

    testWidgets('tapping About tile opens about dialog', (tester) async {
      final api = FakeApiService.empty();

      await tester.pumpWidget(testApp(const SettingsScreen(), api: api));
      await tester.pumpAndSettle();

      // The about ListTile has title 'Dutch Warnings'. Scroll to it first.
      await tester.ensureVisible(find.text('Dutch Warnings'));
      await tester.tap(find.text('Dutch Warnings'));
      await tester.pumpAndSettle();

      expect(find.byType(AboutDialog), findsOneWidget);
    });

    testWidgets('load-all button is disabled when all alerts already loaded',
        (tester) async {
      final api = FakeApiService.empty();

      await tester.pumpWidget(testApp(const SettingsScreen(), api: api));
      await tester.pumpAndSettle();

      final btn = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Laad alle alerts in'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(btn.onPressed, isNull);
    });
  });
}
