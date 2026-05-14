import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../l10n/l10n.dart';
import '../models/alert.dart';
import '../providers/alerts_provider.dart';

@RoutePage()
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
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

  @override
  Widget build(BuildContext context) {
    ref.listen<AlertsState>(alertsProvider, (prev, next) {
      if (prev?.hasMore == false && next.hasMore) _loadAllTriggered = false;
      if (prev?.isLoading == true && !next.isLoading) _maybeLoadAll();
    });

    final alertsState = ref.watch(alertsProvider);
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l.statsTitle)),
      body: alertsState.hasMore
          ? _LoadingBody(state: alertsState)
          : _ChartsBody(alerts: alertsState.alerts),
    );
  }
}

// ── Loading ──────────────────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody({required this.state});
  final AlertsState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: 24),
            Text(l.statsLoading, style: theme.textTheme.titleMedium),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(minHeight: 6),
            ),
            const SizedBox(height: 8),
            Text(
              l.statsLoadingCount(state.alerts.length),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Charts container ─────────────────────────────────────────────────────────

class _ChartsBody extends StatelessWidget {
  const _ChartsBody({required this.alerts});
  final List<Alert> alerts;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    final locale = Localizations.localeOf(context).toString();

    return LayoutBuilder(
      builder: (context, constraints) {
        final hPad =
            constraints.maxWidth > 700 ? (constraints.maxWidth - 700) / 2 : 0.0;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad + 16, 16, hPad + 16, 24),
          child: Column(
            children: [
              _ChartCard(
                title: l.statsChartMonthly,
                info: l.statsChartMonthlyInfo,
                child: _MonthlyChart(
                    alerts: alerts, color: color, locale: locale),
              ),
              const SizedBox(height: 16),
              _ChartCard(
                title: l.statsChartTimeline,
                info: l.statsChartTimelineInfo,
                child: _TimelineChart(alerts: alerts, color: color),
              ),
              const SizedBox(height: 16),
              _ChartCard(
                title: l.statsChartDuration,
                info: l.statsChartDurationInfo,
                child: _DurationChart(alerts: alerts, color: color),
              ),
              const SizedBox(height: 16),
              _ChartCard(
                title: l.statsChartByHour,
                info: l.statsChartByHourInfo,
                child: _HourChart(alerts: alerts, color: color),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.info,
    required this.child,
  });
  final String title;
  final String info;
  final Widget child;

  void _showInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(info),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.done),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 20),
                  color: theme.colorScheme.outline,
                  tooltip: title,
                  onPressed: () => _showInfo(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(height: 200, child: child),
          ],
        ),
      ),
    );
  }
}

// ── Shared chart helpers ──────────────────────────────────────────────────────

BarTouchData _touchData(ThemeData theme,
    BarTooltipItem? Function(BarChartGroupData, int, BarChartRodData, int)
        getItem) {
  return BarTouchData(
    touchTooltipData: BarTouchTooltipData(
      getTooltipColor: (_) => theme.colorScheme.inverseSurface,
      getTooltipItem: getItem,
    ),
  );
}

FlGridData _gridData(ThemeData theme) => FlGridData(
      show: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (_) => FlLine(
        color: theme.colorScheme.outlineVariant,
        strokeWidth: 0.5,
      ),
    );

FlTitlesData _titlesData(SideTitles Function(AxisSide) bottomTitles) =>
    FlTitlesData(
      bottomTitles: AxisTitles(sideTitles: bottomTitles(AxisSide.bottom)),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );

BarChartRodData _rod(double y, Color color, double width) => BarChartRodData(
      toY: y,
      color: color,
      width: width,
      borderRadius: BorderRadius.circular(3),
    );

// ── Chart 1: Alerts per maand ─────────────────────────────────────────────────

class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart(
      {required this.alerts, required this.color, required this.locale});
  final List<Alert> alerts;
  final Color color;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // counts[0] = januari, counts[11] = december — alle jaren bij elkaar opgeteld
    final counts = List.filled(12, 0);
    for (final alert in alerts) {
      counts[alert.startAt.month - 1]++;
    }

    final maxY = counts.reduce((a, b) => a > b ? a : b).toDouble();
    final fmt = DateFormat('MMM', locale);

    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 1 : maxY * 1.2,
        barGroups: List.generate(
          12,
          (i) => BarChartGroupData(
              x: i, barRods: [_rod(counts[i].toDouble(), color, 14)]),
        ),
        titlesData: _titlesData((_) => SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= 12) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    fmt.format(DateTime(2000, i + 1)),
                    style: TextStyle(
                        fontSize: 10, color: theme.colorScheme.outline),
                  ),
                );
              },
            )),
        borderData: FlBorderData(show: false),
        gridData: _gridData(theme),
        barTouchData: _touchData(theme, (group, _, rod, _) => BarTooltipItem(
              rod.toY.round().toString(),
              TextStyle(
                  color: theme.colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w600),
            )),
      ),
    );
  }
}

// ── Chart 2: Alerts over tijd (per jaar) ─────────────────────────────────────

class _TimelineChart extends StatelessWidget {
  const _TimelineChart({required this.alerts, required this.color});
  final List<Alert> alerts;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l10n;

    if (alerts.isEmpty) return Center(child: Text(l.statsNoData));

    final countsByYear = <int, int>{};
    for (final alert in alerts) {
      final y = alert.startAt.year;
      countsByYear[y] = (countsByYear[y] ?? 0) + 1;
    }

    final years = countsByYear.keys.toList()..sort();
    final spots = years
        .map((y) => FlSpot(y.toDouble(), countsByYear[y]!.toDouble()))
        .toList();

    final maxY = countsByYear.values.reduce((a, b) => a > b ? a : b).toDouble();
    final minX = years.first.toDouble();
    final maxX = years.last.toDouble();

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: 0,
        maxY: maxY * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: color,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: color,
                strokeWidth: 2,
                strokeColor: theme.colorScheme.surface,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withAlpha(40),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: years.length > 8 ? ((years.last - years.first) / 6).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) {
                final y = value.toInt();
                if (!years.contains(y) && value != value.roundToDouble()) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '$y',
                    style: TextStyle(
                        fontSize: 10, color: theme.colorScheme.outline),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: _gridData(theme),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => theme.colorScheme.inverseSurface,
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '${s.x.toInt()}: ${s.y.toInt()}',
                      TextStyle(
                        color: theme.colorScheme.onInverseSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ── Chart 3: Duur van alerts ──────────────────────────────────────────────────

class _DurationChart extends StatelessWidget {
  const _DurationChart({required this.alerts, required this.color});
  final List<Alert> alerts;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l10n;

    final buckets = [0, 0, 0, 0];
    for (final alert in alerts.where((a) => a.stopAt != null)) {
      final hours = alert.stopAt!.difference(alert.startAt).inHours;
      if (hours < 1) {
        buckets[0]++;
      } else if (hours < 4) {
        buckets[1]++;
      } else if (hours < 24) {
        buckets[2]++;
      } else {
        buckets[3]++;
      }
    }

    final labels = [
      l.statsDurLt1h,
      l.statsDur1to4h,
      l.statsDur4to24h,
      l.statsDurGt24h,
    ];
    final maxY = buckets.reduce((a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 1 : maxY * 1.2,
        barGroups: List.generate(
          4,
          (i) => BarChartGroupData(
              x: i, barRods: [_rod(buckets[i].toDouble(), color, 40)]),
        ),
        titlesData: _titlesData((_) => SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= 4) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                        fontSize: 10, color: theme.colorScheme.outline),
                  ),
                );
              },
            )),
        borderData: FlBorderData(show: false),
        gridData: _gridData(theme),
        barTouchData: _touchData(theme, (group, _, rod, _) => BarTooltipItem(
              rod.toY.round().toString(),
              TextStyle(
                  color: theme.colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w600),
            )),
      ),
    );
  }
}

// ── Chart 4: Alerts per uur ───────────────────────────────────────────────────

class _HourChart extends StatelessWidget {
  const _HourChart({required this.alerts, required this.color});
  final List<Alert> alerts;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hourCounts = List.filled(24, 0);
    for (final alert in alerts) {
      hourCounts[alert.startAt.hour]++;
    }
    final maxY = hourCounts.reduce((a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 1 : maxY * 1.2,
        barGroups: List.generate(
          24,
          (i) => BarChartGroupData(
              x: i, barRods: [_rod(hourCounts[i].toDouble(), color, 8)]),
        ),
        titlesData: _titlesData((_) => SideTitles(
              showTitles: true,
              interval: 4,
              getTitlesWidget: (value, meta) {
                final h = value.toInt();
                if (h % 4 != 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '$h',
                    style: TextStyle(
                        fontSize: 10, color: theme.colorScheme.outline),
                  ),
                );
              },
            )),
        borderData: FlBorderData(show: false),
        gridData: _gridData(theme),
        barTouchData: _touchData(theme, (group, _, rod, _) => BarTooltipItem(
              '${group.x}:00 (${rod.toY.round()})',
              TextStyle(
                  color: theme.colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w600),
            )),
      ),
    );
  }
}
