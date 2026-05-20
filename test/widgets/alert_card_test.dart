import 'package:dutch_warnings/l10n/l10n.dart';
import 'package:dutch_warnings/widgets/alert_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../fixtures/fixtures.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('nl'),
      home: Scaffold(body: child),
    );

void main() {
  setUpAll(() async {
    await initializeDateFormatting('nl_NL');
  });

  group('AlertCard – active alert (no user location)', () {
    testWidgets('shows alert title', (tester) async {
      final alert = makeActiveAlert();
      await tester.pumpWidget(_wrap(AlertCard(
        alert: alert,
        userLocation: null,
        onTap: () {},
      )));
      expect(find.textContaining('Amsterdam'), findsWidgets);
    });

    testWidgets('shows Actief badge', (tester) async {
      await tester.pumpWidget(_wrap(AlertCard(
        alert: makeActiveAlert(),
        userLocation: null,
        onTap: () {},
      )));
      expect(find.text('Actief'), findsOneWidget);
    });

    testWidgets('does not show Afgelopen badge', (tester) async {
      await tester.pumpWidget(_wrap(AlertCard(
        alert: makeActiveAlert(),
        userLocation: null,
        onTap: () {},
      )));
      expect(find.text('Afgelopen'), findsNothing);
    });

    testWidgets('shows formatted start date', (tester) async {
      final alert = makeActiveAlert();
      await tester.pumpWidget(_wrap(AlertCard(
        alert: alert,
        userLocation: null,
        onTap: () {},
      )));
      // The card uses 'dd MMM yyyy HH:mm' in nl_NL – just verify it has the year.
      expect(find.textContaining('2024'), findsWidgets);
    });

    testWidgets('shows dutch message preview', (tester) async {
      await tester.pumpWidget(_wrap(AlertCard(
        alert: makeActiveAlert(),
        userLocation: null,
        onTap: () {},
      )));
      expect(find.textContaining('Wateroverlast'), findsWidgets);
    });
  });

  group('AlertCard – inactive alert', () {
    testWidgets('shows Afgelopen badge', (tester) async {
      await tester.pumpWidget(_wrap(AlertCard(
        alert: makeInactiveAlert(),
        userLocation: null,
        onTap: () {},
      )));
      expect(find.text('Afgelopen'), findsOneWidget);
    });

    testWidgets('does not show Actief badge', (tester) async {
      await tester.pumpWidget(_wrap(AlertCard(
        alert: makeInactiveAlert(),
        userLocation: null,
        onTap: () {},
      )));
      expect(find.text('Actief'), findsNothing);
    });
  });

  group('AlertCard – user inside alert area', () {
    // kAmsterdamCenter (52.37, 4.90) is inside kAmsterdamPolygon.
    testWidgets('shows U! badge when user is in the area', (tester) async {
      await tester.pumpWidget(_wrap(AlertCard(
        alert: makeActiveAlert(area: kAmsterdamPolygon),
        userLocation: kAmsterdamCenter,
        onTap: () {},
      )));
      expect(find.text('U!'), findsOneWidget);
    });

    testWidgets('shows affected location banner text', (tester) async {
      await tester.pumpWidget(_wrap(AlertCard(
        alert: makeActiveAlert(area: kAmsterdamPolygon),
        userLocation: kAmsterdamCenter,
        onTap: () {},
      )));
      expect(
        find.textContaining('waarschuwingsgebied geldt voor uw locatie'),
        findsOneWidget,
      );
    });

    testWidgets('does not show U! badge for inactive alert even if inside',
        (tester) async {
      // An inactive alert with the Amsterdam polygon; user is inside, but
      // isActive=false so _userAffected returns false.
      await tester.pumpWidget(_wrap(AlertCard(
        alert: makeInactiveAlert(area: kAmsterdamPolygon),
        userLocation: kAmsterdamCenter,
        onTap: () {},
      )));
      expect(find.text('U!'), findsNothing);
    });
  });

  group('AlertCard – user outside alert area', () {
    testWidgets('does not show U! badge when user is outside', (tester) async {
      // kSeaLocation is far from kAmsterdamPolygon.
      await tester.pumpWidget(_wrap(AlertCard(
        alert: makeActiveAlert(area: kAmsterdamPolygon),
        userLocation: kSeaLocation,
        onTap: () {},
      )));
      expect(find.text('U!'), findsNothing);
    });

    testWidgets('still shows Actief badge when outside', (tester) async {
      await tester.pumpWidget(_wrap(AlertCard(
        alert: makeActiveAlert(area: kAmsterdamPolygon),
        userLocation: kSeaLocation,
        onTap: () {},
      )));
      expect(find.text('Actief'), findsOneWidget);
    });
  });

  group('AlertCard – interaction', () {
    testWidgets('calls onTap callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(AlertCard(
        alert: makeActiveAlert(),
        userLocation: null,
        onTap: () => tapped = true,
      )));
      await tester.tap(find.byType(InkWell).first);
      expect(tapped, isTrue);
    });
  });
}
