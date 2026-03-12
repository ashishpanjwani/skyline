import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:as_promised_weather/core/constants/pref_keys.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:as_promised_weather/ui/widgets/weather_widgets.dart';
import 'package:as_promised_weather/ui/weather_conditions.dart';

const String kWidgetName = 'WeatherWidgetProvider';
const String kWidgetKey = 'widget_image';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await WidgetService.updateWidget();
      return Future.value(true);
    } catch (e) {
      debugPrint('Widget update failed: $e');
      return Future.value(false);
    }
  });
}

class WidgetService {
  static Future<void> initialize() async {
    // Widgets are Android-only and not supported on web. Skip safely.
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      debugPrint(
          'WidgetService.initialize: skipped (platform=${kIsWeb ? 'web' : defaultTargetPlatform.name})');
      return;
    }
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await Workmanager().registerPeriodicTask(
      'weather_widget_update',
      'updateWeatherWidget',
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );

    await updateWidget();
  }

  static Future<void> updateWidget() async {
    // Guard against unsupported platforms
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      debugPrint(
          'WidgetService.updateWidget: skipped (platform=${kIsWeb ? 'web' : defaultTargetPlatform.name})');
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      double? lat;
      double? lon;
      String locationName = 'Current Location';

      // 1. Get Location
      final mode = prefs.getString(PrefKeys.locMode);
      if (mode == 'manual') {
        lat = prefs.getDouble(PrefKeys.locLat);
        lon = prefs.getDouble(PrefKeys.locLon);
        locationName = prefs.getString(PrefKeys.locLabel) ?? locationName;
      } else {
        lat = prefs.getDouble(PrefKeys.lastLat);
        lon = prefs.getDouble(PrefKeys.lastLon);
        locationName = prefs.getString(PrefKeys.lastLocName) ?? locationName;
      }
      // if (lat == null || lon == null) {
      //   debugPrint('No location data for widget');
      //   return;
      // }
      lat ??= 28.6139;
      lon ??= 77.2090;
      // locationName ??= "Delhi";

      // 2. Fetch Weather
      final weatherData = await _fetchWeather(lat, lon);

      final current = weatherData['current'];
      final daily = weatherData['daily'];

      final temp = (current['temperature_2m'] as num).round();
      final code = (current['weather_code'] as num).toInt();
      final isDay = (current['is_day'] as num).toInt() == 1;

      final high = (daily['temperature_2m_max'][0] as num).round();
      final low = (daily['temperature_2m_min'][0] as num).round();
      final windMph = (current['wind_speed_10m'] as num).round();

      // final conditionText = _conditionText(code);
      // final icon = _iconFromCode(code, !isDay);
      // final gradient = _getGradient(code, !isDay);
      // final textColor =
      //     (!isDay || [95, 96, 99].contains(code)) ? Colors.white : Colors.black;

      final template = resolveTemplate(
        code: code,
        isNight: !isDay,
        tempF: temp,
        windMph: windMph, // optional if you want to pass wind
      );

      final gradient = template.gradient;
      final icon = template.icon;
      final textColor = template.textColor;
      final conditionText = _conditionText(code);

      final data = WeatherWidgetData(
        id: 0,
        type: 'square',
        gradient: gradient,
        textColor: textColor,
        icon: icon,
        temperature: _convertTemp(temp, prefs),
        location: locationName.split(',').first, // Shorten
        condition: conditionText,
        high: _convertTemp(high, prefs),
        low: _convertTemp(low, prefs),
      );

      // 3. Render Widget
      // Note: background rendering might fail on some Android versions if Workmanager runs without UI.
      // But we attempt it.
      final path = await HomeWidget.renderFlutterWidget(
        SquareWidget(data: data),
        key: 'weather_widget_preview',
        logicalSize: const Size(250, 250),
        pixelRatio: 2.0,
      );

      if (path != null) {
        await HomeWidget.saveWidgetData<String>(kWidgetKey, path);
        await HomeWidget.updateWidget(
          name: kWidgetName,
          androidName: kWidgetName,
          iOSName: kWidgetName,
        );
        debugPrint('Widget updated successfully');
      }
    } catch (e) {
      debugPrint('Error updating widget: $e');
      rethrow;
    }
  }

  static int _convertTemp(int f, SharedPreferences prefs) {
    final unit = prefs.getString(PrefKeys.tempUnit);
    if (unit == 'F') return f;
    return ((f - 32) * 5 / 9).round();
  }

  static Future<Map<String, dynamic>> _fetchWeather(
      double lat, double lon) async {
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
      // Add weather_code to daily so we can map icons per-day
      'daily':
          'temperature_2m_max,temperature_2m_min,sunrise,sunset,apparent_temperature_max,apparent_temperature_min,precipitation_probability_max,weather_code',
    });
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Weather API ${res.statusCode}');
    return json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static String _conditionText(int code) {
    if (code == 0) return 'Clear';
    if ([1, 2, 3].contains(code)) return 'Cloudy';
    if ([45, 48].contains(code)) return 'Fog';
    if ([51, 53, 55, 56, 57].contains(code)) return 'Drizzle';
    if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code)) return 'Rain';
    if ([71, 73, 75, 77, 85, 86].contains(code)) return 'Snow';
    if ([95, 96, 99].contains(code)) return 'Storm';
    return 'Unknown';
  }

  static IconData _iconFromCode(int code, bool isNight) {
    if ([0].contains(code)) return isNight ? LucideIcons.moon : LucideIcons.sun;
    if ([1, 2].contains(code))
      return isNight ? LucideIcons.cloudMoon : LucideIcons.cloudSun;
    if ([3].contains(code)) return LucideIcons.cloud;
    if ([45, 48].contains(code)) return LucideIcons.cloudFog;
    if ([51, 53, 55, 56, 57].contains(code)) return LucideIcons.cloudDrizzle;
    if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code))
      return LucideIcons.cloudRain;
    if ([71, 73, 75, 77, 85, 86].contains(code)) return LucideIcons.cloudSnow;
    if ([95, 96, 99].contains(code)) return LucideIcons.zap;
    return LucideIcons.cloud;
  }

  static List<Color> _getGradient(int code, bool isNight) {
    if (isNight)
      return [const Color(0xFF0F172A), const Color(0xFF1E1B4B), Colors.black];
    if ([95, 96, 99].contains(code))
      return [
        const Color(0xFF334155),
        const Color(0xFF475569),
        const Color(0xFF64748B)
      ]; // Storm
    if ([0].contains(code))
      return [
        const Color(0xFF60A5FA),
        const Color(0xFF3B82F6),
        const Color(0xFF2563EB)
      ]; // Clear
    if ([61, 63, 65, 80, 81, 82].contains(code))
      return [
        const Color(0xFF60A5FA),
        const Color(0xFF93C5FD),
        const Color(0xFFBFDBFE)
      ]; // Rain
    // Default
    return [
      const Color(0xFF60A5FA),
      const Color(0xFF93C5FD),
      const Color(0xFFBFDBFE)
    ];
  }
}
