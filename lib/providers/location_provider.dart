import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/settings_service.dart';
import 'settings_provider.dart';

final locationProvider = FutureProvider<LatLng?>((ref) async {
  // Only re-run when location-relevant settings change, not on every
  // settings update (e.g. tile server, auto-refresh interval, etc.).
  final mode = ref.watch(settingsProvider.select((s) => s.locationMode));
  final manualLat =
      ref.watch(settingsProvider.select((s) => s.manualLatitude));
  final manualLng =
      ref.watch(settingsProvider.select((s) => s.manualLongitude));

  switch (mode) {
    case LocationMode.off:
      return null;

    case LocationMode.manual:
      if (manualLat != null && manualLng != null) {
        return LatLng(manualLat, manualLng);
      }
      return null;

    case LocationMode.automatic:
      try {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) return null;

        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return null;
        }

        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 10),
          ),
        );
        return LatLng(position.latitude, position.longitude);
      } catch (e, st) {
        debugPrint('[Location] error getting position: $e\n$st');
        return null;
      }
  }
});
