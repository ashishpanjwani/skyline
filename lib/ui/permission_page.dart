import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:as_promised_weather/services/location_service.dart';
import 'package:as_promised_weather/ui/settings_page.dart'; // for Place
import 'package:shared_preferences/shared_preferences.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  bool _loading = false;

  Future<void> _enableLocation() async {
    setState(() => _loading = true);
    try {
      final result =
          await LocationService().getCurrentLocationWithName(allowIpFallback: false);
      if (result != null) {
        await _saveLocationMode('current');
        if (mounted) context.go('/');
      }
    } catch (e) {
      debugPrint('Permission enable failed: $e');
      if (mounted) {
        bool opened = false;
        if (e.toString().contains('disabled')) {
          opened = await LocationService().openLocationSettings();
        } else if (e.toString().contains('permanently')) {
          opened = await LocationService().openAppSettings();
        }

        if (!opened && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not enable location. Please check settings.'),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _searchCity() async {
    final result = await context.push('/change-city');
    if (result is Place) {
      await _saveManualLocation(result);
      if (mounted) context.go('/');
    }
  }

  Future<void> _saveLocationMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loc_mode', mode);
  }

  Future<void> _saveManualLocation(Place place) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loc_mode', 'manual');
    await prefs.setDouble('loc_lat', place.lat);
    await prefs.setDouble('loc_lon', place.lon);
    await prefs.setString('loc_label', place.displayName);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1e293b), const Color(0xFF0f172a)]
                : [const Color(0xFFe0f2fe), const Color(0xFFffffff)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: color.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.mapPin, size: 64, color: color.primary),
                ),
                const SizedBox(height: 40),
                Text(
                  'Enable Location',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: color.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'We need your location to show you accurate weather conditions for your area.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    height: 1.5,
                    color: color.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                if (_loading)
                  const CircularProgressIndicator()
                else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _enableLocation,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        backgroundColor: color.primary,
                        foregroundColor: color.onPrimary,
                      ),
                      child: Text(
                        'Turn on Location',
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _searchCity,
                    child: Text(
                      'Search for your city',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

