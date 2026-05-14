import 'package:dutch_warnings/l10n/l10n.dart';
import 'package:dutch_warnings/providers/alerts_provider.dart';
import 'package:dutch_warnings/providers/location_provider.dart';
import 'package:dutch_warnings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../fixtures/fixtures.dart';

/// Wraps [child] in a ProviderScope + MaterialApp with Dutch locale.
/// Provider overrides are built from the named parameters so that the
/// sealed `Override` type never needs to be named explicitly.
Widget testApp(
  Widget child, {
  required FakeApiService api,
  FakeCacheService? cache,
  LatLng? location,
}) {
  return ProviderScope(
    overrides: [
      alertsProvider.overrideWith(
        (ref) => AlertsNotifier(api: api, cache: cache ?? FakeCacheService()),
      ),
      settingsProvider.overrideWith(
        (ref) => SettingsNotifier(FakeSettingsService()),
      ),
      locationProvider.overrideWith((ref) async => location),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('nl'),
      theme: ThemeData(useMaterial3: true),
      home: child,
    ),
  );
}
