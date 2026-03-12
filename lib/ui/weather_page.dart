import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:as_promised_weather/ui/models.dart';
import 'package:as_promised_weather/ui/weather_screen.dart';
import 'package:as_promised_weather/cubit/weather_cubit.dart';
import 'package:as_promised_weather/cubit/weather_state.dart';
import 'package:as_promised_weather/data/repositories/weather_repository.dart';
import 'package:as_promised_weather/data/repositories/preferences_repository.dart';
import 'package:as_promised_weather/nav.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WeatherCubit(
        weatherRepository: WeatherRepository(),
        preferencesRepository: PreferencesRepository(),
      )..init(),
      child: const _WeatherView(),
    );
  }
}

class _WeatherView extends StatelessWidget {
  const _WeatherView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WeatherCubit, WeatherState>(
      listener: (context, state) {
        if (state.shouldNavigateToPermission) {
          context.go(AppRoutes.permission);
        }
      },
      builder: (context, state) {
        // If we don't have any weather yet, show a pure loading state.
        if (state.weather == null && !state.hasError) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.hasError && state.weather == null) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: _ErrorView(
                message: state.errorMessage ?? 'Something went wrong',
                onRetry: () => context.read<WeatherCubit>().load(),
              ),
            ),
          );
        }

        // While loading a new location (e.g. after changing city), avoid showing
        // the previous weather behind a spinner. Show a clean loading screen instead.
        if (state.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final weather = state.weather!;
        final cubit = context.read<WeatherCubit>();

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: WeatherScreen(
            onRefresh: () => cubit.refresh(),
            weather: weather,
            location: state.locationLabel,
            unit: state.tempUnit == TempUnit.c ? 'C' : 'F',
            windUnit: state.windUnit,
            pressureUnit: state.pressureUnit,
            onOpenSettings: () => _openSettings(context, state, cubit),
          ),
        );
      },
    );
  }

  void _openSettings(
    BuildContext context,
    WeatherState state,
    WeatherCubit cubit,
  ) {
    context.push(AppRoutes.settings, extra: {
      'unit': state.tempUnit == TempUnit.c ? 'C' : 'F',
      'windUnit': state.windUnit,
      'pressureUnit': state.pressureUnit,
      'currentLocation': state.locationLabel,
      'onUnitChange': (String newUnit) => cubit.setTempUnit(newUnit),
      'onWindUnitChange': (String w) => cubit.setWindUnit(w),
      'onPressureUnitChange': (String p) => cubit.setPressureUnit(p),
      'onSelectLocation': (String name, double lat, double lon) {
        final label = name.split(',').first.trim();
        cubit.saveLocationManual(lat, lon, label);
      },
      'onUseCurrentLocation': () => cubit.useCurrentLocation(),
      'creative': state.creative,
      'onCreativeChange': (bool v) => cubit.setCreativeMode(v),
    });
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.wifiOff, color: onSurface),
          const SizedBox(height: 12),
          Text(
            message,
            style: t.titleLarge?.copyWith(color: onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

