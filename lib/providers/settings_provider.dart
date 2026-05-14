import 'package:flutter_riverpod/legacy.dart';
import '../services/settings_service.dart';

class SettingsState {
  const SettingsState({
    this.tileServerUrl = kDefaultTileServer,
    this.autoRefreshEnabled = false,
    this.autoRefreshIntervalMinutes = 5,
    this.locationMode = LocationMode.automatic,
    this.manualLatitude,
    this.manualLongitude,
    this.debugInjectAlert = false,
  });

  final String tileServerUrl;
  final bool autoRefreshEnabled;
  final int autoRefreshIntervalMinutes;
  final LocationMode locationMode;
  final double? manualLatitude;
  final double? manualLongitude;
  final bool debugInjectAlert;

  SettingsState copyWith({
    String? tileServerUrl,
    bool? autoRefreshEnabled,
    int? autoRefreshIntervalMinutes,
    LocationMode? locationMode,
    double? manualLatitude,
    double? manualLongitude,
    bool? debugInjectAlert,
  }) =>
      SettingsState(
        tileServerUrl: tileServerUrl ?? this.tileServerUrl,
        autoRefreshEnabled: autoRefreshEnabled ?? this.autoRefreshEnabled,
        autoRefreshIntervalMinutes:
            autoRefreshIntervalMinutes ?? this.autoRefreshIntervalMinutes,
        locationMode: locationMode ?? this.locationMode,
        manualLatitude: manualLatitude ?? this.manualLatitude,
        manualLongitude: manualLongitude ?? this.manualLongitude,
        debugInjectAlert: debugInjectAlert ?? this.debugInjectAlert,
      );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._service) : super(const SettingsState()) {
    _load();
  }

  final SettingsService _service;

  Future<void> _load() async {
    state = SettingsState(
      tileServerUrl: await _service.getTileServerUrl(),
      autoRefreshEnabled: await _service.getAutoRefreshEnabled(),
      autoRefreshIntervalMinutes: await _service.getAutoRefreshInterval(),
      locationMode: await _service.getLocationMode(),
      manualLatitude: await _service.getManualLatitude(),
      manualLongitude: await _service.getManualLongitude(),
      debugInjectAlert: await _service.getDebugInjectAlert(),
    );
  }

  Future<void> setTileServerUrl(String url) async {
    await _service.setTileServerUrl(url);
    state = state.copyWith(tileServerUrl: url);
  }

  Future<void> resetTileServerUrl() async {
    await _service.resetTileServerUrl();
    state = state.copyWith(tileServerUrl: kDefaultTileServer);
  }

  Future<void> setAutoRefreshEnabled(bool value) async {
    await _service.setAutoRefreshEnabled(value);
    state = state.copyWith(autoRefreshEnabled: value);
  }

  Future<void> setAutoRefreshInterval(int minutes) async {
    await _service.setAutoRefreshInterval(minutes);
    state = state.copyWith(autoRefreshIntervalMinutes: minutes);
  }

  Future<void> setLocationMode(LocationMode mode) async {
    await _service.setLocationMode(mode);
    state = state.copyWith(locationMode: mode);
  }

  Future<void> setDebugInjectAlert(bool value) async {
    await _service.setDebugInjectAlert(value);
    state = state.copyWith(debugInjectAlert: value);
  }

  Future<void> setManualCoordinates(double lat, double lng) async {
    await _service.setManualCoordinates(lat, lng);
    state = SettingsState(
      tileServerUrl: state.tileServerUrl,
      autoRefreshEnabled: state.autoRefreshEnabled,
      autoRefreshIntervalMinutes: state.autoRefreshIntervalMinutes,
      locationMode: state.locationMode,
      manualLatitude: lat,
      manualLongitude: lng,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(SettingsService());
});
