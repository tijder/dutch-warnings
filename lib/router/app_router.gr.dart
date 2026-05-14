// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [DetailScreen]
class DetailRoute extends PageRouteInfo<DetailRouteArgs> {
  DetailRoute({
    Key? key,
    required String alertId,
    List<PageRouteInfo>? children,
  }) : super(
         DetailRoute.name,
         args: DetailRouteArgs(key: key, alertId: alertId),
         rawPathParams: {'id': alertId},
         initialChildren: children,
       );

  static const String name = 'DetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<DetailRouteArgs>(
        orElse: () => DetailRouteArgs(alertId: pathParams.getString('id')),
      );
      return DetailScreen(key: args.key, alertId: args.alertId);
    },
  );
}

class DetailRouteArgs {
  const DetailRouteArgs({this.key, required this.alertId});

  final Key? key;

  final String alertId;

  @override
  String toString() {
    return 'DetailRouteArgs{key: $key, alertId: $alertId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DetailRouteArgs) return false;
    return key == other.key && alertId == other.alertId;
  }

  @override
  int get hashCode => key.hashCode ^ alertId.hashCode;
}

/// generated route for
/// [ListScreen]
class ListRoute extends PageRouteInfo<void> {
  const ListRoute({List<PageRouteInfo>? children})
    : super(ListRoute.name, initialChildren: children);

  static const String name = 'ListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ListScreen();
    },
  );
}

/// generated route for
/// [MainScreen]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainScreen();
    },
  );
}

/// generated route for
/// [MapOverviewScreen]
class MapOverviewRoute extends PageRouteInfo<void> {
  const MapOverviewRoute({List<PageRouteInfo>? children})
    : super(MapOverviewRoute.name, initialChildren: children);

  static const String name = 'MapOverviewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MapOverviewScreen();
    },
  );
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}

/// generated route for
/// [StatsScreen]
class StatsRoute extends PageRouteInfo<void> {
  const StatsRoute({List<PageRouteInfo>? children})
    : super(StatsRoute.name, initialChildren: children);

  static const String name = 'StatsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StatsScreen();
    },
  );
}
