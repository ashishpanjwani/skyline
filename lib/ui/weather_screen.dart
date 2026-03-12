import 'package:as_promised_weather/ui/models.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

// --- MAIN SCREEN WIDGET ---
class WeatherScreen extends StatelessWidget {
  final WeatherData weather;
  final String location;
  final String unit;
  final VoidCallback onOpenSettings;
  final String windUnit;
  final String pressureUnit;
  final Future<void> Function() onRefresh;

  const WeatherScreen({
    super.key,
    required this.weather,
    required this.location,
    required this.onOpenSettings,
    required this.onRefresh,
    this.unit = 'C',
    this.windUnit = 'mph',
    this.pressureUnit = 'mb',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: weather.gradient,
          ),
        ),
        child: Stack(
          children: [
            // Scrollable Content
            SafeArea(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                color: weather.textColor,
                backgroundColor: weather.textColor.withValues(alpha: 0.1),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 30),
                      _buildAnimatedIcon(),
                      const SizedBox(height: 32),
                      _buildMainStatement(),
                      const SizedBox(height: 32),
                      _buildTempDisplay(),
                      const SizedBox(height: 48),
                      _buildTip(),
                      const SizedBox(height: 40),
                      _buildHourlySection(),
                      const SizedBox(height: 32),
                      _buildDailySection(),
                      const SizedBox(height: 32),
                      _buildAQISection(),
                      const SizedBox(height: 32),
                      _buildSunSection(),
                      const SizedBox(height: 32),
                      _buildDetailsGrid(),
                      const SizedBox(
                          height: 100), // Bottom padding for home indicator
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SUB-WIDGETS ---

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("LOCATION",
                style: GoogleFonts.inter(
                    color: weather.textColor.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5)),
            Text(location,
                style: GoogleFonts.inter(
                    color: weather.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w900)),
          ],
        ),
        IconButton(
          onPressed: onOpenSettings,
          icon: Icon(LucideIcons.settings, color: weather.textColor, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: weather.textColor.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(12),
          ),
        )
      ],
    );
  }

  Widget _buildAnimatedIcon() {
    return Center(
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 800),
        curve: Curves.elasticOut,
        builder: (context, double value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Icon(weather.icon, size: 85, color: weather.textColor),
      ),
    );
  }

  Widget _buildMainStatement() {
    return Center(
      child: Column(
        children: [
          if (weather.statement.line1.trim().isNotEmpty)
            _statementLine(
                weather.statement.line1, weather.statement.line1Style, 50),
          if (weather.statement.line2.trim().isNotEmpty)
            _statementLine(
                weather.statement.line2, weather.statement.line2Style, 64),
          if (weather.statement.line3.trim().isNotEmpty)
            _statementLine(
                weather.statement.line3, weather.statement.line3Style, 64),
          if (weather.statement.line4 != null &&
              weather.statement.line4!.trim().isNotEmpty)
            _statementLine(weather.statement.line4!, 'solid', 64),
        ],
      ),
    );
  }

  Widget _statementLine(String text, String? style, double size) {
    bool isOutline = style == 'outline';
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w900,
        height: 1.1,
        letterSpacing: -2,
        foreground: isOutline
            ? (Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5
              ..color = weather.textColor)
            : null,
        color: isOutline ? null : weather.textColor,
      ),
    );
  }

  Widget _buildTempDisplay() {
    return Center(
      child: Column(
        children: [
          Text("${weather.temperature}°$unit",
              style: GoogleFonts.inter(
                  color: weather.textColor,
                  fontSize: 84,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -5)),
          Text(
            "Feels like ${weather.feelsLike}° · H:${weather.high}° L:${weather.low}°",
            style: GoogleFonts.inter(
                color: weather.textColor.withValues(alpha: 0.5),
                fontSize: 14,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildTip() {
    return Center(
      child: Text(
        weather.tip,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
            color: weather.textColor.withValues(alpha: 0.7),
            fontSize: 16,
            fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildHourlySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("HOURLY"),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: weather.hourly.length,
            separatorBuilder: (context, index) => const SizedBox(width: 25),
            itemBuilder: (context, index) {
              final hour = weather.hourly[index];
              return Column(
                children: [
                  Text(hour.time,
                      style: GoogleFonts.inter(
                          color: weather.textColor.withValues(alpha: 0.6),
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  const SizedBox(height: 10),
                  Icon(hour.icon, color: weather.textColor, size: 28),
                  const SizedBox(height: 10),
                  Text("${hour.temp}°",
                      style: GoogleFonts.inter(
                          color: weather.textColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 22)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("THIS WEEK"),
        ...weather.daily.map((day) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                      width: 50,
                      child: Text(day.day,
                          style: GoogleFonts.inter(
                              color: weather.textColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 16))),
                  Icon(day.icon, color: weather.textColor, size: 24),
                  const Spacer(),
                  Text("${day.low}°",
                      style: GoogleFonts.inter(
                          color: weather.textColor.withValues(alpha: 0.5),
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(width: 15),
                  Text("${day.high}°",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                          color: weather.textColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 22)),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildAQISection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("AIR QUALITY"),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text("${weather.details.aqi}",
                style: GoogleFonts.inter(
                    color: weather.textColor,
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2)),
            const SizedBox(width: 12),
            Text(weather.details.aqiLabel,
                style: GoogleFonts.inter(
                    color: weather.textColor.withValues(alpha: 0.7),
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ],
    );
  }

  Widget _buildSunSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("SUN"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sunInfoTile(
                "Sunrise", weather.details.sunrise, LucideIcons.sunrise),
            _sunInfoTile("Sunset", weather.details.sunset, LucideIcons.sunset,
                isRight: true),
          ],
        ),
      ],
    );
  }

  Widget _sunInfoTile(String label, String time, IconData icon,
      {bool isRight = false}) {
    List<Widget> children = [
      Icon(icon, color: weather.textColor, size: 32),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment:
            isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  color: weather.textColor.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          Text(time,
              style: GoogleFonts.inter(
                  color: weather.textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    ];
    return Row(children: isRight ? children.reversed.toList() : children);
  }

  Widget _buildDetailsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("DETAILS"),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 1.3,
          children: [
            _detailTile("Humidity", "${weather.details.humidity}%"),
            _detailTile("Wind", "${weather.details.windSpeed}",
                unit: _windUnitLabel()),
            _detailTile("UV Index", "${weather.details.uvIndex}"),
            _detailTile("Visibility", "${weather.details.visibility}",
                unit: "mi"),
            _detailTile(
              "Pressure",
              _formatPressure(weather.details.pressure),
              unit: pressureUnit,
            ),
            _detailTile("Rain", "${weather.details.precipitation}%"),
          ],
        ),
      ],
    );
  }

  String _formatPressure(num p) {
    if (pressureUnit.toLowerCase() == 'inhg') {
      return (p is double ? p : p.toDouble()).toStringAsFixed(1);
    }
    return p.toStringAsFixed(0);
  }

  String _windUnitLabel() {
    switch (windUnit.toLowerCase()) {
      case 'kmh':
        return 'km/h';
      case 'ms':
        return 'm/s';
      default:
        return 'mph';
    }
  }

  Widget _detailTile(String label, String value, {String? unit}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                color: weather.textColor.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: value,
                  style: GoogleFonts.inter(
                      color: weather.textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w900)),
              if (unit != null)
                TextSpan(
                    text: " $unit",
                    style: GoogleFonts.inter(
                        color: weather.textColor.withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title,
          style: GoogleFonts.inter(
              color: weather.textColor.withValues(alpha: 0.4),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5)),
    );
  }
}

