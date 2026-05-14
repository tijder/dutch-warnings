import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../models/alert.dart';
import '../l10n/l10n.dart';
import '../providers/alerts_provider.dart';
import '../router/app_router.dart';
import '../providers/auto_refresh_provider.dart';
import '../providers/location_provider.dart';
import '../providers/notification_watcher_provider.dart';
import '../services/notification_service.dart';
import '../widgets/alert_card.dart';

@RoutePage()
class ListScreen extends ConsumerStatefulWidget {
  const ListScreen({super.key});

  @override
  ConsumerState<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<ListScreen> {
  final _scrollController = ScrollController();
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Delay to avoid conflicting with the geolocator permission dialog,
      // which is also requested on first launch.
      _notificationTimer = Timer(const Duration(seconds: 2), () async {
        if (mounted) await NotificationService.instance.requestPermission();
      });
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(alertsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(autoRefreshProvider);
    ref.watch(notificationWatcherProvider);
    final state = ref.watch(alertsProvider);
    final locationAsync = ref.watch(locationProvider);
    final userLocation = locationAsync.value;

    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/icon/icon.png', width: 28, height: 28,
                errorBuilder: (ctx, err, st) =>
                    const Icon(Icons.warning_amber_rounded)),
            const SizedBox(width: 10),
            Flexible(child: Text(l.appTitle, overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          if (state.isOffline)
            Tooltip(
              message: l.offlineBanner,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(Icons.cloud_off,
                    color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (locationAsync.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (userLocation != null)
            Tooltip(
              message: l.locationAvailable,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.my_location,
                    color: Theme.of(context).colorScheme.primary),
              ),
            )
          else
            Tooltip(
              message: l.locationUnavailable,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.location_off,
                    color: Theme.of(context).colorScheme.outline),
              ),
            ),
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l.refresh,
              onPressed: () => ref.read(alertsProvider.notifier).refresh(),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Horizontal padding centers content up to 700px; ListView stays
          // full-width so the entire screen area responds to scroll gestures.
          final hPad = constraints.maxWidth > 700
              ? (constraints.maxWidth - 700) / 2
              : 0.0;

          return RefreshIndicator(
            onRefresh: () => ref.read(alertsProvider.notifier).refresh(),
            child: _buildBody(state, userLocation, hPad),
          );
        },
      ),
    );
  }

  Widget _buildBody(AlertsState state, LatLng? userLocation, double hPad) {
    if (state.isLoading && state.alerts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final l = context.l10n;

    if (state.alerts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                const Icon(Icons.notifications_off_outlined,
                    size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text(l.noAlertsFound,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 8),
      itemCount: state.alerts.length + 2, // header + footer
      itemBuilder: (context, index) {
        if (index == 0) return _buildHeader(state);
        final alertIndex = index - 1;
        if (alertIndex < state.alerts.length) {
          final alert = state.alerts[alertIndex];
          return AlertCard(
            alert: alert,
            userLocation: userLocation,
            onTap: () => _openDetail(alert),
          );
        }
        return _buildFooter(state);
      },
    );
  }

  Widget _buildHeader(AlertsState state) {
    final active = state.alerts.where((a) => a.isActive).length;
    if (active == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            context.l10n.activeAlertsCount(active),
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(AlertsState state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!state.hasMore) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(context.l10n.allMessagesLoaded,
              style: const TextStyle(color: Colors.grey)),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _openDetail(Alert alert) {
    context.pushRoute(DetailRoute(alertId: alert.id));
  }
}
