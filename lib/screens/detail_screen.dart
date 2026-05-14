import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/l10n.dart';
import '../models/alert.dart';
import '../providers/alerts_provider.dart';
import '../providers/location_provider.dart';
import '../utils/geo_utils.dart';
import '../widgets/alert_map.dart';

@RoutePage()
class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key, @PathParam('id') required this.alertId});

  final String alertId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsState = ref.watch(alertsProvider);
    final alert = alertsState.alerts
        .where((a) => a.id == alertId)
        .firstOrNull;

    if (alert == null) {
      final l = context.l10n;
      return Scaffold(
        appBar: AppBar(title: Text(l.appTitle)),
        body: Center(child: Text(l.alertNotFound)),
      );
    }

    final locationAsync = ref.watch(locationProvider);
    final userLocation = locationAsync.value;
    final affected = userLocation != null &&
        alert.isActive &&
        isUserInAlertArea(userLocation, alert.area);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;
          return isWide
              ? _WideLayout(
                  alert: alert,
                  userLocation: userLocation,
                  affected: affected,
                )
              : _NarrowLayout(
                  alert: alert,
                  userLocation: userLocation,
                  affected: affected,
                );
        },
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.alert,
    required this.userLocation,
    required this.affected,
  });

  final Alert alert;
  final LatLng? userLocation;
  final bool affected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 400,
          child: _InfoPanel(
            alert: alert,
            userLocation: userLocation,
            affected: affected,
            showAppBar: true,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: AlertMap(alert: alert, userLocation: userLocation),
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.alert,
    required this.userLocation,
    required this.affected,
  });

  final Alert alert;
  final LatLng? userLocation;
  final bool affected;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: AlertMap(alert: alert, userLocation: userLocation),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SliverToBoxAdapter(
          child: _InfoPanel(
            alert: alert,
            userLocation: userLocation,
            affected: affected,
            showAppBar: false,
          ),
        ),
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.alert,
    required this.userLocation,
    required this.affected,
    required this.showAppBar,
  });

  final Alert alert;
  final LatLng? userLocation;
  final bool affected;
  final bool showAppBar;

  Widget _content(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final fmt = DateFormat('dd MMMM yyyy HH:mm', locale);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusRow(isActive: alert.isActive, affected: affected),
          const SizedBox(height: 12),
          Text(
            alert.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.schedule,
            label: l.startTime,
            value: fmt.format(alert.startAt),
          ),
          if (alert.stopAt != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.stop_circle_outlined,
              label: l.endTime,
              value: fmt.format(alert.stopAt!),
            ),
          ],
          const SizedBox(height: 20),
          _MessageSection(
            label: l.messageLabelDutch,
            text: alert.dutchMessage,
          ),
          if (alert.englishMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            _MessageSection(
              label: l.messageLabelEnglish,
              text: alert.englishMessage,
            ),
          ],
          if (affected) ...[
            const SizedBox(height: 16),
            _AffectedBanner(),
          ],
          const SizedBox(height: 24),
          Text(
            l.alertId(alert.id),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!showAppBar) {
      // In narrow layout: inside CustomScrollView — no Expanded needed.
      return _content(context);
    }

    // In wide layout: standalone scrollable panel with AppBar.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBar(
          title: Text(context.l10n.appTitle),
          centerTitle: false,
        ),
        Expanded(
          child: SingleChildScrollView(child: _content(context)),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.isActive, required this.affected});

  final bool isActive;
  final bool affected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        if (affected)
          _Chip(
            label: context.l10n.affectsYourLocation,
            icon: Icons.my_location,
            color: Colors.deepOrange,
          ),
        _Chip(
          label: isActive ? context.l10n.statusActive : context.l10n.statusPast,
          icon: isActive ? Icons.warning_amber_rounded : Icons.check_circle_outline,
          color: isActive ? Colors.orange : Colors.grey,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon, required this.color});

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline)),
            Text(value, style: theme.textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}

class _MessageSection extends StatelessWidget {
  const _MessageSection({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final urlRegex = RegExp(r'https?://\S+');
    final spans = <InlineSpan>[];
    int last = 0;
    for (final match in urlRegex.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start)));
      }
      final url = match.group(0)!;
      spans.add(WidgetSpan(
        child: GestureDetector(
          onTap: () => launchUrl(Uri.parse(url)),
          child: Text(
            url,
            style: TextStyle(
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ));
      last = match.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: theme.colorScheme.outline)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: spans,
            ),
          ),
        ),
      ],
    );
  }
}

class _AffectedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepOrange.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.deepOrange),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: Colors.deepOrange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.affectedBannerText,
              style: TextStyle(
                  color: Colors.deepOrange.shade800,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
