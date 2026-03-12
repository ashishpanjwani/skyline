import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:as_promised_weather/ui/weather_page.dart';
import 'package:as_promised_weather/ui/settings_page.dart';
import 'package:as_promised_weather/ui/permission_page.dart';

/// GoRouter configuration for app navigation
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: WeatherPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.weather,
        name: 'weather',
        redirect: (context, state) => AppRoutes.home,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: WeatherPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) {
          final extra = (state.extra as Map?) ?? {};
          final String unit = (extra['unit'] as String?) ?? 'C';
          final String windUnit = (extra['windUnit'] as String?) ?? 'kmh';
          final String pressureUnit = (extra['pressureUnit'] as String?) ?? 'mb';
          final String currentLocation = (extra['currentLocation'] as String?) ?? '';
          final void Function(String)? onUnitChange = extra['onUnitChange'] as void Function(String)?;
          final void Function(String, double, double)? onSelectLocation = extra['onSelectLocation'] as void Function(String, double, double)?;
          final VoidCallback? onUseCurrentLocation = extra['onUseCurrentLocation'] as VoidCallback?;
          final void Function(String)? onWindUnitChange = extra['onWindUnitChange'] as void Function(String)?;
          final void Function(String)? onPressureUnitChange = extra['onPressureUnitChange'] as void Function(String)?;
          final bool creative = (extra['creative'] as bool?) ?? false;
          final void Function(bool)? onCreativeChange = extra['onCreativeChange'] as void Function(bool)?;
          return NoTransitionPage(
            child: SettingsPage(
              unit: unit,
              onUnitChange: onUnitChange ?? (_) {},
              onSelectLocation: onSelectLocation ?? (_, __, ___) {},
              currentLocationLabel: currentLocation,
              onUseCurrentLocation: onUseCurrentLocation,
              windUnit: windUnit,
              pressureUnit: pressureUnit,
              onWindUnitChange: onWindUnitChange ?? (_) {},
              onPressureUnitChange: onPressureUnitChange ?? (_) {},
              creativeEnabled: creative,
              onCreativeChange: onCreativeChange ?? (_) {},
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.changeCity,
        name: 'change_city',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: ChangeCityPage()),
      ),
      GoRoute(
        path: AppRoutes.permission,
        name: 'permission',
        pageBuilder: (context, state) => const NoTransitionPage(child: PermissionPage()),
      ),
    ],
  );
}

/// Route path constants
class AppRouterRoutes {
  // Deprecated usage of AppRouterRoutes if any, relying on AppRoutes class below
}

class AppRoutes {
  static const String home = '/';
  static const String weather = '/weather';
  static const String settings = '/settings';
  static const String changeCity = '/change-city';
  static const String permission = '/permission';
}
