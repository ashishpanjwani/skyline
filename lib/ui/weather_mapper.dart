import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:as_promised_weather/ui/creative_statement_builder.dart';
import 'package:as_promised_weather/ui/models.dart';
import 'package:as_promised_weather/ui/weather_conditions.dart';

/// Pure mapping and weather-display business logic.
/// Converts raw API maps + preferences into [WeatherData].
class WeatherMapper {
  WeatherMapper({
    required this.tempUnit,
    required this.windUnit,
    required this.pressureUnit,
    required this.creativeMode,
    this.maxTitleWidth = 320,
  });

  final TempUnit tempUnit;
  final String windUnit;
  final String pressureUnit;
  final bool creativeMode;
  final double maxTitleWidth;

  int convertTemp(int f) {
    if (tempUnit == TempUnit.f) return f;
    return ((f - 32) * 5 / 9).round();
  }

  WeatherData mapToWeatherData(
    Map<String, dynamic> w,
    Map<String, dynamic> aqi,
  ) {
    final current = w['current'] as Map<String, dynamic>;
    final daily = w['daily'] as Map<String, dynamic>;
    final hourly = w['hourly'] as Map<String, dynamic>;
    final int offsetSec = (w['utc_offset_seconds'] as num?)?.toInt() ?? 0;

    int tempRaw = (current['temperature_2m'] as num?)?.round() ?? 68;
    int feelsRaw =
        (current['apparent_temperature'] as num?)?.round() ?? tempRaw;
    int windMph = (current['wind_speed_10m'] as num?)?.round() ?? 0;
    int humidity = (current['relative_humidity_2m'] as num?)?.round() ?? 0;
    int pressureHpa = (current['pressure_msl'] as num?)?.round() ?? 0;
    num visibilityMi = ((current['visibility'] as num?) ?? 0) / 1609.34;
    int isDay = (current['is_day'] as num?)?.toInt() ?? 1;
    bool isNight = isDay == 0;

    int windDisplay;
    switch (windUnit) {
      case 'kmh':
        windDisplay = (windMph * 1.60934).round();
        break;
      case 'ms':
        windDisplay = (windMph * 0.44704).round();
        break;
      case 'mph':
      default:
        windDisplay = windMph;
        break;
    }

    num pressureDisplay;
    switch (pressureUnit.toLowerCase()) {
      case 'inhg':
        pressureDisplay = pressureHpa * 0.0295299830714;
        break;
      case 'hpa':
        pressureDisplay = pressureHpa;
        break;
      case 'mb':
      default:
        pressureDisplay = pressureHpa;
        break;
    }

    final List timesH = (hourly['time'] as List?) ?? const [];
    final List tempsH = (hourly['temperature_2m'] as List?) ?? const [];
    final List wcodeH = (hourly['weather_code'] as List?) ?? const [];

    final List timesD = (daily['time'] as List?) ?? const [];
    final List maxD = (daily['temperature_2m_max'] as List?) ?? const [];
    final List minD = (daily['temperature_2m_min'] as List?) ?? const [];
    final List sunrise = (daily['sunrise'] as List?) ?? const [];
    final List sunset = (daily['sunset'] as List?) ?? const [];
    final List wcodeD = (daily['weather_code'] as List?) ??
        (daily['weathercode'] as List?) ??
        const [];

    int aqiVal = 0;
    String aqiLabel = '—';
    if (aqi.isNotEmpty) {
      try {
        final List aqiVals = (aqi['hourly']?['us_aqi'] as List?) ?? const [];
        if (aqiVals.isNotEmpty) {
          aqiVal = (aqiVals[0] as num?)?.round() ?? 0;
          aqiLabel = aqiLabelFromValue(aqiVal);
        }
      } catch (_) {}
    }

    final int codeNow = (current['weather_code'] as num?)?.toInt() ?? 0;
    final WeatherTemplate tpl = resolveTemplate(
      code: codeNow,
      isNight: isNight,
      tempF: tempRaw,
      windMph: windMph,
    );

    final WeatherStatement statement = creativeMode
        ? makeCreativeStatement(
            code: codeNow,
            isNight: isNight,
            tempF: tempRaw,
            humidity: humidity,
            windMph: windMph,
            visibilityMi: visibilityMi,
            offsetSec: offsetSec,
            fallback: tpl.statement,
          )
        : tpl.statement;

    final List<HourlyData> hourlyData = _buildHourly(
      timesH: timesH,
      tempsH: tempsH,
      wcodeH: wcodeH,
      offsetSec: offsetSec,
      tempRaw: tempRaw,
      isNight: isNight,
    );

    final List<DailyData> dailyData = _buildDaily(
      timesD: timesD,
      maxD: maxD,
      minD: minD,
      wcodeD: wcodeD,
      tempRaw: tempRaw,
    );

    final String sunriseStr =
        sunrise.isNotEmpty ? fmtHour(sunrise[0] as String? ?? '') : '--:--';
    final String sunsetStr =
        sunset.isNotEmpty ? fmtHour(sunset[0] as String? ?? '') : '--:--';

    return WeatherData(
      gradient: tpl.gradient,
      textColor: tpl.textColor,
      icon: tpl.icon,
      statement: statement,
      temperature: convertTemp(tempRaw),
      feelsLike: convertTemp(feelsRaw),
      high: convertTemp(
          (maxD.isNotEmpty ? (maxD[0] as num?)?.round() : null) ?? tempRaw),
      low: convertTemp(
          (minD.isNotEmpty ? (minD[0] as num?)?.round() : null) ?? tempRaw),
      tip: tpl.tip,
      details: WeatherDetails(
        humidity: humidity,
        windSpeed: windDisplay,
        uvIndex: 0,
        visibility: double.parse(visibilityMi.toStringAsFixed(1)),
        pressure: pressureDisplay,
        precipitation: (daily['precipitation_probability_max'] is List &&
                (daily['precipitation_probability_max'] as List).isNotEmpty)
            ? (((daily['precipitation_probability_max'] as List)[0] as num?)
                    ?.round() ??
                0)
            : 0,
        aqi: aqiVal,
        aqiLabel: aqiLabel,
        sunrise: sunriseStr,
        sunset: sunsetStr,
      ),
      hourly: hourlyData,
      daily: dailyData,
    );
  }

  List<HourlyData> _buildHourly({
    required List timesH,
    required List tempsH,
    required List wcodeH,
    required int offsetSec,
    required int tempRaw,
    required bool isNight,
  }) {
    final List<HourlyData> result = [];
    try {
      final nowLoc = nowInLocation(offsetSec);
      final String nowKey = isoKeyTopOfHour(nowLoc);

      int startIdx = -1;
      for (int i = 0; i < timesH.length; i++) {
        final String t = (timesH[i] as String?) ?? '';
        if (t == nowKey) {
          startIdx = i;
          break;
        }
      }
      if (startIdx == -1) {
        for (int i = 0; i < timesH.length; i++) {
          final String t = (timesH[i] as String?) ?? '';
          if (t.compareTo(nowKey) > 0) {
            startIdx = i > 0 ? i - 1 : 0;
            break;
          }
        }
        if (startIdx == -1) startIdx = 0;
      }

      for (int j = 0; j < 12; j++) {
        final idx = startIdx + j;
        if (idx >= timesH.length || idx >= tempsH.length || idx >= wcodeH.length) {
          break;
        }
        final String t = (timesH[idx] as String?) ?? '';
        final int tf = (tempsH[idx] as num?)?.round() ?? tempRaw;
        final int c = (wcodeH[idx] as num?)?.toInt() ?? 0;
        final String label = j == 0 ? 'Now' : fmtHourShort(t);
        result.add(HourlyData(
          time: label,
          temp: convertTemp(tf),
          icon: iconFromCode(c, isNight),
        ));
      }
    } catch (_) {}
    return result;
  }

  List<DailyData> _buildDaily({
    required List timesD,
    required List maxD,
    required List minD,
    required List wcodeD,
    required int tempRaw,
  }) {
    final List<DailyData> result = [];
    for (int i = 0; i < timesD.length && i < 7; i++) {
      final String day = weekday(timesD[i] as String? ?? '');
      final int hi = (maxD[i] as num?)?.round() ?? tempRaw;
      final int lo = (minD[i] as num?)?.round() ?? tempRaw;
      final int code =
          (i < wcodeD.length ? (wcodeD[i] as num?)?.toInt() : null) ?? 3;
      result.add(DailyData(
        day: day,
        high: convertTemp(hi),
        low: convertTemp(lo),
        icon: iconFromCode(code, false),
      ));
    }
    return result;
  }

  static String aqiLabelFromValue(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy (SG)';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  static String fmtHour(String iso) {
    if (iso.isEmpty) return '--:--';
    try {
      final dt = DateTime.parse(iso);
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final mm = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$mm$ampm';
    } catch (_) {
      return iso;
    }
  }

  static String fmtHourShort(String iso) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h $ampm';
    } catch (_) {
      return iso;
    }
  }

  static String weekday(String iso) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return names[dt.weekday % 7];
    } catch (_) {
      return '';
    }
  }

  static DateTime nowInLocation(int offsetSeconds) =>
      DateTime.now().toUtc().add(Duration(seconds: offsetSeconds));

  static String isoKeyTopOfHour(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    return '$y-$m-$d${'T'}$h:00';
  }

  static IconData iconFromCode(int code, bool isNight) {
    if ([0].contains(code)) return isNight ? LucideIcons.moon : LucideIcons.sun;
    if ([1, 2].contains(code)) {
      return isNight ? LucideIcons.cloudMoon : LucideIcons.cloudSun;
    }
    if ([3].contains(code)) return LucideIcons.cloud;
    if ([45, 48].contains(code)) return LucideIcons.cloudFog;
    if ([51, 53, 55, 56, 57].contains(code)) return LucideIcons.cloudDrizzle;
    if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code)) {
      return LucideIcons.cloudRain;
    }
    if ([71, 73, 75, 77, 85, 86].contains(code)) return LucideIcons.cloudSnow;
    if ([95, 96, 99].contains(code)) return LucideIcons.zap;
    return LucideIcons.cloud;
  }

  WeatherStatement makeCreativeStatement({
    required int code,
    required bool isNight,
    required int tempF,
    required int humidity,
    required int windMph,
    required num visibilityMi,
    required int offsetSec,
    required WeatherStatement fallback,
  }) {
    return CreativeStatementBuilder(maxTitleWidth: maxTitleWidth).build(
      code: code,
      isNight: isNight,
      tempF: tempF,
      humidity: humidity,
      windMph: windMph,
      visibilityMi: visibilityMi,
      offsetSec: offsetSec,
      fallback: fallback,
    );
  }
}

