import 'package:dutch_warnings/models/alert.dart';
import 'package:dutch_warnings/providers/alerts_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/fixtures.dart';

/// Creates a container with a fresh AlertsNotifier backed by the given fakes,
/// waits for initialization to finish, and registers cleanup.
Future<ProviderContainer> makeContainer(
  FakeApiService api,
  FakeCacheService cache,
) async {
  final container = ProviderContainer(
    overrides: [
      alertsProvider.overrideWith(
        (ref) => AlertsNotifier(api: api, cache: cache),
      ),
    ],
  );
  // Read the notifier to trigger creation, then wait for _initialize().
  await container.read(alertsProvider.notifier).ready;
  return container;
}

void main() {
  group('AlertsNotifier – initial state', () {
    test('exposes isLoading=true before initialization completes', () async {
      // Create the container but do NOT await ready before asserting.
      final cache = FakeCacheService();
      final api = FakeApiService.singlePage([makeActiveAlert()]);
      final container = ProviderContainer(
        overrides: [
          alertsProvider.overrideWith(
            (ref) => AlertsNotifier(api: api, cache: cache),
          ),
        ],
      );
      // Immediately after construction the state should be loading.
      expect(container.read(alertsProvider).isLoading, isTrue);
      expect(container.read(alertsProvider).alerts, isEmpty);
      // Drain async initialization before disposal to avoid the
      // _debugIsMounted assertion from state_notifier.
      await container.read(alertsProvider.notifier).ready;
      container.dispose();
    });
  });

  group('AlertsNotifier – after initialization', () {
    test('loads alerts from API into cache and exposes them', () async {
      final active = makeActiveAlert(id: 'a1');
      final inactive = makeInactiveAlert(id: 'i1');
      final api = FakeApiService.singlePage([active, inactive]);
      final cache = FakeCacheService();

      final container = await makeContainer(api, cache);
      addTearDown(container.dispose);

      final state = container.read(alertsProvider);
      expect(state.isLoading, isFalse);
      expect(state.isOffline, isFalse);
      expect(state.alerts, hasLength(2));
      expect(state.alerts.map((a) => a.id), containsAll(['a1', 'i1']));
    });

    test('persists alerts to cache during init', () async {
      final alert = makeActiveAlert(id: 'cached');
      final api = FakeApiService.singlePage([alert]);
      final cache = FakeCacheService();

      final container = await makeContainer(api, cache);
      addTearDown(container.dispose);

      expect(cache.storedAlerts.map((a) => a.id), contains('cached'));
    });

    test('falls back to cache when API throws', () async {
      final cached = makeActiveAlert(id: 'from-cache');
      // Pre-seed the cache.
      final cache = FakeCacheService();
      await cache.saveAlerts([cached]);

      // API always throws.
      final api = _ThrowingApiService();
      final container = await makeContainer(api, cache);
      addTearDown(container.dispose);

      final state = container.read(alertsProvider);
      expect(state.isOffline, isTrue);
      expect(state.alerts.map((a) => a.id), contains('from-cache'));
    });

    test('sets hasMore=false when API returns empty list', () async {
      final api = FakeApiService.empty();
      final cache = FakeCacheService();

      final container = await makeContainer(api, cache);
      addTearDown(container.dispose);

      expect(container.read(alertsProvider).hasMore, isFalse);
    });
  });

  group('AlertsNotifier.refresh', () {
    test('replaces state with fresh API data', () async {
      final first = makeActiveAlert(id: 'first');
      final second = makeActiveAlert(id: 'second');
      // Page 1 is returned on init; page 2 on the explicit refresh call.
      final api = FakeApiService([
        [first],
        [second],
      ]);
      final cache = FakeCacheService();

      final container = await makeContainer(api, cache);
      addTearDown(container.dispose);

      await container.read(alertsProvider.notifier).refresh();

      final ids = container.read(alertsProvider).alerts.map((a) => a.id);
      // Both pages are now in the cache and therefore in state.
      expect(ids, containsAll(['first', 'second']));
    });

    test('sets isOffline=true on network error during refresh', () async {
      // Init succeeds; refresh fails.
      final api = _HybridApiService(
        firstResult: [makeActiveAlert()],
        thenThrow: true,
      );
      final cache = FakeCacheService();
      final container = await makeContainer(api, cache);
      addTearDown(container.dispose);

      await container.read(alertsProvider.notifier).refresh();

      expect(container.read(alertsProvider).isOffline, isTrue);
    });
  });

  group('AlertsNotifier.loadMore', () {
    test('appends next page of alerts', () async {
      final page1 = [makeActiveAlert(id: 'p1-1'), makeActiveAlert(id: 'p1-2')];
      final page2 = [makeInactiveAlert(id: 'p2-1')];
      final api = FakeApiService([page1, page2]);
      final cache = FakeCacheService();

      final container = await makeContainer(api, cache);
      addTearDown(container.dispose);

      await container.read(alertsProvider.notifier).loadMore();

      final ids = container.read(alertsProvider).alerts.map((a) => a.id);
      expect(ids, containsAll(['p1-1', 'p1-2', 'p2-1']));
    });

    test('sets hasMore=false when next page is empty', () async {
      final api = FakeApiService([
        [makeActiveAlert()], // init page
        [], // loadMore returns nothing
      ]);
      final cache = FakeCacheService();
      final container = await makeContainer(api, cache);
      addTearDown(container.dispose);

      await container.read(alertsProvider.notifier).loadMore();

      expect(container.read(alertsProvider).hasMore, isFalse);
    });

    test('is a no-op when hasMore is false', () async {
      final api = FakeApiService.empty();
      final cache = FakeCacheService();
      final container = await makeContainer(api, cache);
      addTearDown(container.dispose);

      final callsBefore = api.callCount;
      await container.read(alertsProvider.notifier).loadMore();

      expect(api.callCount, callsBefore); // no extra call
    });

    test('is a no-op when alerts list is empty', () async {
      // API has data but cache stays empty (shouldn't happen in practice, but test the guard).
      final api = FakeApiService.empty();
      final cache = FakeCacheService();
      final container = await makeContainer(api, cache);
      addTearDown(container.dispose);

      final callsBefore = api.callCount;
      await container.read(alertsProvider.notifier).loadMore();
      expect(api.callCount, callsBefore);
    });
  });

  group('AlertsNotifier.loadAll', () {
    test('fetches all pages until API returns empty', () async {
      final page1 = List.generate(
          3, (i) => makeActiveAlert(id: 'a${i + 1}'));
      final page2 = List.generate(
          3, (i) => makeInactiveAlert(id: 'b${i + 1}'));
      // Init uses page1; loadAll uses page2 then gets empty.
      final api = FakeApiService([page1, page2]);
      final cache = FakeCacheService();

      final container = await makeContainer(api, cache);
      addTearDown(container.dispose);

      await container.read(alertsProvider.notifier).loadAll();

      expect(container.read(alertsProvider).alerts, hasLength(6));
      expect(container.read(alertsProvider).hasMore, isFalse);
      expect(container.read(alertsProvider).isLoadingAll, isFalse);
    });

    test('sets isLoadingAll=false after completion', () async {
      final api = FakeApiService.singlePage([makeActiveAlert()]);
      final cache = FakeCacheService();
      final container = await makeContainer(api, cache);
      addTearDown(container.dispose);

      await container.read(alertsProvider.notifier).loadAll();

      expect(container.read(alertsProvider).isLoadingAll, isFalse);
    });

    test('is a no-op when alerts list is empty', () async {
      final api = FakeApiService.empty();
      final cache = FakeCacheService();
      final container = await makeContainer(api, cache);
      addTearDown(container.dispose);

      final callsBefore = api.callCount;
      await container.read(alertsProvider.notifier).loadAll();
      expect(api.callCount, callsBefore);
    });
  });
}

// ---------------------------------------------------------------------------
// Local helpers
// ---------------------------------------------------------------------------

class _ThrowingApiService extends FakeApiService {
  _ThrowingApiService() : super.empty();

  @override
  Future<List<Alert>> fetchAlerts({String? after}) =>
      Future.error(Exception('no network'));
}

/// Succeeds on first call, then throws on all subsequent calls.
class _HybridApiService extends FakeApiService {
  _HybridApiService({required this._firstResult, required bool thenThrow})
      : super.empty();

  final List _firstResult;
  int _calls = 0;

  @override
  Future<List<Alert>> fetchAlerts({String? after}) {
    if (_calls++ == 0) return Future.value(List<Alert>.from(_firstResult));
    return Future.error(Exception('no network'));
  }
}
