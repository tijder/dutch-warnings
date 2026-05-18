import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../l10n/l10n.dart';
import '../providers/alerts_provider.dart';
import '../providers/settings_provider.dart';
import '../services/settings_service.dart';

@RoutePage()
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _tileController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  bool _tileDirty = false;
  bool _coordsDirty = false;
  final _locationModeKey = GlobalKey<FormFieldState<LocationMode>>();

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _tileController = TextEditingController(text: s.tileServerUrl);
    _tileController.addListener(_onTileChanged);
    _latController = TextEditingController(
      text: s.manualLatitude?.toString() ?? '',
    );
    _lngController = TextEditingController(
      text: s.manualLongitude?.toString() ?? '',
    );
    _latController.addListener(_onCoordsChanged);
    _lngController.addListener(_onCoordsChanged);
  }

  @override
  void dispose() {
    _tileController.removeListener(_onTileChanged);
    _latController.removeListener(_onCoordsChanged);
    _lngController.removeListener(_onCoordsChanged);
    _tileController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _onTileChanged() {
    final current = ref.read(settingsProvider).tileServerUrl;
    setState(() => _tileDirty = _tileController.text.trim() != current);
  }

  void _onCoordsChanged() {
    final s = ref.read(settingsProvider);
    final latText = _latController.text.trim();
    final lngText = _lngController.text.trim();
    final lat = double.tryParse(latText);
    final lng = double.tryParse(lngText);
    setState(() {
      _coordsDirty = lat != null &&
          lng != null &&
          (lat != s.manualLatitude || lng != s.manualLongitude);
    });
  }

  void _applyPreset(String url) {
    _tileController.text = url;
    _saveTile();
  }

  Future<void> _saveTile() async {
    final url = _tileController.text.trim();
    if (url.isEmpty) return;
    final msg = context.l10n.tileServerSaved;
    await ref.read(settingsProvider.notifier).setTileServerUrl(url);
    setState(() => _tileDirty = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  Future<void> _resetTile() async {
    await ref.read(settingsProvider.notifier).resetTileServerUrl();
    _tileController.text = kDefaultTileServer;
    setState(() => _tileDirty = false);
  }

  Future<void> _saveCoords() async {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if (lat == null || lng == null) return;
    final msg = context.l10n.coordinatesSaved;
    await ref.read(settingsProvider.notifier).setManualCoordinates(lat, lng);
    setState(() => _coordsDirty = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final alertsState = ref.watch(alertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settingsTitle),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final hPad = constraints.maxWidth > 700
              ? (constraints.maxWidth - 700) / 2
              : 0.0;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(hPad + 16, 24, hPad + 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Vernieuwen ───────────────────────────────────────────
                _sectionTitle(theme, l.refresh),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.autoRefresh,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Switch(
                      value: s.autoRefreshEnabled,
                      onChanged: (v) => ref
                          .read(settingsProvider.notifier)
                          .setAutoRefreshEnabled(v),
                    ),
                  ],
                ),
                if (s.autoRefreshEnabled) ...[
                  const SizedBox(height: 12),
                  Text(
                    l.interval,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    initialValue: s.autoRefreshIntervalMinutes,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: kAutoRefreshIntervalOptions.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(l.intervalMinutes(m)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        ref
                            .read(settingsProvider.notifier)
                            .setAutoRefreshInterval(v);
                      }
                    },
                  ),
                ],
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // ── Mijn locatie ─────────────────────────────────────────
                _sectionTitle(theme, l.sectionLocation),
                const SizedBox(height: 12),
                Text(
                  l.locationMode,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<LocationMode>(
                  key: _locationModeKey,
                  initialValue: s.locationMode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: LocationMode.automatic,
                      child: Text(l.locationAutomatic),
                    ),
                    DropdownMenuItem(
                      value: LocationMode.manual,
                      child: Text(l.locationManual),
                    ),
                    DropdownMenuItem(
                      value: LocationMode.off,
                      child: Text(l.locationOff),
                    ),
                  ],
                  onChanged: (v) async {
                    if (v == null) return;
                    if (v == LocationMode.automatic) {
                      var permission = await Geolocator.checkPermission();
                      if (permission == LocationPermission.denied) {
                        permission = await Geolocator.requestPermission();
                      }
                      if (!mounted) return;
                      if (permission == LocationPermission.denied ||
                          permission == LocationPermission.deniedForever) {
                        _locationModeKey.currentState?.reset();
                        return;
                      }
                    }
                    ref.read(settingsProvider.notifier).setLocationMode(v);
                  },
                ),
                if (s.locationMode == LocationMode.manual) ...[
                  const SizedBox(height: 16),
                  Text(
                    l.coordinates,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _latController,
                          decoration: InputDecoration(
                            labelText: l.latitude,
                            hintText: '52.3',
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          onSubmitted: (_) => _saveCoords(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _lngController,
                          decoration: InputDecoration(
                            labelText: l.longitude,
                            hintText: '5.3',
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          onSubmitted: (_) => _saveCoords(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: _coordsDirty ? _saveCoords : null,
                        child: Text(l.save),
                      ),
                      if (s.manualLatitude != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${s.manualLatitude!.toStringAsFixed(5)}, '
                          '${s.manualLongitude!.toStringAsFixed(5)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // ── Kaart ────────────────────────────────────────────────
                _sectionTitle(theme, l.sectionMap),
                const SizedBox(height: 16),
                Text(
                  l.tileServerUrl,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _tileController,
                  decoration: InputDecoration(
                    hintText: kDefaultTileServer,
                    border: const OutlineInputBorder(),
                    suffixIcon: _tileDirty
                        ? IconButton(
                            icon: const Icon(Icons.check),
                            tooltip: l.save,
                            onPressed: _saveTile,
                          )
                        : null,
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  onSubmitted: (_) => _saveTile(),
                ),
                const SizedBox(height: 4),
                Text(
                  l.tileServerHint('{z}', '{x}', '{y}'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l.presets,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kTileServerPresets.map((preset) {
                    final selected =
                        s.tileServerUrl == preset.url && !_tileDirty;
                    return ChoiceChip(
                      label: Text(preset.label),
                      selected: selected,
                      onSelected: (_) => _applyPreset(preset.url),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  icon: const Icon(Icons.restore),
                  label: Text(l.resetDefaults),
                  onPressed: s.tileServerUrl == kDefaultTileServer && !_tileDirty
                      ? null
                      : _resetTile,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // ── Gegevens ─────────────────────────────────────────────
                _sectionTitle(theme, l.sectionData),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: alertsState.isLoadingAll
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.download_outlined),
                        label: Text(l.loadAllAlerts),
                        onPressed: alertsState.isLoadingAll ||
                                alertsState.isLoading ||
                                !alertsState.hasMore
                            ? null
                            : () =>
                                ref.read(alertsProvider.notifier).loadAll(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  alertsState.isLoadingAll
                      ? l.alertsLoadingCount(alertsState.alerts.length)
                      : !alertsState.hasMore
                          ? l.allAlertsLoadedCount(alertsState.alerts.length)
                          : l.alertsCount(alertsState.alerts.length),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // ── Over ─────────────────────────────────────────────────
                _sectionTitle(theme, l.sectionAbout),
                const SizedBox(height: 4),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/icon/icon.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                  title: const Text('Dutch Warnings'),
                  subtitle: Text(l.aboutVersion('1.0.0')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Dutch Warnings',
                    applicationVersion: '1.0.0',
                    applicationIcon: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/icon/icon.png',
                        width: 64,
                        height: 64,
                      ),
                    ),
                    applicationLegalese: l.aboutLegalese,
                  ),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  _sectionTitle(theme, l.sectionDebug),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.debugFakeAlert,
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              l.debugFakeAlertDesc,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: s.debugInjectAlert,
                        onChanged: (v) => ref
                            .read(settingsProvider.notifier)
                            .setDebugInjectAlert(v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: alertsState.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.notification_add_outlined),
                    label: Text(l.debugSendAlert),
                    onPressed: alertsState.isLoading
                        ? null
                        : () async {
                            if (!s.debugInjectAlert) {
                              await ref
                                  .read(settingsProvider.notifier)
                                  .setDebugInjectAlert(true);
                            }
                            await ref
                                .read(alertsProvider.notifier)
                                .refresh();
                          },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
