import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../l10n/l10n.dart';
import '../models/alert.dart';
import '../providers/alerts_provider.dart';
import '../providers/location_provider.dart';
import '../providers/settings_provider.dart';
import '../router/app_router.dart';
import '../utils/geo_utils.dart';

enum _MapMode { current, history }

@RoutePage()
class MapOverviewScreen extends ConsumerStatefulWidget {
  const MapOverviewScreen({super.key});

  @override
  ConsumerState<MapOverviewScreen> createState() => _MapOverviewScreenState();
}

class _MapOverviewScreenState extends ConsumerState<MapOverviewScreen> {
  _MapMode _mode = _MapMode.current;
  DateTimeRange? _dateRange;
  bool _loadAllTriggered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadAll());
  }

  void _maybeLoadAll() {
    if (!mounted) return;
    final s = ref.read(alertsProvider);
    if (!_loadAllTriggered &&
        s.hasMore &&
        !s.isLoading &&
        !s.isLoadingAll &&
        s.alerts.isNotEmpty) {
      _loadAllTriggered = true;
      ref.read(alertsProvider.notifier).loadAll();
    }
  }

  List<Alert> _filteredAlerts(List<Alert> alerts) {
    if (_mode == _MapMode.current) {
      return alerts.where((a) => a.isActive).toList();
    }
    if (_dateRange == null) return [];
    final start = _dateRange!.start.toUtc();
    final end = _dateRange!.end.toUtc().add(const Duration(days: 1));
    return alerts.where((a) {
      return a.startAt.isBefore(end) &&
          (a.stopAt == null || a.stopAt!.isAfter(start));
    }).toList();
  }

  void _setLast30Days() {
    final now = DateTime.now();
    setState(() => _dateRange = DateTimeRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        ));
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final l = context.l10n;
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
      firstDate: DateTime(2012),
      lastDate: now,
      helpText: l.selectPeriod,
      cancelText: l.cancel,
      confirmText: l.done,
      saveText: l.done,
    );
    if (range == null || !mounted) return;
    setState(() => _dateRange = range);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AlertsState>(alertsProvider, (prev, next) {
      if (prev?.hasMore == false && next.hasMore) _loadAllTriggered = false;
      if (prev?.isLoading == true && !next.isLoading) _maybeLoadAll();
    });

    final alertsState = ref.watch(alertsProvider);
    final locationAsync = ref.watch(locationProvider);
    final userLocation = locationAsync.value;
    final tileUrl = ref.watch(settingsProvider).tileServerUrl;
    final alerts = _filteredAlerts(alertsState.alerts);
    final l = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final fmt = DateFormat('dd/MM/yy', locale);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icon/icon.png',
              width: 28,
              height: 28,
              errorBuilder: (ctx, err, st) =>
                  const Icon(Icons.warning_amber_rounded),
            ),
            const SizedBox(width: 10),
            Text(l.mapOverviewTitle),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                SegmentedButton<_MapMode>(
                  segments: [
                    ButtonSegment(
                      value: _MapMode.current,
                      label: Text(l.mapModeCurrent),
                      icon: const Icon(Icons.notifications_active_outlined),
                    ),
                    ButtonSegment(
                      value: _MapMode.history,
                      label: Text(l.mapModeHistory),
                      icon: const Icon(Icons.history),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
                if (_mode == _MapMode.history) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.date_range, size: 18),
                      label: Text(
                        _dateRange == null
                            ? l.selectPeriod
                            : '${fmt.format(_dateRange!.start)} – ${fmt.format(_dateRange!.end)}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: _pickDateRange,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(52.3, 5.3),
              initialZoom: 7.0,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: tileUrl,
                userAgentPackageName: 'nl.g4d.dutch_warnings',
                tileProvider: NetworkTileProvider(
                  cachingProvider: const DisabledMapCachingProvider(),
                ),
              ),
              PolygonLayer(
                polygons: alerts.expand((alert) {
                  return alert.area.map(parsePolygon).map((poly) => Polygon(
                        points: poly,
                        color: alert.isActive
                            ? const Color(0x33FF5722)
                            : const Color(0x3321468B),
                        borderColor: alert.isActive
                            ? const Color(0xFFFF5722)
                            : const Color(0xFF21468B),
                        borderStrokeWidth: 2,
                      ));
                }).toList(),
              ),
              MarkerLayer(
                markers: alerts.expand((alert) {
                  return alert.area.map(parsePolygon).map((poly) {
                    final center = polygonCenter(poly);
                    return Marker(
                      point: center,
                      width: 36,
                      height: 36,
                      child: GestureDetector(
                        onTap: () => context
                            .pushRoute(DetailRoute(alertId: alert.id)),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: alert.isActive
                              ? Colors.deepOrange
                              : Colors.blueGrey,
                          size: 32,
                          shadows: const [
                            Shadow(color: Colors.white, blurRadius: 4)
                          ],
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),
              if (userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLocation,
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
                    l.osmContributors,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
          if (_mode == _MapMode.history && alertsState.hasMore)
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map, size: 56, color: theme.colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(l.statsLoading, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 240,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(minHeight: 6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.statsLoadingCount(alertsState.alerts.length),
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_mode == _MapMode.history && _dateRange == null)
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.date_range, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        l.selectPeriodTitle,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.selectPeriodDesc,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(l.choosePeriodButton),
                        onPressed: _pickDateRange,
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.history),
                        label: Text(l.last30Days),
                        onPressed: _setLast30Days,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_mode == _MapMode.current && alerts.isEmpty)
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        l.noActiveAlerts,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.noActiveAlertsDesc,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
