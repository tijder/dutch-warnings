import 'package:dutch_warnings/models/alert.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/fixtures.dart';

void main() {
  group('Alert.fromJson', () {
    test('parses id, type and resourceUri', () {
      final alert = Alert.fromJson(kActiveAlertJson);
      expect(alert.id, '2c93acc6aaf2');
      expect(alert.type, 'nl-alert');
      expect(alert.resourceUri,
          'https://api.public-warning.app/api/v1/providers/nl-alert/alerts/2c93acc6aaf2');
    });

    test('parses startAt as UTC moment', () {
      final alert = Alert.fromJson(kActiveAlertJson);
      expect(alert.startAt.toUtc(), DateTime.utc(2024, 6, 15, 10, 30));
    });

    test('parses stopAt when present', () {
      final alert = Alert.fromJson(kInactiveAlertJson);
      expect(alert.stopAt, isNotNull);
      expect(alert.stopAt!.toUtc(), DateTime.utc(2023, 11, 20, 14, 0));
    });

    test('stopAt is null for active alert', () {
      final alert = Alert.fromJson(kActiveAlertJson);
      expect(alert.stopAt, isNull);
    });

    test('parses single-item area list', () {
      final alert = Alert.fromJson(kActiveAlertJson);
      expect(alert.area, hasLength(1));
      expect(alert.area.first, kAmsterdamPolygon);
    });

    test('parses multi-area alert', () {
      final alert = Alert.fromJson(kMultiAreaAlertJson);
      expect(alert.area, hasLength(2));
    });

    test('handles null resourceUri', () {
      final alert = Alert.fromJson(kNlOnlyAlertJson);
      expect(alert.resourceUri, isNull);
    });

    test('handles missing area key gracefully (empty list)', () {
      final json = Map<String, dynamic>.from(kActiveAlertJson)
        ..remove('area');
      final alert = Alert.fromJson(json);
      expect(alert.area, isEmpty);
    });
  });

  group('Alert.toJson roundtrip', () {
    test('active alert survives toJson → fromJson', () {
      final original = Alert.fromJson(kActiveAlertJson);
      final roundtripped = Alert.fromJson(original.toJson());
      expect(roundtripped.id, original.id);
      expect(roundtripped.message, original.message);
      expect(roundtripped.type, original.type);
      expect(roundtripped.startAt.toUtc(), original.startAt.toUtc());
      expect(roundtripped.stopAt, isNull);
      expect(roundtripped.area, original.area);
    });

    test('inactive alert preserves stopAt through roundtrip', () {
      final original = Alert.fromJson(kInactiveAlertJson);
      final roundtripped = Alert.fromJson(original.toJson());
      expect(roundtripped.stopAt!.toUtc(), original.stopAt!.toUtc());
    });
  });

  group('Alert.isActive', () {
    test('true when stopAt is null', () {
      final alert = Alert.fromJson(kActiveAlertJson);
      expect(alert.isActive, isTrue);
    });

    test('true when stopAt is in the future', () {
      final future = DateTime.now().toUtc().add(const Duration(hours: 2));
      final json = Map<String, dynamic>.from(kActiveAlertJson)
        ..['stop_at'] = future.toIso8601String();
      expect(Alert.fromJson(json).isActive, isTrue);
    });

    test('false when stopAt is in the past', () {
      final alert = Alert.fromJson(kInactiveAlertJson);
      expect(alert.isActive, isFalse);
    });
  });

  group('Alert.title', () {
    test('extracts first Dutch sentence (up to first dot)', () {
      final alert = Alert.fromJson(kActiveAlertJson);
      // First Dutch sentence ends after "Amsterdam"
      expect(alert.title, contains('Amsterdam'));
      expect(alert.title, isNot(contains('***')));
      expect(alert.title.endsWith('.'), isFalse); // dot stripped
    });

    test('falls back to truncation when no dot within 100 chars', () {
      final json = Map<String, dynamic>.from(kActiveAlertJson)
        ..['message'] = 'A' * 150; // no dot, very long
      final alert = Alert.fromJson(json);
      expect(alert.title.length, lessThanOrEqualTo(91)); // 90 + '…'
      expect(alert.title.endsWith('…'), isTrue);
    });

    test('returns full short message when no dot and short', () {
      final json = Map<String, dynamic>.from(kActiveAlertJson)
        ..['message'] = 'Kort bericht zonder punt';
      final alert = Alert.fromJson(json);
      expect(alert.title, 'Kort bericht zonder punt');
    });

    test('does not include English part', () {
      final alert = Alert.fromJson(kActiveAlertJson);
      expect(alert.title, isNot(contains('Flooding')));
    });
  });

  group('Alert.dutchMessage / englishMessage', () {
    test('dutchMessage is text before ***', () {
      final alert = Alert.fromJson(kActiveAlertJson);
      expect(alert.dutchMessage, contains('Amsterdam'));
      expect(alert.dutchMessage, isNot(contains('***')));
      expect(alert.dutchMessage, isNot(contains('Flooding')));
    });

    test('englishMessage is text after ***', () {
      final alert = Alert.fromJson(kActiveAlertJson);
      expect(alert.englishMessage, contains('Flooding'));
      expect(alert.englishMessage, isNot(contains('***')));
    });

    test('englishMessage is empty when no *** separator', () {
      final alert = Alert.fromJson(kNlOnlyAlertJson);
      expect(alert.englishMessage, isEmpty);
    });
  });

  group('Alert equality', () {
    test('two alerts with the same id are equal', () {
      final a = Alert.fromJson(kActiveAlertJson);
      final b = Alert.fromJson(kActiveAlertJson);
      expect(a, equals(b));
    });

    test('alerts with different ids are not equal', () {
      final a = Alert.fromJson(kActiveAlertJson);
      final b = Alert.fromJson(kInactiveAlertJson);
      expect(a, isNot(equals(b)));
    });

    test('hashCode matches for equal alerts', () {
      final a = Alert.fromJson(kActiveAlertJson);
      final b = Alert.fromJson(kActiveAlertJson);
      expect(a.hashCode, b.hashCode);
    });
  });
}
