import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'models.dart';

// Tailwind-like palette approximations using Material swatches
class TW {
  static Color blue(int shade) => Colors.blue[shade] ?? Colors.blue;
  static Color sky(int shade) => Colors.lightBlue[shade] ?? Colors.lightBlue;
  static Color cyan(int shade) => Colors.cyan[shade] ?? Colors.cyan;
  static Color teal(int shade) => Colors.teal[shade] ?? Colors.teal;
  static Color indigo(int shade) => Colors.indigo[shade] ?? Colors.indigo;
  static Color slate(int shade) => Colors.blueGrey[shade] ?? Colors.blueGrey;
  static Color gray(int shade) => Colors.grey[shade] ?? Colors.grey;
  static Color orange(int shade) => Colors.orange[shade] ?? Colors.orange;
  static Color yellow(int shade) => Colors.yellow[shade] ?? Colors.yellow;
  static Color purple(int shade) => Colors.purple[shade] ?? Colors.purple;
  static Color pink(int shade) => Colors.pink[shade] ?? Colors.pink;
  static Color amber(int shade) => Colors.amber[shade] ?? Colors.amber;
  static Color black() => Colors.black;
  static Color white() => Colors.white;
}

List<Color> g(List<Color> colors) => colors;

final List<WeatherData> weatherConditions = [
  WeatherData(
    gradient: g([TW.blue(400), TW.blue(300), TW.blue(200)]),
    textColor: Colors.white,
    icon: LucideIcons.cloudRain,
    statement: const WeatherStatement(
        line1: "It's",
        line2: 'pouring',
        line3: 'rain',
        line3Style: 'outline',
        line4: 'now.'),
    temperature: 58,
    feelsLike: 55,
    high: 62,
    low: 54,
    tip: 'Grab an umbrella before heading out',
    details: const WeatherDetails(
        humidity: 85,
        windSpeed: 15,
        uvIndex: 2,
        visibility: 6,
        pressure: 1012,
        precipitation: 75,
        aqi: 42,
        aqiLabel: 'Good',
        sunrise: '6:45 AM',
        sunset: '7:30 PM'),
    hourly: const [
      HourlyData(time: 'Now', temp: 58, icon: LucideIcons.cloudRain),
      HourlyData(time: '5PM', temp: 57, icon: LucideIcons.cloudRain),
      HourlyData(time: '6PM', temp: 56, icon: LucideIcons.cloud),
      HourlyData(time: '7PM', temp: 55, icon: LucideIcons.cloud),
      HourlyData(time: '8PM', temp: 54, icon: LucideIcons.cloud),
      HourlyData(time: '9PM', temp: 53, icon: LucideIcons.moon),
    ],
    daily: const [
      DailyData(day: 'Mon', high: 62, low: 54, icon: LucideIcons.cloudRain),
      DailyData(day: 'Tue', high: 65, low: 56, icon: LucideIcons.cloud),
      DailyData(day: 'Wed', high: 70, low: 58, icon: LucideIcons.sun),
      DailyData(day: 'Thu', high: 68, low: 60, icon: LucideIcons.cloudSun),
      DailyData(day: 'Fri', high: 64, low: 55, icon: LucideIcons.cloudRain),
    ],
  ),
  WeatherData(
    gradient: g([TW.sky(300), TW.blue(200), TW.cyan(200)]),
    textColor: TW.black(),
    icon: LucideIcons.sun,
    statement: const WeatherStatement(
        line1: 'Perfect',
        line1Style: 'outline',
        line2: 'blue',
        line3: 'sky',
        line4: 'day.'),
    temperature: 72,
    feelsLike: 72,
    high: 76,
    low: 62,
    tip: "It's a beautiful day outside",
    details: const WeatherDetails(
        humidity: 45,
        windSpeed: 6,
        uvIndex: 7,
        visibility: 10,
        pressure: 1015,
        precipitation: 0,
        aqi: 25,
        aqiLabel: 'Good',
        sunrise: '6:30 AM',
        sunset: '7:45 PM'),
    hourly: const [
      HourlyData(time: 'Now', temp: 72, icon: LucideIcons.sun),
      HourlyData(time: '3PM', temp: 74, icon: LucideIcons.sun),
      HourlyData(time: '4PM', temp: 76, icon: LucideIcons.sun),
      HourlyData(time: '5PM', temp: 75, icon: LucideIcons.sun),
      HourlyData(time: '6PM', temp: 73, icon: LucideIcons.cloudSun),
      HourlyData(time: '7PM', temp: 70, icon: LucideIcons.cloudSun),
    ],
    daily: const [
      DailyData(day: 'Mon', high: 76, low: 62, icon: LucideIcons.sun),
      DailyData(day: 'Tue', high: 78, low: 64, icon: LucideIcons.sun),
      DailyData(day: 'Wed', high: 80, low: 66, icon: LucideIcons.sun),
      DailyData(day: 'Thu', high: 77, low: 63, icon: LucideIcons.sun),
      DailyData(day: 'Fri', high: 75, low: 61, icon: LucideIcons.sun),
    ],
  ),
];

