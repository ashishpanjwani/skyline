import 'dart:async';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:http/http.dart' as http;

/// A modern settings overlay with blur backdrop and elastic scale animation.
///
/// Parameters:
/// - unit: 'C' or 'F'
/// - onUnitChange: callback to propagate unit change back to the weather page
/// - onClose: dismiss the overlay (use context.pop() when wiring)
/// - onSelectLocation: called when a location is selected from search. Provides
///   a triple of (displayName, latitude, longitude)
class SettingsOverlay extends StatefulWidget {
  final String unit;
  final ValueChanged<String> onUnitChange;
  final VoidCallback onClose;
  final void Function(String name, double lat, double lon) onSelectLocation;

  const SettingsOverlay({
    super.key,
    required this.unit,
    required this.onUnitChange,
    required this.onClose,
    required this.onSelectLocation,
  });

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  bool showLocationScreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Backdrop blur and dimmer
          GestureDetector(
            onTap: widget.onClose,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),
          ),

          // Elastic scale "iPhone" container
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.9, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.85,
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 844),
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 40,
                        spreadRadius: 10),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Stack(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: showLocationScreen
                            ? _LocationScreen(
                                key: const ValueKey('location'),
                                onBack: () =>
                                    setState(() => showLocationScreen = false),
                                onClose: widget.onClose,
                                onPick: (place) {
                                  widget.onSelectLocation(
                                      place.displayName, place.lat, place.lon);
                                  widget.onClose();
                                },
                              )
                            : _PreferencesView(
                                key: const ValueKey('prefs'),
                                unit: widget.unit,
                                onUnitChange: widget.onUnitChange,
                                onClose: widget.onClose,
                                onOpenLocation: () => setState(
                                    () => showLocationScreen = true),
                              ),
                      ),

                      // iPhone notch
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 160,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                        ),
                      ),

                      // Home indicator
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 130,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferencesView extends StatelessWidget {
  final String unit;
  final ValueChanged<String> onUnitChange;
  final VoidCallback onClose;
  final VoidCallback onOpenLocation;

  const _PreferencesView({
    super.key,
    required this.unit,
    required this.onUnitChange,
    required this.onClose,
    required this.onOpenLocation,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 64, 32, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SETTINGS',
                style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5)),
            Text('Preferences',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900)),
          ]),
          IconButton(
            onPressed: onClose,
            icon: const Icon(LucideIcons.x, color: Colors.white, size: 24),
            style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1)),
          ),
        ]),
        const SizedBox(height: 48),

        _sectionHeader(LucideIcons.thermometerSun, 'TEMPERATURE UNIT'),
        Row(children: [
          Expanded(
              child:
                  _unitButton('°C', 'Celsius', unit == 'C', () => onUnitChange('C'))),
          const SizedBox(width: 12),
          Expanded(
              child: _unitButton(
                  '°F', 'Fahrenheit', unit == 'F', () => onUnitChange('F'))),
        ]),
        const SizedBox(height: 32),

        _sectionHeader(LucideIcons.mapPin, 'LOCATION'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Change your location',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: onOpenLocation,
              child: Text('Open location search',
                  style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
        const SizedBox(height: 32),

        _sectionHeader(LucideIcons.bell, 'NOTIFICATIONS'),
        const SettingToggle(label: 'Weather Alerts', initialValue: true),
        const SizedBox(height: 12),
        const SettingToggle(label: 'Daily Forecast', initialValue: false),
        const SizedBox(height: 12),
        const SettingToggle(label: 'Severe Weather', initialValue: true),
        const SizedBox(height: 32),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ABOUT',
                style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.38),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1)),
            const Text('Weather App v1.0',
                style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const Text('Expressive weather, beautifully designed.',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  Widget _sectionHeader(IconData icon, String title) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(children: [
          Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Text(title,
              style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2)),
        ]),
      );

  Widget _unitButton(String symbol, String label, bool active, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: active
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: active ? Colors.white : Colors.white.withValues(alpha: 0.12),
                width: 2),
          ),
          child: Column(children: [
            Text(symbol,
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900)),
            Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ]),
        ),
      );
}

class _Place {
  final String displayName;
  final double lat;
  final double lon;
  const _Place({required this.displayName, required this.lat, required this.lon});
}

class _LocationScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onClose;
  final ValueChanged<_Place> onPick;
  const _LocationScreen(
      {super.key, required this.onBack, required this.onClose, required this.onPick});

  @override
  State<_LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<_LocationScreen> {
  final TextEditingController _controller = TextEditingController();
  List<_Place> _results = const [];
  String _query = '';
  Timer? _debounce;
  bool _loading = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _results = const []);
      return;
    }
    setState(() => _loading = true);
    try {
      final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search',
          {'name': q, 'count': '10', 'language': 'en', 'format': 'json'});
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
          final disp = [name, if (admin1.isNotEmpty) admin1, if (country.isNotEmpty) country]
              .join(', ');
          final lat = (m['latitude'] as num).toDouble();
          final lon = (m['longitude'] as num).toDouble();
          return _Place(displayName: disp, lat: lat, lon: lon);
        }).cast<_Place>().toList();
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 64, 32, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('LOCATION',
                style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w900,
                    fontSize: 12)),
            Text('Change City',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 32)),
          ]),
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(LucideIcons.x, color: Colors.white),
            style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1)),
          ),
        ]),
        const SizedBox(height: 24),
        TextField(
          controller: _controller,
          onChanged: (v) {
            _query = v;
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 350), () => _search(_query));
            setState(() {});
          },
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Search for a city...',
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
          ),
        ),
        const SizedBox(height: 32),
        Text(_query.isEmpty ? 'POPULAR CITIES' : 'SEARCH RESULTS',
            style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.6),
                fontWeight: FontWeight.w900,
                fontSize: 11)),
        const SizedBox(height: 16),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : ListView.separated(
                  itemCount: (_query.isEmpty ? _popular.length : _results.length),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (_query.isEmpty) {
                      final p = _popular[index];
                      return _cityTile(p.displayName, () => widget.onPick(p));
                    } else {
                      final r = _results[index];
                      return _cityTile(r.displayName, () => widget.onPick(r));
                    }
                  },
                ),
        ),
      ]),
    );
  }

  Widget _cityTile(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(children: [
            Icon(LucideIcons.mapPin, color: Colors.white.withValues(alpha: 0.6), size: 20),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900),
                    overflow: TextOverflow.ellipsis)),
            Icon(LucideIcons.chevronRight, color: Colors.white.withValues(alpha: 0.24)),
          ]),
        ),
      );

  static const List<_Place> _popular = [
    _Place(displayName: 'San Francisco, CA, United States', lat: 37.7749, lon: -122.4194),
    _Place(displayName: 'New York, NY, United States', lat: 40.7128, lon: -74.0060),
    _Place(displayName: 'London, United Kingdom', lat: 51.5074, lon: -0.1278),
    _Place(displayName: 'Bengaluru, Karnataka, IN', lat: 12.9716, lon: 77.5946),
    _Place(displayName: 'Tokyo, Japan', lat: 35.6762, lon: 139.6503),
    _Place(displayName: 'Sydney, Australia', lat: -33.8688, lon: 151.2093),
  ];
}

class SettingToggle extends StatefulWidget {
  final String label;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;
  const SettingToggle(
      {super.key, required this.label, required this.initialValue, this.onChanged});

  @override
  State<SettingToggle> createState() => _SettingToggleState();
}

class _SettingToggleState extends State<SettingToggle> {
  late bool enabled;

  @override
  void initState() {
    super.initState();
    enabled = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => enabled = !enabled);
        widget.onChanged?.call(enabled);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(widget.label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 28,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: enabled ? Colors.white : Colors.white24,
                borderRadius: BorderRadius.circular(20)),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                  width: 20,
                  height: 20,
                  decoration:
                      const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
            ),
          ),
        ]),
      ),
    );
  }
}

