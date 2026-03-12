import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Robust location service handling permissions, GPS, and IP fallback.
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Returns current location (lat, lon) and a reverse-geocoded city name.
  /// Throws exceptions for permission/service errors if [allowIpFallback] is false.
  /// If [allowIpFallback] is true (default), it attempts to resolve location via IP
  /// if GPS fails or is denied.
  Future<({double lat, double lon, String name})?> getCurrentLocationWithName({bool allowIpFallback = true}) async {
    try {
      // 1. Check Service Status
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[LocationService] Location services are disabled.');
        if (allowIpFallback) return await _ipGeolocate();
        throw const LocationServiceDisabledException();
      }

      // 2. Check/Request Permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        debugPrint('[LocationService] Location permission denied.');
        if (allowIpFallback) return await _ipGeolocate();
        throw const PermissionDeniedException('Location permission denied');
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[LocationService] Location permission denied forever.');
        if (allowIpFallback) return await _ipGeolocate();
        throw const PermissionDeniedException('Location permission permanently denied');
      }

      // 3. Get Position
      // Set a timeout to avoid hanging indefinitely
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      
      // 4. Reverse Geocode
      final name = await getNameFromCoordinates(pos.latitude, pos.longitude);
      return (lat: pos.latitude, lon: pos.longitude, name: name ?? 'Current Location');

    } catch (e) {
      debugPrint('[LocationService] GPS error: $e');
      if (allowIpFallback) {
        debugPrint('[LocationService] Falling back to IP geolocation...');
        return await _ipGeolocate();
      }
      rethrow;
    }
  }

  /// Public method to get a location name from coordinates.
  /// Returns null if lookup fails, so the caller can decide on a fallback.
  Future<String?> getNameFromCoordinates(double lat, double lon) async {
    // 1. Try Open-Meteo
    try {
      final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/reverse', {
        'latitude': lat.toString(),
        'longitude': lon.toString(),
        'language': 'en',
        'format': 'json',
      });
      final res = await http.get(uri, headers: {
        'User-Agent': 'as_promised_weather/1.0',
      });
      
      if (res.statusCode == 200) {
        final data = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final List results = (data['results'] as List?) ?? const [];
        if (results.isNotEmpty) {
           final Map first = results.first as Map;
           // Hierarchy of preference
           final candidates = [
             first['name'],
             first['city'],
             first['town'],
             first['village'],
             first['hamlet'],
             first['suburb'],
             first['admin1'],
             first['country'],
           ];

           for (final c in candidates) {
             if (c is String && c.trim().isNotEmpty) {
               return c.trim();
             }
           }
        }
      } else {
        debugPrint('[LocationService] Open-Meteo failed: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('[LocationService] Open-Meteo error: $e');
    }

    // 2. Fallback to Nominatim
    try {
      debugPrint('[LocationService] Falling back to Nominatim...');
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'format': 'json',
      });
      final res = await http.get(uri, headers: {
        'User-Agent': 'as_promised_weather/1.0',
      });
      
      if (res.statusCode == 200) {
        final data = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
           final name = address['city'] ?? 
                        address['town'] ?? 
                        address['village'] ?? 
                        address['hamlet'] ?? 
                        address['suburb'] ?? 
                        address['county'] ?? 
                        address['state'];
           if (name != null) return name.toString();
        }
      }
    } catch (e) {
      debugPrint('[LocationService] Nominatim error: $e');
    }

    return null;
  }

  Future<String> _reverseGeocode(double lat, double lon) async {
    return await getNameFromCoordinates(lat, lon) ?? 'Current Location';
  }

  /// Lightweight IP-based geolocation fallback.
  Future<({double lat, double lon, String name})?> _ipGeolocate() async {
    try {
      // Try ipapi.co (JSON)
      final uri = Uri.parse('https://ipapi.co/json/');
      final res = await http.get(uri, headers: {
        'User-Agent': 'weather-app/1.0',
      }).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final lat = (data['latitude'] is num) ? (data['latitude'] as num).toDouble() : null;
        final lon = (data['longitude'] is num) ? (data['longitude'] as num).toDouble() : null;
        final city = (data['city'] ?? '') as String;
        
        if (lat != null && lon != null) {
          return (lat: lat, lon: lon, name: city.isNotEmpty ? city : 'Your Area');
        }
      }
    } catch (e) {
      debugPrint('[LocationService] IP geolocate failed: $e');
    }
    return null;
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}

class PermissionDeniedException implements Exception {
  final String message;
  const PermissionDeniedException(this.message);
  @override
  String toString() => message;
}

class LocationServiceDisabledException implements Exception {
  const LocationServiceDisabledException();
  @override
  String toString() => 'Location services are disabled.';
}
