import 'package:hive_ce_flutter/hive_flutter.dart';

const kDefaultTileServer = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

const kTileServerPresets = [
  (label: 'OpenStreetMap', url: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
  (label: 'CartoDB Light', url: 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png'),
  (label: 'CartoDB Dark', url: 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'),
  (label: 'OpenTopoMap', url: 'https://tile.opentopomap.org/{z}/{x}/{y}.png'),
];

const kAutoRefreshIntervalOptions = [1, 5, 10, 15, 30];

enum LocationMode { automatic, manual, off }

class SettingsService {
  static const _boxName = 'settings_v1';
  static const _keyTileServer = 'tileServerUrl';
  static const _keyAutoRefreshEnabled = 'autoRefreshEnabled';
  static const _keyAutoRefreshInterval = 'autoRefreshInterval';
  static const _keyLocationMode = 'locationMode';
  static const _keyManualLat = 'manualLatitude';
  static const _keyManualLng = 'manualLongitude';
  static const _keyDebugInjectAlert = 'debugInjectAlert';

  Future<Box> _openBox() => Hive.openBox(_boxName);

  Future<String> getTileServerUrl() async {
    final box = await _openBox();
    return box.get(_keyTileServer, defaultValue: kDefaultTileServer) as String;
  }

  Future<void> setTileServerUrl(String url) async {
    final box = await _openBox();
    await box.put(_keyTileServer, url);
  }

  Future<void> resetTileServerUrl() async {
    final box = await _openBox();
    await box.put(_keyTileServer, kDefaultTileServer);
  }

  Future<bool> getAutoRefreshEnabled() async {
    final box = await _openBox();
    return box.get(_keyAutoRefreshEnabled, defaultValue: false) as bool;
  }

  Future<void> setAutoRefreshEnabled(bool value) async {
    final box = await _openBox();
    await box.put(_keyAutoRefreshEnabled, value);
  }

  Future<int> getAutoRefreshInterval() async {
    final box = await _openBox();
    return box.get(_keyAutoRefreshInterval, defaultValue: 5) as int;
  }

  Future<void> setAutoRefreshInterval(int minutes) async {
    final box = await _openBox();
    await box.put(_keyAutoRefreshInterval, minutes);
  }

  Future<LocationMode> getLocationMode() async {
    final box = await _openBox();
    final value = box.get(_keyLocationMode, defaultValue: 'automatic') as String;
    return LocationMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LocationMode.automatic,
    );
  }

  Future<void> setLocationMode(LocationMode mode) async {
    final box = await _openBox();
    await box.put(_keyLocationMode, mode.name);
  }

  Future<double?> getManualLatitude() async {
    final box = await _openBox();
    return box.get(_keyManualLat) as double?;
  }

  Future<double?> getManualLongitude() async {
    final box = await _openBox();
    return box.get(_keyManualLng) as double?;
  }

  Future<bool> getDebugInjectAlert() async {
    final box = await _openBox();
    return box.get(_keyDebugInjectAlert, defaultValue: false) as bool;
  }

  Future<void> setDebugInjectAlert(bool value) async {
    final box = await _openBox();
    await box.put(_keyDebugInjectAlert, value);
  }

  Future<void> setManualCoordinates(double lat, double lng) async {
    final box = await _openBox();
    await box.put(_keyManualLat, lat);
    await box.put(_keyManualLng, lng);
  }
}
