import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/alert.dart';

class CacheService {
  static const _boxName = 'alerts_v1';

  Future<Box> _openBox() => Hive.openBox(_boxName);

  Future<void> saveAlerts(List<Alert> alerts) async {
    final box = await _openBox();
    final batch = {for (final a in alerts) a.id: a.toJson()};
    await box.putAll(batch);
  }

  Future<List<Alert>> loadAlerts() async {
    final box = await _openBox();
    final alerts = <Alert>[];
    for (final v in box.values) {
      try {
        alerts.add(Alert.fromJson(Map<String, dynamic>.from(v as Map)));
      } catch (e) {
        debugPrint('[Cache] corrupt entry skipped: $e');
      }
    }
    alerts.sort((a, b) => b.startAt.compareTo(a.startAt));
    return alerts;
  }

  Future<void> clear() async {
    final box = await _openBox();
    await box.clear();
  }
}
