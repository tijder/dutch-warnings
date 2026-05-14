import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../screens/detail_screen.dart';
import '../screens/list_screen.dart';
import '../screens/main_screen.dart';
import '../screens/map_overview_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/stats_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/',
          page: MainRoute.page,
          children: [
            AutoRoute(path: '', page: ListRoute.page, initial: true),
            AutoRoute(path: 'map', page: MapOverviewRoute.page),
            AutoRoute(path: 'stats', page: StatsRoute.page),
            AutoRoute(path: 'settings', page: SettingsRoute.page),
          ],
        ),
        AutoRoute(path: '/warning/:id', page: DetailRoute.page),
      ];
}
