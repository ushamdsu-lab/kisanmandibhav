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
  final bool isLocationServiceDisabled;
  final bool isPermissionDeniedForever;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.state,
    required this.district,
    required this.mandi,
    this.isGps = false,
    this.errorMessage,
    this.isLocationServiceDisabled = false,
    this.isPermissionDeniedForever = false,
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

  /// Fetch user location via GPS -> LastKnown -> Multi-provider IP Geolocation -> Reverse Geocoding
  static Future<LocationResult> getCurrentLocation() async {
    try {
      double? lat;
      double? lng;
      bool isGpsSuccess = false;
      bool isServiceDisabled = false;
      bool isDeniedForever = false;
      String? customError;
      String? ipCity;
      String? ipRegion;

      // 1. Check Location Service & Permissions
      bool serviceEnabled = false;
      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      } catch (e) {
        debugPrint('Geolocator isLocationServiceEnabled error: $e');
      }

      if (!serviceEnabled) {
        isServiceDisabled = true;
        customError = 'फोन का GPS (लोकेशन) बंद है। कृपया ऊपर से GPS चालू करें।';
      }

      LocationPermission permission = LocationPermission.denied;
      try {
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.deniedForever) {
          isDeniedForever = true;
          customError = 'लोकेशन परमिशन बंद है। ऐप सेटिंग्स से परमिशन चालू करें।';
        }
      } catch (e) {
        debugPrint('Geolocator permission error: $e');
      }

      // 2. If permission granted and service enabled, attempt fresh GPS first!
      if (serviceEnabled &&
          (permission == LocationPermission.always || permission == LocationPermission.whileInUse)) {
        // Step 2A: High accuracy fresh GPS fix (up to 12 seconds)
        try {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 12),
            ),
          );
          lat = position.latitude;
          lng = position.longitude;
          isGpsSuccess = true;
          customError = null;
        } catch (e) {
          debugPrint('Geolocator high fix timed out or failed: $e');
        }

        // Step 2B: Balanced / medium accuracy fix (Cell tower + WiFi) if satellite GPS timed out (e.g. indoors)
        if (lat == null || lng == null) {
          try {
            final position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.medium,
                timeLimit: Duration(seconds: 6),
              ),
            );
            lat = position.latitude;
            lng = position.longitude;
            isGpsSuccess = true;
            customError = null;
          } catch (e) {
            debugPrint('Geolocator medium fix failed: $e');
          }
        }

        // Step 2C: Fallback to last known position
        if (lat == null || lng == null) {
          try {
            final lastKnown = await Geolocator.getLastKnownPosition();
            if (lastKnown != null) {
              lat = lastKnown.latitude;
              lng = lastKnown.longitude;
              isGpsSuccess = true;
              customError = null;
            }
          } catch (e) {
            debugPrint('Geolocator lastKnown fallback error: $e');
          }
        }
      }

      // 3. Fallback to reliable IP Geolocation if GPS is unavailable / disabled / timed out
      if (lat == null || lng == null) {
        // Option A: ipwho.is (fast HTTPS, reliable Indian ISP location)
        try {
          final res = await http
              .get(Uri.parse('https://ipwho.is/'))
              .timeout(const Duration(seconds: 4));
          if (res.statusCode == 200) {
            final data = json.decode(res.body);
            if (data['success'] == true && data['latitude'] != null && data['longitude'] != null) {
              lat = (data['latitude'] as num).toDouble();
              lng = (data['longitude'] as num).toDouble();
              ipCity = data['city']?.toString();
              ipRegion = data['region']?.toString();
              // Note: IP geolocation is approximate, not real hardware GPS
              isGpsSuccess = false;
            }
          }
        } catch (e) {
          debugPrint('ipwho.is fallback error: $e');
        }

        // Option B: freeipapi.com (secure HTTPS secondary free IP geolocation provider)
        if (lat == null || lng == null) {
          try {
            final res = await http
                .get(Uri.parse('https://freeipapi.com/api/json'))
                .timeout(const Duration(seconds: 4));
            if (res.statusCode == 200) {
              final data = json.decode(res.body);
              if (data['latitude'] != null && data['longitude'] != null) {
                lat = (data['latitude'] as num).toDouble();
                lng = (data['longitude'] as num).toDouble();
                ipCity = data['cityName']?.toString();
                ipRegion = data['regionName']?.toString();
                isGpsSuccess = false;
              }
            }
          } catch (e) {
            debugPrint('freeipapi fallback error: $e');
          }
        }
      }

      // 4. Default fallback if absolutely all location methods failed
      if (lat == null || lng == null) {
        lat = 26.9124; // Jaipur, Rajasthan default
        lng = 75.7873;
      }

      // 5. Pre-match nearest predefined city from coordinates
      final nearestCity = getNearestPopularCity(lat, lng);
      String cityName = nearestCity.name;
      String state = ipRegion != null && ipRegion.isNotEmpty ? ipRegion : nearestCity.state;
      String district = ipCity != null && ipCity.isNotEmpty ? ipCity : nearestCity.effectiveDistrict;

      String? detectedPlace;
      String? detectedDistrict;

      // 6. Reverse Geocoding - Primary: BigDataCloud Reverse Geocoding Client (Fast & Accurate for India)
      try {
        final bdcUrl = Uri.parse(
          'https://api-bdc.io/data/reverse-geocode-client?latitude=$lat&longitude=$lng&localityLanguage=en',
        );
        final bdcResponse = await http.get(bdcUrl).timeout(const Duration(seconds: 4));
        if (bdcResponse.statusCode == 200) {
          final data = json.decode(bdcResponse.body);
          if (data is Map<String, dynamic>) {
            final p = data['locality'] ?? data['city'];
            final st = data['principalSubdivision'];

            if (p != null && p.toString().trim().isNotEmpty) {
              detectedPlace = p.toString().trim();
            }
            if (st != null && st.toString().trim().isNotEmpty) {
              state = st.toString().trim();
            }

            final admin = data['localityInfo']?['administrative'];
            if (admin is List) {
              for (final item in admin) {
                if (item is Map) {
                  final name = item['name']?.toString() ?? '';
                  final desc = item['description']?.toString() ?? '';
                  if (desc.toLowerCase().contains('district') || name.toLowerCase().contains('district')) {
                    detectedDistrict = name
                        .replaceAll(RegExp(r'\s*district\s*', caseSensitive: false), '')
                        .trim();
                    break;
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('BigDataCloud Reverse Geocoding error: $e');
      }

      // 7. Reverse Geocoding - Secondary: OpenStreetMap Nominatim Fallback
      if (detectedDistrict == null || detectedDistrict.isEmpty) {
        try {
          final url = Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&accept-language=hi,en',
          );
          final response = await http.get(
            url,
            headers: {'User-Agent': 'KisanMitraApp/1.0.5 (kisanmitra.india@gmail.com)'},
          ).timeout(const Duration(seconds: 4));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final addr = data['address'] as Map<String, dynamic>?;
            if (addr != null) {
              final place = addr['suburb'] ??
                  addr['town'] ??
                  addr['village'] ??
                  addr['city'] ??
                  addr['subdistrict'] ??
                  addr['municipality'] ??
                  addr['hamlet'] ??
                  addr['neighbourhood'];
              final distName = addr['state_district'] ??
                  addr['county'] ??
                  addr['city_district'] ??
                  addr['district'];
              final stName = addr['state'];

              if (place != null && place.toString().trim().isNotEmpty) {
                detectedPlace = place.toString().trim();
              }
              if (distName != null && distName.toString().trim().isNotEmpty) {
                detectedDistrict = distName
                    .toString()
                    .replaceAll(RegExp(r'\s*district\s*', caseSensitive: false), '')
                    .trim();
              }
              if (stName != null && stName.toString().trim().isNotEmpty) {
                state = stName.toString().trim();
              }
            }
          }
        } catch (e) {
          debugPrint('Nominatim Reverse Geocoding error: $e');
        }
      }

      // 8. Match and Standardize State
      for (final st in MandiDirectory.allStates) {
        if (state.toLowerCase().contains(st.toLowerCase()) || st.toLowerCase().contains(state.toLowerCase())) {
          state = st;
          break;
        }
      }

      // 9. Match and Standardize District
      String stdDistrict = '';
      if (detectedDistrict != null && detectedDistrict.isNotEmpty) {
        stdDistrict = MandiDirectory.getStandardDistrictName(state, detectedDistrict);
      }
      if (stdDistrict.isEmpty && detectedPlace != null && detectedPlace.isNotEmpty) {
        stdDistrict = MandiDirectory.getStandardDistrictName(state, detectedPlace);
      }
      if (stdDistrict.isEmpty && ipCity != null && ipCity.isNotEmpty) {
        stdDistrict = MandiDirectory.getStandardDistrictName(state, ipCity);
      }
      if (stdDistrict.isEmpty || !MandiDirectory.hasDistrict(state, stdDistrict)) {
        stdDistrict = nearestCity.effectiveDistrict;
        if (state.isEmpty) state = nearestCity.state;
      }
      district = stdDistrict;

      // 10. Auto-Detect Specific Nearest Mandi for Farmer
      String nearestMandi = '';
      final availableDistrictMandis = MandiDirectory.getMandisForDistrict(state, district);

      if (nearestCity.mandi.isNotEmpty &&
          (nearestCity.effectiveDistrict.toLowerCase() == district.toLowerCase() ||
              availableDistrictMandis.contains(nearestCity.mandi))) {
        nearestMandi = nearestCity.mandi;
      } else if (detectedPlace != null && detectedPlace.isNotEmpty) {
        final placeLower = detectedPlace.toLowerCase();
        for (final m in availableDistrictMandis) {
          if (m.toLowerCase().contains(placeLower) || placeLower.contains(m.toLowerCase().replaceAll('apmc', '').trim())) {
            nearestMandi = m;
            break;
          }
        }
      }

      if (nearestMandi.isEmpty && availableDistrictMandis.isNotEmpty) {
        nearestMandi = availableDistrictMandis.first;
      }

      // 11. Format City Name Display for Farmer UI
      if (detectedPlace != null && detectedPlace.isNotEmpty && detectedDistrict != null && detectedDistrict.isNotEmpty) {
        if (detectedPlace.toLowerCase() != detectedDistrict.toLowerCase()) {
          cityName = '$detectedPlace ($detectedDistrict)';
        } else {
          cityName = detectedPlace;
        }
      } else if (detectedPlace != null && detectedPlace.isNotEmpty) {
        cityName = detectedPlace;
      } else if (detectedDistrict != null && detectedDistrict.isNotEmpty) {
        cityName = detectedDistrict;
      } else if (ipCity != null && ipCity.isNotEmpty) {
        cityName = ipCity;
      } else {
        cityName = nearestCity.name;
      }

      return LocationResult(
        latitude: lat,
        longitude: lng,
        cityName: cityName,
        state: state,
        district: district,
        mandi: nearestMandi,
        isGps: isGpsSuccess,
        errorMessage: isGpsSuccess ? null : customError,
        isLocationServiceDisabled: isServiceDisabled,
        isPermissionDeniedForever: isDeniedForever,
      );
    } catch (e) {
      debugPrint('LocationService unexpected error: $e');
      return LocationResult(
        latitude: 26.9124,
        longitude: 75.7873,
        cityName: 'जयपुर (Jaipur)',
        state: 'Rajasthan',
        district: 'Jaipur',
        mandi: 'Jaipur (Grain) APMC',
        isGps: false,
        errorMessage: 'स्थान प्राप्त करने में समस्या हुई। कृपया GPS ऑन करें।',
        isLocationServiceDisabled: true,
      );
    }
  }
}
