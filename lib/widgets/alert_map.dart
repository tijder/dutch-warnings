import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../models/alert.dart';
import '../providers/settings_provider.dart';
import '../utils/geo_utils.dart';

class AlertMap extends ConsumerWidget {
  const AlertMap({
    super.key,
    required this.alert,
    this.userLocation,
  });

  final Alert alert;
  final LatLng? userLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tileServerUrl = ref.watch(settingsProvider).tileServerUrl;

    final polygons = alert.area.map(parsePolygon).toList();
    final allPoints = polygons.expand((p) => p).toList();

    if (allPoints.isEmpty) {
      return const Center(child: Text('Geen kaartgebied beschikbaar'));
    }

    final bounds = LatLngBounds.fromPoints(allPoints);

    return FlutterMap(
      options: MapOptions(
        initialCameraFit: CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(40),
        ),
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: tileServerUrl,
          userAgentPackageName: 'nl.g4d.dutch_warnings',
          tileProvider: NetworkTileProvider(
            cachingProvider: const DisabledMapCachingProvider(),
          ),
        ),
        PolygonLayer(
          polygons: polygons
              .map(
                (poly) => Polygon(
                  points: poly,
                  color: alert.isActive
                      ? const Color(0x33FF5722)
                      : const Color(0x3321468B),
                  borderColor: alert.isActive
                      ? const Color(0xFFFF5722)
                      : const Color(0xFF21468B),
                  borderStrokeWidth: 2.5,
                ),
              )
              .toList(),
        ),
        if (userLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: userLocation!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.person_pin_circle_rounded,
                  color: Colors.blue,
                  size: 36,
                  shadows: [Shadow(color: Colors.white, blurRadius: 4)],
                ),
              ),
            ],
          ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap bijdragers',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}
