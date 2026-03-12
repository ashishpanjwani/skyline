import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:as_promised_weather/data/repositories/weather_repository.dart';
import 'package:as_promised_weather/data/repositories/preferences_repository.dart';
import 'package:as_promised_weather/ui/models.dart';
import 'package:as_promised_weather/ui/weather_mapper.dart';
import 'package:as_promised_weather/cubit/weather_state.dart';
import 'package:as_promised_weather/services/location_service.dart';
import 'package:as_promised_weather/services/widget_service.dart';

const bool kForceBengaluru = false;
const double kBlrLat = 12.9716;
const double kBlrLon = 77.5946;

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit({
    required WeatherRepository weatherRepository,
    required PreferencesRepository preferencesRepository,
    LocationService? locationService,
  })  : _weatherRepository = weatherRepository,
        _preferencesRepository = preferencesRepository,
        _locationService = locationService ?? LocationService(),
        super(const WeatherState());

  final WeatherRepository _weatherRepository;
  final PreferencesRepository _preferencesRepository;
  final LocationService _locationService;

  /// Initial load: read prefs, then load weather (manual location or GPS).
  Future<void> init() async {
    await _loadPreferences();
    await load();
  }

  /// Load preferences and update state (units, creative).
  Future<void> _loadPreferences() async {
    try {
      final tempUnitStr = await _preferencesRepository.getTempUnit();
      final windUnit = await _preferencesRepository.getWindUnit();
      final pressureUnit = await _preferencesRepository.getPressureUnit();
      final creative = await _preferencesRepository.getCreativeMode();
      final tempUnit = tempUnitStr == 'F' ? TempUnit.f : TempUnit.c;
      emit(state.copyWith(
        tempUnit: tempUnit,
        windUnit: windUnit,
        pressureUnit: pressureUnit,
        creative: creative,
      ));
    } catch (e) {
      debugPrint('WeatherCubit: failed to read prefs: $e');
    }
  }

  /// Full load: decide location (manual / Bengaluru / GPS), fetch weather, map, save, update widget.
  Future<void> load({bool isRefresh = false}) async {
    // Always emit loading so UI can show a spinner overlay while keeping old weather visible.
    emit(state.copyWith(
      status: WeatherStatus.loading,
      errorMessage: null,
      shouldNavigateToPermission: false,
    ));

    try {
      final saved = await _preferencesRepository.getSavedLocationIfManual();
      if (saved != null) {
        final (lat, lon, label) = saved;
        final preferredLabel =
            label != null && label.isNotEmpty ? label.split(',').first.trim() : null;
        await _loadForLocation(
          lat,
          lon,
          preferredLabel: (preferredLabel == null || preferredLabel.isEmpty)
              ? null
              : preferredLabel,
          isRefresh: isRefresh,
        );
        return;
      }

      if (kForceBengaluru) {
        await _loadForLocation(kBlrLat, kBlrLon,
            preferredLabel: 'Bengaluru', isRefresh: isRefresh);
        return;
      }

      final loc =
          await _locationService.getCurrentLocationWithName(allowIpFallback: false);
      if (loc == null) {
        emit(state.copyWith(
          status: WeatherStatus.failure,
          shouldNavigateToPermission: true,
        ));
        return;
      }

      String? label = loc.name;
      if (label == 'Current Location' || label == 'Your Area') label = null;
      await _loadForLocation(loc.lat, loc.lon,
          preferredLabel: label, isRefresh: isRefresh);
    } catch (e) {
      debugPrint('WeatherCubit load error: $e');
      if (state.weather == null) {
        emit(state.copyWith(
          status: WeatherStatus.failure,
          shouldNavigateToPermission: true,
        ));
        return;
      }
      if (e is PermissionDeniedException || e is LocationServiceDisabledException) {
        emit(state.copyWith(
          status: WeatherStatus.failure,
          shouldNavigateToPermission: true,
        ));
        return;
      }
      emit(state.copyWith(
        status: WeatherStatus.failure,
        errorMessage: 'Failed to load weather.',
      ));
    }
  }

  Future<void> _loadForLocation(
    double lat,
    double lon, {
    String? preferredLabel,
    bool isRefresh = false,
  }) async {
    final nextLabel = (preferredLabel != null && preferredLabel.isNotEmpty)
        ? preferredLabel
        : state.locationLabel;
    emit(state.copyWith(
      status: WeatherStatus.loading,
      errorMessage: null,
      locationLabel: nextLabel,
    ));

    try {
      final futures = await Future.wait([
        _weatherRepository.fetchWeather(lat, lon),
        _weatherRepository.fetchAqi(lat, lon),
      ]);
      final rawWeather = futures[0];
      final rawAqi = futures[1];

      String locationLabel = state.locationLabel;
      if (preferredLabel == null) {
        final name = await _locationService.getNameFromCoordinates(lat, lon);
        locationLabel = name ?? 'Current Location';
      }

      final mapper = WeatherMapper(
        tempUnit: state.tempUnit,
        windUnit: state.windUnit,
        pressureUnit: state.pressureUnit,
        creativeMode: state.creative,
      );
      final weather = mapper.mapToWeatherData(rawWeather, rawAqi);

      await _preferencesRepository.saveLastLocation(lat, lon, locationLabel);
      await WidgetService.updateWidget();

      emit(state.copyWith(
        status: WeatherStatus.loaded,
        weather: weather,
        locationLabel: locationLabel,
        errorMessage: null,
      ));
    } catch (e) {
      debugPrint('Load for location failed: $e');
      emit(state.copyWith(
        status: WeatherStatus.failure,
        errorMessage: 'Failed to load weather.',
      ));
    }
  }

  /// Refresh: reload weather for current location (manual or last).
  Future<void> refresh() => load(isRefresh: true);

  /// Set temp unit, persist, and rebuild weather model if we have data.
  Future<void> setTempUnit(String unit) async {
    await _preferencesRepository.setTempUnit(unit);
    final tempUnit = unit == 'F' ? TempUnit.f : TempUnit.c;
    emit(state.copyWith(tempUnit: tempUnit));
    await _rebuildWeatherIfPossible();
  }

  Future<void> setWindUnit(String unit) async {
    await _preferencesRepository.setWindUnit(unit);
    emit(state.copyWith(windUnit: unit));
    await _rebuildWeatherIfPossible();
  }

  Future<void> setPressureUnit(String unit) async {
    await _preferencesRepository.setPressureUnit(unit);
    emit(state.copyWith(pressureUnit: unit));
    await _rebuildWeatherIfPossible();
  }

  Future<void> setCreativeMode(bool value) async {
    await _preferencesRepository.setCreativeMode(value);
    emit(state.copyWith(creative: value));
    await _rebuildWeatherIfPossible();
  }

  /// Save manual location and load weather for it.
  Future<void> saveLocationManual(double lat, double lon, String label) async {
    final trimmedLabel = label.split(',').first.trim();
    await _preferencesRepository.saveLocationManual(lat, lon, trimmedLabel);
    await _loadForLocation(lat, lon, preferredLabel: trimmedLabel);
  }

  /// Switch to "current location" mode and reload using GPS.
  Future<void> useCurrentLocation() async {
    await _preferencesRepository.setLocationModeCurrent();
    await load();
  }

  /// Rebuild [WeatherData] after unit/creative change by refetching for last location.
  Future<void> _rebuildWeatherIfPossible() async {
    if (state.weather == null) return;
    final saved = await _preferencesRepository.getSavedLocationIfManual();
    if (saved != null) {
      await _loadForLocation(
        saved.$1,
        saved.$2,
        preferredLabel: saved.$3,
        isRefresh: true,
      );
      return;
    }
    final last = await _preferencesRepository.getLastLocation();
    if (last != null) {
      await _loadForLocation(
        last.$1,
        last.$2,
        preferredLabel: last.$3,
        isRefresh: true,
      );
    }
  }
}

