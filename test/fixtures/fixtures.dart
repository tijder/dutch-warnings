import 'package:dutch_warnings/models/alert.dart';
import 'package:dutch_warnings/services/api_service.dart';
import 'package:dutch_warnings/services/cache_service.dart';
import 'package:dutch_warnings/services/settings_service.dart';
import 'package:latlong2/latlong.dart';

// ---------------------------------------------------------------------------
// Polygon strings (lat,lon pairs separated by spaces, closed ring)
// ---------------------------------------------------------------------------

const kAmsterdamPolygon =
    '52.3500,4.8500 52.4200,4.8500 52.4200,5.0000 52.3500,5.0000 52.3500,4.8500';

const kRotterdamPolygon =
    '51.8700,4.3000 51.9400,4.3000 51.9400,4.6000 51.8700,4.6000 51.8700,4.3000';

const kUtrechtPolygon =
    '52.0700,5.0500 52.1200,5.0500 52.1200,5.1500 52.0700,5.1500 52.0700,5.0500';

// ---------------------------------------------------------------------------
// Specific user locations
// ---------------------------------------------------------------------------

/// Inside kAmsterdamPolygon.
const kAmsterdamCenter = LatLng(52.3700, 4.9000);

/// In the North Sea – outside every Dutch polygon in this fixture set.
const kSeaLocation = LatLng(53.0000, 3.5000);

// ---------------------------------------------------------------------------
// Raw JSON maps – used directly in model tests
// ---------------------------------------------------------------------------

final Map<String, dynamic> kActiveAlertJson = {
  'id': '2c93acc6aaf2',
  'message':
      'NL-Alert. Wateroverlast verwacht in de omgeving van Amsterdam. '
      'Vermijd laaggelegen gebieden en ondergrondse parkeergarages. '
      'Volg de aanwijzingen van de hulpdiensten op.'
      '***'
      'NL-Alert. Flooding expected in the area of Amsterdam. '
      'Avoid low-lying areas and underground car parks. '
      'Follow the instructions of the emergency services.',
  'type': 'nl-alert',
  'start_at': '2024-06-15T10:30:00Z',
  'stop_at': null,
  'area': [kAmsterdamPolygon],
  'resource_uri':
      'https://api.public-warning.app/api/v1/providers/nl-alert/alerts/2c93acc6aaf2',
};

final Map<String, dynamic> kInactiveAlertJson = {
  'id': 'b7f2e1d3c8a1',
  'message':
      'NL-Alert. Brand in industriegebied Europoort te Rotterdam. '
      'Rook kan gevaarlijk zijn. Blijf binnen, sluit ramen en deuren en zet ventilatie uit.'
      '***'
      'NL-Alert. Fire in Europoort industrial area in Rotterdam. '
      'Smoke may be hazardous. Stay indoors, close windows and doors and turn off ventilation.',
  'type': 'nl-alert',
  'start_at': '2023-11-20T08:00:00Z',
  'stop_at': '2023-11-20T14:00:00Z',
  'area': [kRotterdamPolygon],
  'resource_uri':
      'https://api.public-warning.app/api/v1/providers/nl-alert/alerts/b7f2e1d3c8a1',
};

/// Alert with Dutch-only message (no *** separator).
final Map<String, dynamic> kNlOnlyAlertJson = {
  'id': 'nlonly-001',
  'message':
      'NL-Alert. Gaslek in Dordrecht Centrum. '
      'Verlaat het gebied en blijf op afstand. Rook niet en vermijd open vuur.',
  'type': 'nl-alert',
  'start_at': '2022-03-10T15:00:00Z',
  'stop_at': '2022-03-10T18:00:00Z',
  'area': [
    '51.8100,4.6500 51.8300,4.6500 51.8300,4.6900 51.8100,4.6900 51.8100,4.6500'
  ],
  'resource_uri': null,
};

/// Alert covering two separate areas.
final Map<String, dynamic> kMultiAreaAlertJson = {
  'id': 'multiarea-001',
  'message':
      'NL-Alert. Storm met zware windstoten verwacht in Noord-Holland. '
      'Blijf binnen en vermijd buitenactiviteiten.'
      '***'
      'NL-Alert. Storm with severe wind gusts expected in Noord-Holland. '
      'Stay indoors and avoid outdoor activities.',
  'type': 'nl-alert',
  'start_at': '2024-01-22T06:00:00Z',
  'stop_at': null,
  'area': [kAmsterdamPolygon, kUtrechtPolygon],
  'resource_uri': null,
};

// ---------------------------------------------------------------------------
// Convenience Alert factories
// ---------------------------------------------------------------------------

Alert makeActiveAlert({
  String id = 'active-001',
  String area = kAmsterdamPolygon,
  DateTime? startAt,
}) =>
    Alert.fromJson({
      'id': id,
      'message':
          'NL-Alert. Wateroverlast verwacht in de omgeving van Amsterdam. '
          'Vermijd laaggelegen gebieden en ondergrondse parkeergarages.'
          '***'
          'NL-Alert. Flooding expected in the area of Amsterdam. '
          'Avoid low-lying areas and underground car parks.',
      'type': 'nl-alert',
      'start_at':
          (startAt ?? DateTime.utc(2024, 6, 15, 10, 30)).toIso8601String(),
      'stop_at': null,
      'area': [area],
      'resource_uri':
          'https://api.public-warning.app/api/v1/providers/nl-alert/alerts/$id',
    });

Alert makeInactiveAlert({
  String id = 'inactive-001',
  String area = kRotterdamPolygon,
}) =>
    Alert.fromJson({
      'id': id,
      'message':
          'NL-Alert. Brand in industriegebied Europoort te Rotterdam. '
          'Rook kan gevaarlijk zijn. Blijf binnen, sluit ramen en deuren.'
          '***'
          'NL-Alert. Fire in Europoort industrial area in Rotterdam. '
          'Smoke may be hazardous. Stay indoors, close windows and doors.',
      'type': 'nl-alert',
      'start_at': '2023-11-20T08:00:00Z',
      'stop_at': '2023-11-20T14:00:00Z',
      'area': [area],
      'resource_uri':
          'https://api.public-warning.app/api/v1/providers/nl-alert/alerts/$id',
    });

// ---------------------------------------------------------------------------
// Fake services – extend real classes and override only public methods
// ---------------------------------------------------------------------------

/// Returns pages sequentially; after all pages are exhausted returns [].
/// The [after] parameter is intentionally ignored – tests control pagination
/// purely by call order, which matches the real usage pattern.
class FakeApiService extends ApiService {
  FakeApiService(this._pages);
  FakeApiService.singlePage(List<Alert> alerts) : _pages = [alerts];
  FakeApiService.empty() : _pages = const [];

  final List<List<Alert>> _pages;
  int _callCount = 0;

  int get callCount => _callCount;

  @override
  Future<List<Alert>> fetchAlerts({String? after}) async {
    if (_callCount >= _pages.length) return [];
    return _pages[_callCount++];
  }
}

/// In-memory cache that never touches Hive.
class FakeCacheService extends CacheService {
  final Map<String, Alert> _store = {};

  List<Alert> get storedAlerts {
    final list = _store.values.toList()
      ..sort((a, b) => b.startAt.compareTo(a.startAt));
    return List.unmodifiable(list);
  }

  @override
  Future<void> saveAlerts(List<Alert> alerts) async {
    for (final a in alerts) {
      _store[a.id] = a;
    }
  }

  @override
  Future<List<Alert>> loadAlerts() async => storedAlerts;

  @override
  Future<void> clear() async => _store.clear();
}

/// In-memory settings that never touch Hive.
class FakeSettingsService extends SettingsService {
  String _tileUrl = kDefaultTileServer;
  bool _autoRefresh = false;
  int _interval = 5;
  LocationMode _locationMode = LocationMode.automatic;
  double? _lat;
  double? _lng;
  bool _debugInjectAlert = false;

  @override Future<String> getTileServerUrl() async => _tileUrl;
  @override Future<void> setTileServerUrl(String url) async => _tileUrl = url;
  @override Future<void> resetTileServerUrl() async => _tileUrl = kDefaultTileServer;

  @override Future<bool> getAutoRefreshEnabled() async => _autoRefresh;
  @override Future<void> setAutoRefreshEnabled(bool v) async => _autoRefresh = v;

  @override Future<int> getAutoRefreshInterval() async => _interval;
  @override Future<void> setAutoRefreshInterval(int m) async => _interval = m;

  @override Future<LocationMode> getLocationMode() async => _locationMode;
  @override Future<void> setLocationMode(LocationMode m) async => _locationMode = m;

  @override Future<double?> getManualLatitude() async => _lat;
  @override Future<double?> getManualLongitude() async => _lng;

  @override Future<bool> getDebugInjectAlert() async => _debugInjectAlert;
  @override Future<void> setDebugInjectAlert(bool v) async => _debugInjectAlert = v;

  @override
  Future<void> setManualCoordinates(double lat, double lng) async {
    _lat = lat;
    _lng = lng;
  }
}
