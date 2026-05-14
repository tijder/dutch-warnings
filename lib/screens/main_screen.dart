import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../router/app_router.dart';

@RoutePage()
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        ListRoute(),
        MapOverviewRoute(),
        StatsRoute(),
        SettingsRoute(),
      ],
      transitionBuilder: (context, child, animation) =>
          FadeTransition(opacity: animation, child: child),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        final activeIndex = tabsRouter.activeIndex;
        final isWide = MediaQuery.sizeOf(context).width >= 600;
        final l = context.l10n;

        void navigate(int index) {
          tabsRouter.setActiveIndex(index);
        }

        return Scaffold(
          body: Row(
            children: [
              if (isWide)
                NavigationRail(
                  selectedIndex: activeIndex,
                  onDestinationSelected: navigate,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.list_outlined),
                      selectedIcon: const Icon(Icons.list),
                      label: Text(l.navOverview),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.map_outlined),
                      selectedIcon: const Icon(Icons.map),
                      label: Text(l.navMap),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.bar_chart_outlined),
                      selectedIcon: const Icon(Icons.bar_chart),
                      label: Text(l.navStats),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.settings_outlined),
                      selectedIcon: const Icon(Icons.settings),
                      label: Text(l.navSettings),
                    ),
                  ],
                ),
              if (isWide) const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  selectedIndex: activeIndex,
                  onDestinationSelected: navigate,
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.list_outlined),
                      selectedIcon: const Icon(Icons.list),
                      label: l.navOverview,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.map_outlined),
                      selectedIcon: const Icon(Icons.map),
                      label: l.navMap,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.bar_chart_outlined),
                      selectedIcon: const Icon(Icons.bar_chart),
                      label: l.navStats,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.settings_outlined),
                      selectedIcon: const Icon(Icons.settings),
                      label: l.navSettings,
                    ),
                  ],
                ),
        );
      },
    );
  }
}
