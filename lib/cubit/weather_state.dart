import 'package:equatable/equatable.dart';
import 'package:as_promised_weather/ui/models.dart';

enum WeatherStatus { initial, loading, loaded, failure }

/// [WeatherState] holds all UI-relevant state for the weather screen.
class WeatherState extends Equatable {
  const WeatherState({
    this.status = WeatherStatus.initial,
    this.weather,
    this.locationLabel = 'Locating…',
    this.tempUnit = TempUnit.c,
    this.windUnit = 'kmh',
    this.pressureUnit = 'mb',
    this.creative = false,
    this.errorMessage,
    this.shouldNavigateToPermission = false,
  });

  final WeatherStatus status;
  final WeatherData? weather;
  final String locationLabel;
  final TempUnit tempUnit;
  final String windUnit;
  final String pressureUnit;
  final bool creative;
  final String? errorMessage;

  /// When true, UI should navigate to permission/setup screen.
  final bool shouldNavigateToPermission;

  bool get isLoading => status == WeatherStatus.loading;
  bool get isLoaded => status == WeatherStatus.loaded && weather != null;
  bool get hasError => status == WeatherStatus.failure;

  WeatherState copyWith({
    WeatherStatus? status,
    WeatherData? weather,
    String? locationLabel,
    TempUnit? tempUnit,
    String? windUnit,
    String? pressureUnit,
    bool? creative,
    String? errorMessage,
    bool? shouldNavigateToPermission,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      locationLabel: locationLabel ?? this.locationLabel,
      tempUnit: tempUnit ?? this.tempUnit,
      windUnit: windUnit ?? this.windUnit,
      pressureUnit: pressureUnit ?? this.pressureUnit,
      creative: creative ?? this.creative,
      errorMessage: errorMessage ?? this.errorMessage,
      shouldNavigateToPermission:
          shouldNavigateToPermission ?? this.shouldNavigateToPermission,
    );
  }

  @override
  List<Object?> get props => [
        status,
        weather,
        locationLabel,
        tempUnit,
        windUnit,
        pressureUnit,
        creative,
        errorMessage,
        shouldNavigateToPermission,
      ];
}

