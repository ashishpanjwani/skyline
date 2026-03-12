import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:as_promised_weather/ui/settings_overlay.dart' show SettingToggle; // reuse toggle component
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:as_promised_weather/services/location_service.dart';

/// A full-screen Settings page pushed onto the app's navigation stack.
///
/// No overlays, notches, or demo home-indicators. Uses go_router for navigation.
class SettingsPage extends StatefulWidget {
  final String unit; // 'C' or 'F'
  final ValueChanged<String> onUnitChange;
  final void Function(String name, double lat, double lon) onSelectLocation;
  final String currentLocationLabel;
  final VoidCallback? onUseCurrentLocation;
  final String windUnit; // kmh | mph | ms
  final String pressureUnit; // mb | inHg | hPa
  final ValueChanged<String> onWindUnitChange;
  final ValueChanged<String> onPressureUnitChange;
  final bool creativeEnabled;
  final ValueChanged<bool> onCreativeChange;

  const SettingsPage({
    super.key,
    required this.unit,
    required this.onUnitChange,
    required this.onSelectLocation,
    this.currentLocationLabel = '',
    this.onUseCurrentLocation,
    this.windUnit = 'kmh',
    this.pressureUnit = 'mb',
    required this.onWindUnitChange,
    required this.onPressureUnitChange,
    this.creativeEnabled = false,
    required this.onCreativeChange,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _unit;
  late String _windUnit;
  late String _pressureUnit;

  @override
  void initState() {
    super.initState();
    _unit = widget.unit;
    _windUnit = widget.windUnit;
    _pressureUnit = widget.pressureUnit;
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Removed AppBar; using custom header with close icon that pops the screen
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SETTINGS',
                            style: GoogleFonts.inter(
                                color: color.onSurface.withValues(alpha: 0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5)),
                        Text('Preferences',
                            style: GoogleFonts.inter(
                                color: color.onSurface,
                                fontSize: 32,
                                fontWeight: FontWeight.w900)),
                      ]),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(LucideIcons.x),
                    color: color.onSurface,
                    style: IconButton.styleFrom(
                        backgroundColor:
                            color.onSurface.withValues(alpha: 0.1)),
                  ),
                ]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PreferencesView(
              key: const ValueKey('prefs'),
              unit: _unit,
              onUnitChange: (u) {
                setState(() => _unit = u);
                widget.onUnitChange(u);
              },
              onOpenLocation: () async {
                final place = await context.push('/change-city') as Place?;
                if (place != null) {
                  if (place.isCurrent && widget.onUseCurrentLocation != null) {
                    widget.onUseCurrentLocation!.call();
                  } else {
                    widget.onSelectLocation(
                        place.displayName, place.lat, place.lon);
                  }
                  context.pop();
                }
              },
              currentLocationLabel: widget.currentLocationLabel,
              windUnit: _windUnit,
              pressureUnit: _pressureUnit,
              onWindUnitChange: (w) {
                setState(() => _windUnit = w);
                widget.onWindUnitChange(w);
              },
              onPressureUnitChange: (p) {
                setState(() => _pressureUnit = p);
                widget.onPressureUnitChange(p);
              },
              creativeEnabled: widget.creativeEnabled,
              onCreativeChange: widget.onCreativeChange,
            ),
          ),
        ]),
      ),
    );
  }
}

class PreferencesView extends StatelessWidget {
  final String unit;
  final ValueChanged<String> onUnitChange;
  final VoidCallback onOpenLocation;
  final String currentLocationLabel;
  final String windUnit;
  final String pressureUnit;
  final ValueChanged<String> onWindUnitChange;
  final ValueChanged<String> onPressureUnitChange;
  final bool creativeEnabled;
  final ValueChanged<bool> onCreativeChange;

  const PreferencesView({
    super.key,
    required this.unit,
    required this.onUnitChange,
    required this.onOpenLocation,
    this.currentLocationLabel = '',
    required this.windUnit,
    required this.pressureUnit,
    required this.onWindUnitChange,
    required this.onPressureUnitChange,
    required this.creativeEnabled,
    required this.onCreativeChange,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(
            LucideIcons.thermometerSun, 'TEMPERATURE UNIT', onSurface),
        Row(children: [
          Expanded(
              child: _unitButton('°C', 'Celsius', unit == 'C', onSurface,
                  () => onUnitChange('C'))),
          const SizedBox(width: 12),
          Expanded(
              child: _unitButton('°F', 'Fahrenheit', unit == 'F', onSurface,
                  () => onUnitChange('F'))),
        ]),
        const SizedBox(height: 28),
        _sectionHeader(LucideIcons.mapPin, 'LOCATION', onSurface),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: onSurface.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: onSurface.withValues(alpha: 0.12)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text((currentLocationLabel.isNotEmpty
                    ? currentLocationLabel
                    : 'Set current location'),
                style: GoogleFonts.inter(
                    color: onSurface, fontSize: 20, fontWeight: FontWeight.w900),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: onOpenLocation,
              child: Text('Change your location',
                  style: GoogleFonts.inter(
                      color: onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
        const SizedBox(height: 28),
        _sectionHeader(LucideIcons.wind, 'WIND SPEED', onSurface),
        _pillOptions(
          context,
          onSurface,
          options: const [
            ('km/h', 'kmh'),
            ('mph', 'mph'),
            ('m/s', 'ms'),
          ],
          selected: windUnit,
          onSelect: onWindUnitChange,
        ),
        const SizedBox(height: 20),
        _sectionHeader(LucideIcons.gauge, 'PRESSURE', onSurface),
        _pillOptions(
          context,
          onSurface,
          options: const [
            ('mb', 'mb'),
            ('inHg', 'inHg'),
            ('hPa', 'hPa'),
          ],
          selected: pressureUnit,
          onSelect: onPressureUnitChange,
        ),
        const SizedBox(height: 28),
        _sectionHeader(LucideIcons.wand, 'BE CREATIVE', onSurface),
        SettingToggle(
          label: 'Generate playful titles',
          initialValue: creativeEnabled,
          onChanged: onCreativeChange,
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ABOUT',
                style: GoogleFonts.inter(
                    color: onSurface.withValues(alpha: 0.38),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1)),
            Text('Feels Good: Weather v1.0',
                style: GoogleFonts.inter(
                    color: onSurface.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w800,
                    fontSize: 14)),
            Text('Expressive weather, beautifully designed.',
                style: GoogleFonts.inter(
                    color: onSurface.withValues(alpha: 0.6), fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color onSurface) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Icon(icon, size: 18, color: onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Text(title,
              style: GoogleFonts.inter(
                  color: onSurface.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2)),
        ]),
      );

  Widget _unitButton(String symbol, String label, bool active, Color onSurface,
          VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            color: active
                ? onSurface.withValues(alpha: 0.16)
                : onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: active ? onSurface : onSurface.withValues(alpha: 0.12),
                width: 2),
          ),
          child: Column(children: [
            Text(symbol,
                style: GoogleFonts.inter(
                    color: onSurface,
                    fontSize: 36,
                    fontWeight: FontWeight.w900)),
            Text(label,
                style: GoogleFonts.inter(
                    color: onSurface.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ]),
        ),
      );

  Widget _pillOptions(
    BuildContext context,
    Color onSurface, {
    required List<(String, String)> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Wrap(spacing: 8, runSpacing: 8, children: [
      for (final (label, value) in options)
        GestureDetector(
          onTap: () => onSelect(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected == value
                  ? onSurface.withValues(alpha: 0.16)
                  : onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: selected == value
                      ? onSurface
                      : onSurface.withValues(alpha: 0.12)),
            ),
            child: Text(label,
                style: GoogleFonts.inter(
                    color: onSurface, fontWeight: FontWeight.w800)),
          ),
        ),
    ]);
  }
}

class Place {
  final String displayName;
  final double lat;
  final double lon;
  final bool isCurrent;
  const Place(
      {required this.displayName,
      required this.lat,
      required this.lon,
      this.isCurrent = false});
}

class LocationSearchView extends StatefulWidget {
  final VoidCallback onBack;
  final ValueChanged<Place> onPick;
  const LocationSearchView({super.key, required this.onBack, required this.onPick});

  @override
  State<LocationSearchView> createState() => _LocationSearchViewState();
}

class _LocationSearchViewState extends State<LocationSearchView> {
  final TextEditingController _controller = TextEditingController();
  List<Place> _results = const [];
  String _query = '';
  Timer? _debounce;
  bool _loading = false;
  bool _locating = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Location services are turned off'),
            action: SnackBarAction(
                label: 'Open Settings',
                onPressed: () => Geolocator.openLocationSettings()),
          ));
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Permission permanently denied'),
            action: SnackBarAction(
                label: 'Open Settings',
                onPressed: () => Geolocator.openAppSettings()),
          ));
        }
        return;
      }
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')));
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final name = await LocationService()
          .getNameFromCoordinates(pos.latitude, pos.longitude);
      final display = name ?? 'Current Location';
      if (mounted) {
        widget.onPick(Place(
            displayName: display,
            lat: pos.latitude,
            lon: pos.longitude,
            isCurrent: true));
      }
    } catch (e) {
      debugPrint('Set current location failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get current location')));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _results = const []);
      return;
    }
    setState(() => _loading = true);
    try {
      final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
        'name': q,
        'count': '10',
        'language': 'en',
        'format': 'json'
      });
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data =
            json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final List items = (data['results'] as List?) ?? const [];
        final results = items.map((e) {
          final m = e as Map<String, dynamic>;
          final name = (m['name'] as String?) ?? '';
          final admin1 = (m['admin1'] as String?) ?? '';
          final country = (m['country'] as String?) ?? '';
          final disp = [
            name,
            if (admin1.isNotEmpty) admin1,
            if (country.isNotEmpty) country
          ].join(', ');
          final lat = (m['latitude'] as num).toDouble();
          final lon = (m['longitude'] as num).toDouble();
          return Place(displayName: disp, lat: lat, lon: lon, isCurrent: false);
        }).cast<Place>().toList();
        if (mounted) setState(() => _results = results);
      }
    } catch (e) {
      debugPrint('Location search failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('LOCATION',
                style: GoogleFonts.inter(
                    color: onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w900,
                    fontSize: 12)),
            Text('Change City',
                style: GoogleFonts.inter(
                    color: onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 28)),
          ]),
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(LucideIcons.x),
            color: onSurface,
            style: IconButton.styleFrom(
                backgroundColor: onSurface.withValues(alpha: 0.1)),
          ),
        ]),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          onChanged: (v) {
            _query = v;
            _debounce?.cancel();
            _debounce =
                Timer(const Duration(milliseconds: 350), () => _search(_query));
            setState(() {});
          },
          style: GoogleFonts.inter(
              color: onSurface, fontSize: 16, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: 'Search for a city...',
            hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.3)),
            filled: true,
            fillColor: onSurface.withValues(alpha: 0.06),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: onSurface.withValues(alpha: 0.12))),
          ),
        ),
        if (_query.isEmpty) ...[
          const SizedBox(height: 20),
          Text('YOUR LOCATION',
              style: GoogleFonts.inter(
                  color: onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w900,
                  fontSize: 11)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _locating ? null : _useCurrentLocation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: onSurface.withValues(alpha: 0.12)),
              ),
              child: Row(children: [
                Icon(LucideIcons.navigation,
                    color: onSurface.withValues(alpha: 0.7), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _locating
                        ? 'Fetching current location…'
                        : 'Set Current Location',
                    style: GoogleFonts.inter(
                        color: onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w900),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_locating)
                  SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: onSurface.withValues(alpha: 0.7))),
                if (!_locating)
                  Icon(LucideIcons.chevronRight,
                      color: onSurface.withValues(alpha: 0.24)),
              ]),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Text(_query.isEmpty ? 'POPULAR CITIES' : 'SEARCH RESULTS',
            style: GoogleFonts.inter(
                color: onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w900,
                fontSize: 11)),
        const SizedBox(height: 10),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemCount: (_query.isEmpty ? _popular.length : _results.length),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (_query.isEmpty) {
                      final p = _popular[index];
                      return _cityTile(
                          p.displayName, onSurface, () => widget.onPick(p));
                    } else {
                      final r = _results[index];
                      return _cityTile(
                          r.displayName, onSurface, () => widget.onPick(r));
                    }
                  },
                ),
        ),
      ]),
    );
  }

  Widget _cityTile(String label, Color onSurface, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: onSurface.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: onSurface.withValues(alpha: 0.12)),
          ),
          child: Row(children: [
            Icon(LucideIcons.mapPin,
                color: onSurface.withValues(alpha: 0.6), size: 18),
            const SizedBox(width: 10),
            Expanded(
                child: Text(label,
                    style: GoogleFonts.inter(
                        color: onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w900),
                    overflow: TextOverflow.ellipsis)),
            Icon(LucideIcons.chevronRight,
                color: onSurface.withValues(alpha: 0.24)),
          ]),
        ),
      );

  static const List<Place> _popular = [
    Place(
        displayName: 'San Francisco, CA, United States',
        lat: 37.7749,
        lon: -122.4194,
        isCurrent: false),
    Place(
        displayName: 'New York, NY, United States',
        lat: 40.7128,
        lon: -74.0060,
        isCurrent: false),
    Place(
        displayName: 'London, United Kingdom',
        lat: 51.5074,
        lon: -0.1278,
        isCurrent: false),
    Place(
        displayName: 'Bengaluru, Karnataka, IN',
        lat: 12.9716,
        lon: 77.5946,
        isCurrent: false),
    Place(
        displayName: 'Tokyo, Japan',
        lat: 35.6762,
        lon: 139.6503,
        isCurrent: false),
    Place(
        displayName: 'Sydney, Australia',
        lat: -33.8688,
        lon: 151.2093,
        isCurrent: false),
  ];
}

// Add a standalone ChangeCityPage that hosts LocationSearchView and pops the route
class ChangeCityPage extends StatelessWidget {
  const ChangeCityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LocationSearchView(
          onBack: () => context.pop(),
          onPick: (place) => context.pop(place),
        ),
      ),
    );
  }
}

