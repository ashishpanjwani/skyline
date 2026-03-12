import 'package:as_promised_weather/data/datasources/weather_remote_datasource.dart';

/// Repository for weather and AQI data. Delegates network calls to data source.
class WeatherRepository {
  WeatherRepository({WeatherRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? WeatherRemoteDataSource();

  final WeatherRemoteDataSource _dataSource;

  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) =>
      _dataSource.getForecast(lat, lon);

  Future<Map<String, dynamic>> fetchAqi(double lat, double lon) =>
      _dataSource.getAqi(lat, lon);
}
