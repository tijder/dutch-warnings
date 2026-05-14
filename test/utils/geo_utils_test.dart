import 'package:dutch_warnings/utils/geo_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('parsePolygon', () {
    test('parses space-separated lat,lon pairs', () {
      const input = '52.35,4.85 52.42,4.85 52.42,5.00';
      final pts = parsePolygon(input);
      expect(pts, hasLength(3));
      expect(pts[0].latitude, closeTo(52.35, 0.0001));
      expect(pts[0].longitude, closeTo(4.85, 0.0001));
      expect(pts[2].latitude, closeTo(52.42, 0.0001));
      expect(pts[2].longitude, closeTo(5.00, 0.0001));
    });

    test('handles leading and trailing whitespace', () {
      const input = '  51.87,4.30  51.94,4.30  ';
      final pts = parsePolygon(input);
      expect(pts, hasLength(2));
    });

    test('returns empty list for empty string', () {
      expect(parsePolygon(''), isEmpty);
      expect(parsePolygon('   '), isEmpty);
    });

    test('parses closed ring (first == last point)', () {
      const ring =
          '52.35,4.85 52.42,4.85 52.42,5.00 52.35,5.00 52.35,4.85';
      final pts = parsePolygon(ring);
      expect(pts.first.latitude, pts.last.latitude);
      expect(pts.first.longitude, pts.last.longitude);
    });
  });

  group('polygonCenter', () {
    test('returns centroid of an axis-aligned rectangle', () {
      final poly = [
        const LatLng(52.0, 4.0),
        const LatLng(53.0, 4.0),
        const LatLng(53.0, 6.0),
        const LatLng(52.0, 6.0),
      ];
      final center = polygonCenter(poly);
      expect(center.latitude, closeTo(52.5, 0.0001));
      expect(center.longitude, closeTo(5.0, 0.0001));
    });

    test('returns single point for one-element list', () {
      final poly = [const LatLng(52.37, 4.90)];
      final center = polygonCenter(poly);
      expect(center.latitude, closeTo(52.37, 0.0001));
      expect(center.longitude, closeTo(4.90, 0.0001));
    });

    test('returns fallback (Netherlands center) for empty polygon', () {
      final center = polygonCenter([]);
      expect(center.latitude, closeTo(52.3, 0.01));
      expect(center.longitude, closeTo(5.3, 0.01));
    });
  });

  group('isUserInAlertArea', () {
    // Simple square: 52.0–53.0°N, 4.0–6.0°E
    const squareArea =
        '52.0000,4.0000 53.0000,4.0000 53.0000,6.0000 52.0000,6.0000 52.0000,4.0000';

    test('returns true when user is inside the polygon', () {
      const user = LatLng(52.5, 5.0); // center of square
      expect(isUserInAlertArea(user, [squareArea]), isTrue);
    });

    test('returns false when user is clearly outside', () {
      const user = LatLng(51.0, 5.0); // south of square
      expect(isUserInAlertArea(user, [squareArea]), isFalse);
    });

    test('returns false for empty areas list', () {
      const user = LatLng(52.5, 5.0);
      expect(isUserInAlertArea(user, []), isFalse);
    });

    test('returns false for degenerate polygon (fewer than 3 points)', () {
      const user = LatLng(52.5, 5.0);
      expect(isUserInAlertArea(user, ['52.0,4.0 53.0,4.0']), isFalse);
    });

    test('returns true when user is in one of multiple areas', () {
      const insideAmsterdam = LatLng(52.37, 4.90);
      const amsterdamArea =
          '52.3500,4.8500 52.4200,4.8500 52.4200,5.0000 52.3500,5.0000 52.3500,4.8500';
      const rotterdamArea =
          '51.8700,4.3000 51.9400,4.3000 51.9400,4.6000 51.8700,4.6000 51.8700,4.3000';
      expect(
        isUserInAlertArea(insideAmsterdam, [rotterdamArea, amsterdamArea]),
        isTrue,
      );
    });

    test('returns false when user is outside all areas', () {
      const northSea = LatLng(53.0, 3.5);
      const amsterdamArea =
          '52.3500,4.8500 52.4200,4.8500 52.4200,5.0000 52.3500,5.0000 52.3500,4.8500';
      const rotterdamArea =
          '51.8700,4.3000 51.9400,4.3000 51.9400,4.6000 51.8700,4.6000 51.8700,4.3000';
      expect(
        isUserInAlertArea(northSea, [amsterdamArea, rotterdamArea]),
        isFalse,
      );
    });
  });
}
