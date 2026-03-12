import 'dart:convert';
import 'package:http/http.dart' as http;

/// Fetches weather and AQI data from remote APIs.
class WeatherRemoteDataSource {
  WeatherRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Open-Meteo forecast API. Returns raw JSON map.
  Future<Map<String, dynamic>> getForecast(double lat, double lon) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'timezone': 'auto',
      'temperature_unit': 'fahrenheit',
      'wind_speed_unit': 'mph',
      'precipitation_unit': 'inch',
      'current':
          'temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m,pressure_msl,visibility,is_day',
      'hourly':
          'temperature_2m,apparent_temperature,relative_humidity_2m,weather_code',
      'daily':
          'temperature_2m_max,temperature_2m_min,sunrise,sunset,apparent_temperature_max,apparent_temperature_min,precipitation_probability_max,weather_code',
    });
    final res = await _client.get(uri);
    if (res.statusCode != 200) throw Exception('Weather API ${res.statusCode}');
    return json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  /// Open-Meteo air quality API. Returns empty map on error.
  Future<Map<String, dynamic>> getAqi(double lat, double lon) async {
    try {
      final uri = Uri.https('air-quality-api.open-meteo.com', '/v1/air-quality', {
        'latitude': lat.toString(),
        'longitude': lon.toString(),
        'timezone': 'auto',
        'hourly': 'us_aqi',
      });
      final res = await _client.get(uri);
      if (res.statusCode != 200) throw Exception('AQI API ${res.statusCode}');
      return json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
