import 'package:flutter/material.dart';

/// Temperature unit
enum TempUnit { c, f }

/// Statement text configuration
class WeatherStatement {
  final String line1;
  final String? line1Style; // 'outline' or null
  final String line2;
  final String? line2Style;
  final String line3;
  final String? line3Style;
  final String? line4;

  const WeatherStatement({
    required this.line1,
    this.line1Style,
    required this.line2,
    this.line2Style,
    required this.line3,
    this.line3Style,
    this.line4,
  });
}

/// Detailed weather metrics
class WeatherDetails {
  final int humidity;
  final int windSpeed;
  final int uvIndex;
  final num visibility;
  final num pressure;
  final int precipitation;
  final int aqi;
  final String aqiLabel;
  final String sunrise;
  final String sunset;

  const WeatherDetails({
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
    required this.visibility,
    required this.pressure,
    required this.precipitation,
    required this.aqi,
    required this.aqiLabel,
    required this.sunrise,
    required this.sunset,
  });
}

/// Hourly forecast item
class HourlyData {
  final String time;
  final int temp;
  final IconData icon;

  const HourlyData({required this.time, required this.temp, required this.icon});
}

/// Daily forecast item
class DailyData {
  final String day;
  final int high;
  final int low;
  final IconData icon;

  const DailyData({
    required this.day,
    required this.high,
    required this.low,
    required this.icon,
  });
}

/// Main data model for the WeatherScreen
class WeatherData {
  final List<Color> gradient;
  final Color textColor;
  final IconData icon;
  final WeatherStatement statement;
  final int temperature;
  final int feelsLike;
  final int high;
  final int low;
  final String tip;
  final WeatherDetails details;
  final List<HourlyData> hourly;
  final List<DailyData> daily;

  const WeatherData({
    required this.gradient,
    required this.textColor,
    required this.icon,
    required this.statement,
    required this.temperature,
    required this.feelsLike,
    required this.high,
    required this.low,
    required this.tip,
    required this.details,
    required this.hourly,
    required this.daily,
  });
}

