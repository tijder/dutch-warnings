import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/alert.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import 'settings_provider.dart';

class AlertsState {
  const AlertsState({
    required this.alerts,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isLoadingAll = false,
    this.hasMore = true,
    this.isOffline = false,
    this.error,
  });

  final List<Alert> alerts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isLoadingAll;
  final bool hasMore;
  final bool isOffline;
  final String? error;

  AlertsState copyWith({
    List<Alert>? alerts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isLoadingAll,
    bool? hasMore,
    bool? isOffline,
    String? error,
    bool clearError = false,
  }) =>
      AlertsState(
        alerts: alerts ?? this.alerts,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isLoadingAll: isLoadingAll ?? this.isLoadingAll,
        hasMore: hasMore ?? this.hasMore,
        isOffline: isOffline ?? this.isOffline,
        error: clearError ? null : error ?? this.error,
      );
}

Alert _makeFakeAlert() => Alert(
      id: 'debug-${DateTime.now().millisecondsSinceEpoch}',
      message: 'Test NL-Alert. Dit is een automatisch gegenereerde '
          'testalert voor debugdoeleinden. '
          '***Test NL-Alert. This is an automatically generated '
          'test alert for debugging purposes.',
      type: 'Alert',
      startAt: DateTime.now(),
      // Netherlands bounding box — covers all Dutch GPS locations.
      area: const ['50.75,3.36 53.56,3.36 53.56,7.23 50.75,7.23'],
    );

class AlertsNotifier extends StateNotifier<AlertsState> {
  AlertsNotifier({ApiService? api, CacheService? cache, Ref? ref})
      : _api = api ?? ApiService(),
        _cache = cache ?? CacheService(),
        _ref = ref,
        super(const AlertsState(alerts: [], isLoading: true)) {
    _ready = _initialize();
  }

  final ApiService _api;
  final CacheService _cache;
  final Ref? _ref;
  late final Future<void> _ready;
  // Fake alerts accumulate in memory for the lifetime of the notifier.
  final List<Alert> _fakeAlerts = [];

  // Exposed so tests can await initialization before asserting state.
  Future<void> get ready => _ready;

  Future<void> _initialize() async {
    final cached = await _cache.loadAlerts();
    if (cached.isNotEmpty) {
      state = state.copyWith(alerts: cached, isLoading: false);
    }
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final fresh = await _api.fetchAlerts();
      await _cache.saveAlerts(fresh);
      var all = await _cache.loadAlerts();
      if (kDebugMode &&
          (_ref?.read(settingsProvider).debugInjectAlert ?? false)) {
        _fakeAlerts.add(_makeFakeAlert());
        all = [..._fakeAlerts, ...all];
      }
      state = state.copyWith(
        alerts: all,
        isLoading: false,
        isOffline: false,
        hasMore: fresh.isNotEmpty,
      );
    } catch (_) {
      final cached = await _cache.loadAlerts();
      state = state.copyWith(
        alerts: cached,
        isLoading: false,
        isOffline: true,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.alerts.isEmpty) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final lastId = state.alerts.last.id;
      final more = await _api.fetchAlerts(after: lastId);
      if (more.isNotEmpty) {
        await _cache.saveAlerts(more);
        final all = await _cache.loadAlerts();
        state = state.copyWith(
          alerts: all,
          isLoadingMore: false,
          hasMore: more.isNotEmpty,
        );
      } else {
        state = state.copyWith(isLoadingMore: false, hasMore: false);
      }
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> loadAll() async {
    if (state.isLoadingAll || state.isLoading || state.alerts.isEmpty) return;
    state = state.copyWith(isLoadingAll: true);
    try {
      while (mounted && state.hasMore) {
        final lastId = state.alerts.last.id;
        final more = await _api.fetchAlerts(after: lastId);
        if (!mounted) break;
        if (more.isEmpty) {
          state = state.copyWith(hasMore: false);
          break;
        }
        await _cache.saveAlerts(more);
        if (!mounted) break;
        final all = await _cache.loadAlerts();
        if (!mounted) break;
        state = state.copyWith(alerts: all);
      }
    } catch (_) {
      // stop on error, leave hasMore as-is so user can retry
    }
    if (mounted) state = state.copyWith(isLoadingAll: false);
  }
}

final alertsProvider =
    StateNotifierProvider<AlertsNotifier, AlertsState>((ref) {
  return AlertsNotifier(ref: ref);
});
