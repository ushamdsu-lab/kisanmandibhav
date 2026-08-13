import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../data/city_locations.dart';
import '../data/mandi_directory.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String cityName;
  final String state;
  final String district;
  final String mandi;
  final bool isGps;
  final String? errorMessage;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.state,
    required this.district,
    required this.mandi,
    this.isGps = false,
    this.errorMessage,
  });
}

class LocationService {
  /// Calculate distance between two coordinates in kilometers using Haversine formula
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // pi / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R * asin(...)
  }

  /// Get nearest city from CityDatabase.popularCities
  static CityLocation getNearestPopularCity(double lat, double lng) {
    CityLocation nearest = CityDatabase.popularCities.first;
    double minDistance = double.infinity;

    for (final city in CityDatabase.popularCities) {
      final dist = calculateDistance(lat, lng, city.latitude, city.longitude);
      if (dist < minDistance) {
        minDistance = dist;
        nearest = city;
      }
    }
    return nearest;
  }

  /// Fetch user location via GPS -> LastKnown -> IP Geolocation -> Default City
  static Future<LocationResult> getCurrentLocation() async {
    try {
      // 1. Check & Request Permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      double? lat;
      double? lng;
      bool isGpsSuccess = false;

      // 2. If permission granted, attempt GPS / LastKnown
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        try {
          // Fast check: Last Known Position (instant cached fix)
          final lastKnown = await Geolocator.getLastKnownPosition();
          if (lastKnown != null) {
            lat = lastKnown.latitude;
            lng = lastKnown.longitude;
            isGpsSuccess = true;
          }
        } catch (e) {
          debugPrint('Geolocator lastKnown error: $e');
        }

        // If no cached fix, request fresh low-latency fix
        if (lat == null || lng == null) {
          try {
            final position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.low,
                timeLimit: Duration(seconds: 5),
              ),
            );
            lat = position.latitude;
            lng = position.longitude;
            isGpsSuccess = true;
          } catch (e) {
            debugPrint('Geolocator currentPosition error: $e');
          }
        }
      }

      // 3. If GPS failed or disabled, use network IP Geolocation fallback
      if (lat == null || lng == null) {
        try {
          final ipRes = await http
              .get(Uri.parse('http://ip-api.com/json/?fields=status,country,regionName,city,lat,lon'))
              .timeout(const Duration(seconds: 3));
          if (ipRes.statusCode == 200) {
            final ipData = json.decode(ipRes.body);
            if (ipData['status'] == 'success' && ipData['lat'] != null) {
              lat = (ipData['lat'] as num).toDouble();
              lng = (ipData['lon'] as num).toDouble();
              isGpsSuccess = true;
            }
          }
        } catch (e) {
          debugPrint('IP Geolocation fallback error: $e');
        }
      }

      // 4. Default fallback if everything failed
      if (lat == null || lng == null) {
        lat = 28.6139; // Delhi default
        lng = 77.2090;
      }

      // 5. Find nearest predefined city
      final nearestCity = getNearestPopularCity(lat, lng);
      String cityName = nearestCity.name;
      String state = nearestCity.state;
      String district = nearestCity.name.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
      String mandi = '';

      // 6. Try Reverse Geocoding via OpenStreetMap Nominatim
      try {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&accept-language=hi,en',
        );
        final response = await http.get(
          url,
          headers: {'User-Agent': 'KisanMandiBhavApp/1.0'},
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final addr = data['address'] as Map<String, dynamic>?;
          if (addr != null) {
            final place = addr['suburb'] ?? addr['city'] ?? addr['town'] ?? addr['village'] ?? addr['municipality'];
            final distName = addr['state_district'] ?? addr['county'] ?? addr['city'];
            final stName = addr['state'];

            if (place != null && place.toString().trim().isNotEmpty) {
              final pStr = place.toString().trim();
              final dStr = distName != null ? distName.toString().trim() : '';
              if (dStr.isNotEmpty && dStr != pStr) {
                cityName = '$pStr, $dStr';
              } else {
                cityName = pStr;
              }
              district = dStr.isNotEmpty ? dStr : pStr;
            }
            if (stName != null && stName.toString().trim().isNotEmpty) {
              final s = stName.toString().trim();
              String matched = s;
              for (final st in MandiDirectory.allStates) {
                if (s.toLowerCase().contains(st.toLowerCase()) || st.toLowerCase().contains(s.toLowerCase())) {
                  matched = st;
                  break;
                }
              }
              state = matched;
            }
          }
        }
      } catch (e) {
        debugPrint('Nominatim Reverse Geocoding error: $e');
      }

      // 7. Resolve Mandi from Directory for this state/district
      final mandis = MandiDirectory.getMandisForDistrict(state, district);
      if (mandis.isNotEmpty) {
        mandi = mandis.first;
      } else {
        mandi = MandiDirectory.getDefaultMandi(state);
      }

      return LocationResult(
        latitude: lat,
        longitude: lng,
        cityName: cityName,
        state: state,
        district: district,
        mandi: mandi,
        isGps: isGpsSuccess,
      );
    } catch (e) {
      debugPrint('LocationService unexpected error: $e');
      return LocationResult(
        latitude: 28.6139,
        longitude: 77.2090,
        cityName: 'नई दिल्ली (Delhi)',
        state: 'Delhi',
        district: 'Central Delhi',
        mandi: 'Azadpur APMC',
        isGps: false,
        errorMessage: 'स्थान प्राप्त करने में समस्या हुई।',
      );
    }
  }
}
