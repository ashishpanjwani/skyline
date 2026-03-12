import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'models.dart';

// Tailwind Color Palette Approximation
class TWColors {
  static const blue400 = Color(0xFF60A5FA);
  static const blue300 = Color(0xFF93C5FD);
  static const blue200 = Color(0xFFBFDBFE);
  static const blue100 = Color(0xFFDBEAFE);

  static const sky300 = Color(0xFF7DD3FC);
  static const cyan200 = Color(0xFFA5F3FC);

  static const orange400 = Color(0xFFFB923C);
  static const orange300 = Color(0xFFFDBA74);
  static const orange200 = Color(0xFFFED7AA);

  static const yellow200 = Color(0xFFFEF08A);
  static const yellow100 = Color(0xFFFEF9C3);

  static const gray800 = Color(0xFF1F2937);
  static const gray600 = Color(0xFF4B5563);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray100 = Color(0xFFF3F4F6);

  static const slate950 = Color(0xFF020617);
  static const slate900 = Color(0xFF0F172A);
  static const slate800 = Color(0xFF1E293B);
  static const slate700 = Color(0xFF334155);
  static const slate200 = Color(0xFFE2E8F0);

  static const indigo950 = Color(0xFF1E1B4B);
  static const indigo900 = Color(0xFF312E81);
  static const indigo800 = Color(0xFF3730A3);
  static const indigo200 = Color(0xFFC7D2FE);

  static const purple900 = Color(0xFF581C87);
  static const purple800 = Color(0xFF6B21A8);
  static const purple500 = Color(0xFFA855F7);
  static const purple400 = Color(0xFFC084FC);
  static const purple300 = Color(0xFFD8B4FE);
  static const purple200 = Color(0xFFE9D5FF);

  static const pink400 = Color(0xFFF472B6);
  static const pink200 = Color(0xFFFBCFE8);

  static const teal200 = Color(0xFF99F6E4);

  static const amber200 = Color(0xFFFDE68A);

  static const blue900 = Color(0xFF1E3A8A);
  static const blue950 = Color(0xFF172554);
}

class WeatherTemplate {
  final int id;
  final List<Color> gradient;
  final Color textColor;
  final IconData icon;
  final WeatherStatement statement;
  final String tip;

  const WeatherTemplate({
    required this.id,
    required this.gradient,
    required this.textColor,
    required this.icon,
    required this.statement,
    required this.tip,
  });
}

// Exact mapping from the React code
final List<WeatherTemplate> weatherTemplates = [
  // 1. Rain
  WeatherTemplate(
    id: 1,
    gradient: [TWColors.blue400, TWColors.blue300, TWColors.blue200],
    textColor: TWColors.gray800,
    icon: LucideIcons.cloudRain,
    statement: const WeatherStatement(
      line1: "It's",
      line2: 'fucking',
      line3: 'raining',
      line3Style: 'outline',
      line4: 'now.',
    ),
    tip: 'Grab an umbrella before heading out',
  ),

  // 2. Perfect Blue Sky
  WeatherTemplate(
    id: 2,
    gradient: [TWColors.sky300, TWColors.blue200, TWColors.cyan200],
    textColor: TWColors.gray800,
    icon: LucideIcons.sun,
    statement: const WeatherStatement(
      line1: 'Perfect',
      line1Style: 'outline',
      line2: 'blue',
      line3: 'sky',
      line4: 'day.',
    ),
    tip: "It's a beautiful day outside",
  ),

  // 3. Hot
  WeatherTemplate(
    id: 3,
    gradient: [TWColors.orange300, TWColors.yellow200, TWColors.orange200],
    textColor: TWColors.gray800,
    icon: LucideIcons.sun,
    statement: const WeatherStatement(
      line1: "It's",
      line2: 'too',
      line2Style: 'outline',
      line3: 'damn',
      line4: 'hot.',
    ),
    tip: 'Stay hydrated and wear sunscreen',
  ),

  // 4. Cloudy
  WeatherTemplate(
    id: 4,
    gradient: [TWColors.gray300, TWColors.slate200, TWColors.gray200],
    textColor: TWColors.gray800,
    icon: LucideIcons.cloud,
    statement: const WeatherStatement(
      line1: 'So',
      line2: 'cloudy',
      line2Style: 'outline',
      line3: 'right',
      line4: 'now.',
    ),
    tip: 'Overcast skies all day long',
  ),

  // 5. Partly Cloudy
  WeatherTemplate(
    id: 5,
    gradient: [TWColors.blue300, TWColors.indigo200, TWColors.purple200],
    textColor: TWColors.gray800,
    icon: LucideIcons.cloudSun,
    statement: const WeatherStatement(
      line1: 'Partly',
      line1Style: 'outline',
      line2: 'cloudy',
      line3: 'vibes',
      line4: 'today.',
    ),
    tip: 'Mix of sun and clouds expected',
  ),

  // 6. Freezing
  WeatherTemplate(
    id: 6,
    gradient: [TWColors.purple400, TWColors.purple300, TWColors.pink200],
    textColor: TWColors.gray800,
    icon: LucideIcons.cloud,
    statement: const WeatherStatement(
      line1: "It's",
      line2: 'freezing',
      line2Style: 'outline',
      line3: 'out',
      line4: 'there.',
    ),
    tip: 'Layer up and stay warm',
  ),

  // 7. Clear Night
  WeatherTemplate(
    id: 7,
    gradient: [TWColors.slate700, TWColors.purple900, TWColors.indigo900],
    textColor: Colors.white,
    icon: LucideIcons.moon,
    statement: const WeatherStatement(
      line1: 'Clear',
      line2: 'night',
      line2Style: 'outline',
      line3: 'sky',
      line4: 'tonight.',
    ),
    tip: 'Perfect night for stargazing',
  ),

  // 8. Partly Cloudy Night
  WeatherTemplate(
    id: 8,
    gradient: [TWColors.indigo800, TWColors.slate700, TWColors.gray800],
    textColor: Colors.white,
    icon: LucideIcons.cloudMoon,
    statement: const WeatherStatement(
      line1: 'Partly',
      line2: 'cloudy',
      line2Style: 'outline',
      line3: 'night',
      line4: 'ahead.',
    ),
    tip: 'Clouds drifting across the moon',
  ),

  // 9. Cloudy Night
  WeatherTemplate(
    id: 9,
    gradient: [TWColors.slate800, TWColors.blue900, TWColors.slate900],
    textColor: Colors.white,
    icon: LucideIcons.cloud,
    statement: const WeatherStatement(
      line1: 'Cloudy',
      line1Style: 'outline',
      line2: 'all',
      line3: 'night',
      line4: 'long.',
    ),
    tip: "Can't see any stars tonight",
  ),

  // 10. Thunder
  WeatherTemplate(
    id: 10,
    gradient: [TWColors.gray600, TWColors.purple800, TWColors.gray800],
    textColor: Colors.white,
    icon: LucideIcons.zap,
    statement: const WeatherStatement(
      line1: 'Thunder',
      line1Style: 'outline',
      line2: 'is',
      line3: 'rolling',
      line4: 'in.',
    ),
    tip: 'Stay indoors and stay safe',
  ),

  // 11. Rainy Night
  WeatherTemplate(
    id: 11,
    gradient: [TWColors.slate900, TWColors.indigo950, Colors.black],
    textColor: Colors.white,
    icon: LucideIcons.cloudRain,
    statement: const WeatherStatement(
      line1: 'Rainy',
      line1Style: 'outline',
      line2: 'night',
      line3: 'ahead.',
      line4: null,
    ),
    tip: 'Cozy night to stay inside',
  ),

  // 12. Fog
  WeatherTemplate(
    id: 12,
    gradient: [Colors.white, TWColors.gray100, TWColors.gray200],
    textColor: TWColors.gray800,
    icon: LucideIcons.cloudFog,
    statement: const WeatherStatement(
      line1: "Can't",
      line2: 'see',
      line2Style: 'outline',
      line3: 'a damn',
      line4: 'thing.',
    ),
    tip: 'Drive carefully, low visibility',
  ),

  // 13. Snow
  WeatherTemplate(
    id: 13,
    gradient: [TWColors.blue200, Colors.white, TWColors.blue100],
    textColor: TWColors.gray800,
    icon: LucideIcons.cloudSnow,
    statement: const WeatherStatement(
      line1: "It's",
      line2: 'snowing',
      line2Style: 'outline',
      line3: 'like',
      line4: 'crazy.',
    ),
    tip: 'Winter wonderland out there',
  ),

  // 14. Snowy Night
  WeatherTemplate(
    id: 14,
    gradient: [TWColors.indigo950, TWColors.blue950, TWColors.slate950],
    textColor: Colors.white,
    icon: LucideIcons.cloudSnow,
    statement: const WeatherStatement(
      line1: 'Snowy',
      line1Style: 'outline',
      line2: 'night',
      line3: 'is',
      line4: 'here.',
    ),
    tip: 'Bundle up if going outside',
  ),

  // 16. Windy
  WeatherTemplate(
    id: 16,
    gradient: [TWColors.cyan200, TWColors.blue200, TWColors.sky300],
    textColor: TWColors.gray800,
    icon: LucideIcons.wind,
    statement: const WeatherStatement(
      line1: 'Crazy',
      line1Style: 'outline',
      line2: 'windy',
      line3: 'day',
      line4: 'today.',
    ),
    tip: 'Hold onto your hat!',
  ),

  // 17. Drizzle
  WeatherTemplate(
    id: 17,
    gradient: [TWColors.blue300, TWColors.cyan200, TWColors.teal200],
    textColor: TWColors.gray800,
    icon: LucideIcons.cloudDrizzle,
    statement: const WeatherStatement(
      line1: 'Light',
      line2: 'drizzle',
      line2Style: 'outline',
      line3: 'all',
      line4: 'day.',
    ),
    tip: 'Light jacket and umbrella',
  ),

  // 19. Windy Night
  WeatherTemplate(
    id: 19,
    gradient: [TWColors.slate800, TWColors.indigo900, TWColors.blue950],
    textColor: Colors.white,
    icon: LucideIcons.wind,
    statement: const WeatherStatement(
      line1: 'Windy',
      line1Style: 'outline',
      line2: 'night',
      line3: 'feels',
      line4: 'wild.',
    ),
    tip: 'Hold onto your hat!',
  ),

  // 20. Drizzle Night
  WeatherTemplate(
    id: 20,
    gradient: [TWColors.slate900, TWColors.blue950, TWColors.indigo950],
    textColor: Colors.white,
    icon: LucideIcons.cloudDrizzle,
    statement: const WeatherStatement(
      line1: 'Light',
      line2: 'drizzle',
      line2Style: 'outline',
      line3: 'all',
      line4: 'night.',
    ),
    tip: 'Cozy vibes, slight mist',
  ),

  // 21. Gentle Snow (Day)
  WeatherTemplate(
    id: 21,
    gradient: [Colors.white, TWColors.blue100, TWColors.cyan200],
    textColor: TWColors.gray800,
    icon: LucideIcons.cloudSnow,
    statement: const WeatherStatement(
      line1: 'Gentle',
      line1Style: 'outline',
      line2: 'snow',
      line3: 'falling',
      line4: 'today.',
    ),
    tip: 'Soft flakes and quiet streets',
  ),

  // 22. Light Snow (Night)
  WeatherTemplate(
    id: 22,
    gradient: [TWColors.blue950, TWColors.slate900, TWColors.indigo950],
    textColor: Colors.white,
    icon: LucideIcons.cloudSnow,
    statement: const WeatherStatement(
      line1: 'Light',
      line2: 'snow',
      line2Style: 'outline',
      line3: 'tonight.',
      line4: null,
    ),
    tip: 'Quiet flurries in the dark',
  ),
];

WeatherTemplate resolveTemplate({
  required int code,
  required bool isNight,
  required int tempF,
  required int windMph,
}) {
  // 1. Wind first
  if (windMph > 25) {
    return weatherTemplates.firstWhere((t) => t.id == (isNight ? 19 : 16));
  }

  // Thunder
  if ([95, 96, 99].contains(code)) {
    return weatherTemplates.firstWhere((t) => t.id == 10);
  }

  // Snow
  if ([71, 73, 75, 77, 85, 86].contains(code)) {
    final heavy = [75, 77, 86].contains(code);
    if (heavy) {
      return weatherTemplates.firstWhere((t) => t.id == (isNight ? 14 : 13));
    } else {
      return weatherTemplates.firstWhere((t) => t.id == (isNight ? 22 : 21));
    }
  }

  // Rain
  if ([61, 63, 65, 80, 81, 82].contains(code)) {
    return weatherTemplates.firstWhere((t) => t.id == (isNight ? 11 : 1));
  }

  // Drizzle
  if ([51, 53, 55, 56, 57].contains(code)) {
    return weatherTemplates.firstWhere((t) => t.id == (isNight ? 20 : 17));
  }

  // Fog
  if ([45, 48].contains(code)) {
    return weatherTemplates.firstWhere((t) => t.id == 12);
  }

  // Clear
  if (code == 0) {
    if (isNight) return weatherTemplates.firstWhere((t) => t.id == 7);
    if (tempF > 85) return weatherTemplates.firstWhere((t) => t.id == 3);
    if (tempF < 32) return weatherTemplates.firstWhere((t) => t.id == 6);
    return weatherTemplates.firstWhere((t) => t.id == 2);
  }

  // Partly Cloudy
  if (code == 1 || code == 2) {
    return weatherTemplates.firstWhere((t) => t.id == (isNight ? 8 : 5));
  }

  // Overcast
  if (code == 3) {
    return weatherTemplates.firstWhere((t) => t.id == (isNight ? 9 : 4));
  }

  return weatherTemplates.firstWhere((t) => t.id == (isNight ? 7 : 2));
}

