import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models.dart';

// --- DATA MODEL ---
class WeatherWidgetData {
  final int id;
  final String type; // 'square' | 'round'
  final List<Color> gradient;
  final Color textColor;
  final IconData icon;
  final int temperature;
  final String location;
  final String condition;
  final int high;
  final int low;

  WeatherWidgetData({
    required this.id,
    required this.type,
    required this.gradient,
    this.textColor = Colors.black,
    required this.icon,
    required this.temperature,
    required this.location,
    required this.condition,
    required this.high,
    required this.low,
  });
}

// Icon Mapping Helper
IconData getIcon(String iconName) {
  switch (iconName) {
    case 'rain':
      return LucideIcons.cloudRain;
    case 'sun':
      return LucideIcons.sun;
    case 'snow':
      return LucideIcons.snowflake;
    case 'cloud':
      return LucideIcons.cloud;
    case 'wind':
      return LucideIcons.wind;
    default:
      return LucideIcons.cloud;
  }
}

class SquareWidget extends StatelessWidget {
  final WeatherWidgetData data;

  const SquareWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isWhiteText = data.textColor == Colors.white;
    final secondaryTextColor = data.textColor.withValues(alpha: 0.7);

    return Container(
      width: 250,
      height: 250,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: Stack(
        children: [
          // Background decorative element
          Positioned(
            bottom: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isWhiteText
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.location.toUpperCase(),
                            style: GoogleFonts.inter(
                                color: secondaryTextColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 12),
                        Text(data.condition,
                            style: GoogleFonts.inter(
                                color: data.textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    Icon(data.icon,
                        color: data.textColor.withValues(alpha: 0.8), size: 40),
                  ],
                ),
                // Bottom section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${data.temperature}°",
                        style: GoogleFonts.inter(
                            color: data.textColor,
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                            height: 1)),
                    Text("H:${data.high}° L:${data.low}°",
                        style: GoogleFonts.inter(
                            color: secondaryTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RoundWidget extends StatelessWidget {
  final WeatherWidgetData data;

  const RoundWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor = data.textColor.withValues(alpha: 0.7);

    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative rings
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: data.textColor.withValues(alpha: 0.1), width: 2),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: data.textColor.withValues(alpha: 0.05), width: 1),
            ),
          ),
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(data.icon,
                  color: data.textColor.withValues(alpha: 0.8), size: 48),
              const SizedBox(height: 4),
              Text("${data.temperature}°",
                  style: GoogleFonts.inter(
                      color: data.textColor,
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      height: 1)),
              Text(data.condition.toUpperCase(),
                  style: GoogleFonts.inter(
                      color: secondaryTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1)),
              Text("${data.high}° / ${data.low}°",
                  style: GoogleFonts.inter(
                      color: secondaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(data.location,
                  style: GoogleFonts.inter(
                      color: data.textColor.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

