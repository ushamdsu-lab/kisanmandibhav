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

  /// Fetch user location via GPS (or fallback to nearest city)
  static Future<LocationResult> getCurrentLocation() async {
    try {
      bool serviceEnabled = false;
      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      } catch (e) {
        debugPrint('Geolocator check error: $e');
      }

      if (!serviceEnabled) {
        return LocationResult(
          latitude: 28.0229,
          longitude: 73.3119,
          cityName: 'बीकानेर (Bikaner)',
          state: 'Rajasthan',
          district: 'Bikaner',
          mandi: 'Bikaner (Grain) APMC',
          isGps: false,
          errorMessage: 'लोकेशन सर्विस बंद है। डिफ़ॉल्ट स्थान सेट है।',
        );
      }

      LocationPermission permission = LocationPermission.denied;
      try {
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
      } catch (e) {
        debugPrint('Geolocator permission error: $e');
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return LocationResult(
          latitude: 28.0229,
          longitude: 73.3119,
          cityName: 'बीकानेर (Bikaner)',
          state: 'Rajasthan',
          district: 'Bikaner',
          mandi: 'Bikaner (Grain) APMC',
          isGps: false,
          errorMessage: 'लोकेशन की अनुमति नहीं मिली। डिफ़ॉल्ट स्थान सेट है।',
        );
      }

      // Fetch Position with timeout
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 8),
          ),
        );
      } catch (e) {
        debugPrint('Geolocator position fetch error: $e');
      }

      if (position == null) {
        return LocationResult(
          latitude: 28.0229,
          longitude: 73.3119,
          cityName: 'बीकानेर (Bikaner)',
          state: 'Rajasthan',
          district: 'Bikaner',
          mandi: 'Bikaner (Grain) APMC',
          isGps: false,
          errorMessage: 'GPS सिग्नल प्राप्त नहीं हुआ।',
        );
      }

      final double lat = position.latitude;
      final double lng = position.longitude;

      // Find nearest predefined city
      final nearestCity = getNearestPopularCity(lat, lng);

      String cityName = nearestCity.name;
      String state = nearestCity.state;
      String district = nearestCity.name.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
      String mandi = '';

      // Try Reverse Geocoding via OpenStreetMap Nominatim
      try {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&accept-language=hi,en',
        );
        final response = await http.get(
          url,
          headers: {'User-Agent': 'KisanMitraApp/1.0'},
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
                if (s.toLowerCase().contains(st.toLowerCase()) ||
                    st.toLowerCase().contains(s.toLowerCase())) {
                  matched = st;
                  break;
                }
              }
              state = matched;
            }
          }
        }
      } catch (e) {
        debugPrint('Nominatim reverse geocode error: $e');
      }

      // Match nearest Mandi from MandiDirectory
      mandi = _findNearestMandi(state, district, nearestCity.name);

      return LocationResult(
        latitude: lat,
        longitude: lng,
        cityName: cityName,
        state: state,
        district: district,
        mandi: mandi,
        isGps: true,
      );
    } catch (e) {
      debugPrint('Location error: $e');
      return LocationResult(
        latitude: 28.6139,
        longitude: 77.2090,
        cityName: 'दिल्ली (Delhi)',
        state: 'Delhi',
        district: 'Delhi',
        mandi: 'Delhi Mandi APMC',
        isGps: false,
        errorMessage: 'लोकेशन प्राप्त करने में समस्या आई: $e',
      );
    }
  }

  static String _findNearestMandi(String state, String district, String cityName) {
    final Map<String, List<String>> districtMandis = MandiDirectory.getDistrictMandis(state);
    
    // First attempt: match district directly
    for (final entry in districtMandis.entries) {
      if (entry.key.toLowerCase().contains(district.toLowerCase()) ||
          district.toLowerCase().contains(entry.key.toLowerCase())) {
        if (entry.value.isNotEmpty) return entry.value.first;
      }
    }

    // Second attempt: match city name
    final cleanCity = cityName.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase();
    for (final entry in districtMandis.entries) {
      if (entry.key.toLowerCase().contains(cleanCity) || cleanCity.contains(entry.key.toLowerCase())) {
        if (entry.value.isNotEmpty) return entry.value.first;
      }
    }

    // Dynamic fallback per state from MandiDirectory
    return MandiDirectory.getDefaultMandi(state);
  }
}
