import 'package:latlong2/latlong.dart';

List<LatLng> parsePolygon(String areaString) {
  return areaString
      .trim()
      .split(' ')
      .where((s) => s.isNotEmpty)
      .map((point) {
        final parts = point.split(',');
        if (parts.length != 2) return null;
        final lat = double.tryParse(parts[0]);
        final lng = double.tryParse(parts[1]);
        if (lat == null || lng == null) return null;
        return LatLng(lat, lng);
      })
      .whereType<LatLng>()
      .toList();
}

LatLng polygonCenter(List<LatLng> polygon) {
  if (polygon.isEmpty) return const LatLng(52.3, 5.3);
  final lat = polygon.map((p) => p.latitude).reduce((a, b) => a + b) /
      polygon.length;
  final lng = polygon.map((p) => p.longitude).reduce((a, b) => a + b) /
      polygon.length;
  return LatLng(lat, lng);
}

// Ray casting algorithm for point-in-polygon.
bool _pointInPolygon(LatLng point, List<LatLng> polygon) {
  if (polygon.length < 3) return false;
  bool inside = false;
  int j = polygon.length - 1;
  for (int i = 0; i < polygon.length; i++) {
    final iLat = polygon[i].latitude;
    final iLng = polygon[i].longitude;
    final jLat = polygon[j].latitude;
    final jLng = polygon[j].longitude;
    if ((iLng > point.longitude) != (jLng > point.longitude) &&
        point.latitude <
            (jLat - iLat) *
                    (point.longitude - iLng) /
                    (jLng - iLng) +
                iLat) {
      inside = !inside;
    }
    j = i;
  }
  return inside;
}

bool isUserInAlertArea(LatLng userLocation, List<String> areas) {
  for (final area in areas) {
    final polygon = parsePolygon(area);
    if (_pointInPolygon(userLocation, polygon)) return true;
  }
  return false;
}
