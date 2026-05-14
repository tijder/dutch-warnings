import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/notification_service.dart';
import '../utils/geo_utils.dart';
import 'alerts_provider.dart';
import 'location_provider.dart';

class NotificationWatcher extends StateNotifier<Set<String>> {
  NotificationWatcher(Ref ref) : super({}) {
    _ref = ref;
    ref.listen<AlertsState>(alertsProvider, _onAlertsChanged);
  }

  late final Ref _ref;
  bool _seeded = false;

  void _onAlertsChanged(AlertsState? prev, AlertsState next) {
    if (next.isLoading || next.alerts.isEmpty) return;

    if (!_seeded) {
      // First load: record all current alerts as seen without notifying.
      _seeded = true;
      state = next.alerts.map((a) => a.id).toSet();
      return;
    }

    final newActive = next.alerts
        .where((a) => a.isActive && !state.contains(a.id))
        .toList();

    if (newActive.isNotEmpty) {
      final location = _ref.read(locationProvider).value;
      for (final alert in newActive) {
        final inArea =
            location != null && isUserInAlertArea(location, alert.area);
        NotificationService.instance
            .showAlertNotification(alert, withSound: inArea);
      }
    }

    // Accumulate all seen IDs so we never notify the same alert twice.
    state = {...state, ...next.alerts.map((a) => a.id)};
  }
}

final notificationWatcherProvider =
    StateNotifierProvider<NotificationWatcher, Set<String>>((ref) {
  return NotificationWatcher(ref);
});
