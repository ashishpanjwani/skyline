import 'package:as_promised_weather/core/constants/pref_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for app preferences (units, location mode, creative mode).
/// All SharedPreferences access goes through this class.
class PreferencesRepository {
  PreferencesRepository({Future<SharedPreferences>? prefsFuture})
      : _prefsFuture = prefsFuture ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _prefsFuture;

  Future<SharedPreferences> get _prefs => _prefsFuture;

  // --- Units ---
  Future<String> getTempUnit() async {
    final p = await _prefs;
    return p.getString(PrefKeys.tempUnit) ?? 'C';
  }

  Future<void> setTempUnit(String unit) async {
    final p = await _prefs;
    await p.setString(PrefKeys.tempUnit, unit);
  }

  Future<String> getWindUnit() async {
    final p = await _prefs;
    return p.getString(PrefKeys.windUnit) ?? 'kmh';
  }

  Future<void> setWindUnit(String unit) async {
    final p = await _prefs;
    await p.setString(PrefKeys.windUnit, unit);
  }

  Future<String> getPressureUnit() async {
    final p = await _prefs;
    return p.getString(PrefKeys.pressureUnit) ?? 'mb';
  }

  Future<void> setPressureUnit(String unit) async {
    final p = await _prefs;
    await p.setString(PrefKeys.pressureUnit, unit);
  }

  Future<bool> getCreativeMode() async {
    final p = await _prefs;
    return p.getBool(PrefKeys.creativeMode) ?? false;
  }

  Future<void> setCreativeMode(bool value) async {
    final p = await _prefs;
    await p.setBool(PrefKeys.creativeMode, value);
  }

  // --- Location ---
  /// Returns (lat, lon, label) if mode is manual and coords are saved; otherwise null.
  Future<(double, double, String?)?> getSavedLocationIfManual() async {
    final p = await _prefs;
    if (p.getString(PrefKeys.locMode) != 'manual') return null;
    final lat = p.getDouble(PrefKeys.locLat);
    final lon = p.getDouble(PrefKeys.locLon);
    final label = p.getString(PrefKeys.locLabel);
    if (lat == null || lon == null) return null;
    return (lat, lon, label);
  }

  Future<void> saveLocationManual(double lat, double lon, String label) async {
    final p = await _prefs;
    await p.setString(PrefKeys.locMode, 'manual');
    await p.setDouble(PrefKeys.locLat, lat);
    await p.setDouble(PrefKeys.locLon, lon);
    await p.setString(PrefKeys.locLabel, label);
  }

  Future<void> saveLastLocation(double lat, double lon, String label) async {
    final p = await _prefs;
    await p.setDouble(PrefKeys.lastLat, lat);
    await p.setDouble(PrefKeys.lastLon, lon);
    await p.setString(PrefKeys.lastLocName, label);
  }

  Future<void> setLocationModeCurrent() async {
    final p = await _prefs;
    await p.setString(PrefKeys.locMode, 'current');
  }

  /// Last known location (from last successful load). Null if never loaded.
  Future<(double, double, String?)?> getLastLocation() async {
    final p = await _prefs;
    final lat = p.getDouble(PrefKeys.lastLat);
    final lon = p.getDouble(PrefKeys.lastLon);
    final name = p.getString(PrefKeys.lastLocName);
    if (lat == null || lon == null) return null;
    return (lat, lon, name);
  }
}
