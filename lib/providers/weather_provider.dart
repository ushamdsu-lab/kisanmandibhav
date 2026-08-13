import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../data/city_locations.dart';
import 'mandi_provider.dart';

class WeatherAlert {
  final String title;
  final String description;
  final String icon;
  final Color color;
  final String severity; // 'warning', 'info', 'success', 'danger'

  const WeatherAlert({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.severity,
  });
}

class WeatherProvider extends ChangeNotifier {
  WeatherData? _weatherData;
  bool _isLoading = false;
  String _error = '';
  
  // Default to Delhi / National Central Hub
  String _cityName = 'दिल्ली (Delhi)';
  double _currentLat = 28.6139;
  double _currentLng = 77.2090;

  bool _isGpsLocation = false;
  String _detectedState = 'Delhi';
  String _detectedDistrict = 'Delhi';
  String _detectedMandi = 'Delhi Mandi APMC';

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get cityName => _cityName;
  double get currentLat => _currentLat;
  double get currentLng => _currentLng;
  bool get isGpsLocation => _isGpsLocation;
  String get detectedState => _detectedState;
  String get detectedDistrict => _detectedDistrict;
  String get detectedMandi => _detectedMandi;

  WeatherProvider() {
    _loadSavedLocation();
  }

  void _loadSavedLocation() {
    final savedCity = StorageService.getSavedCity();
    final savedLat = StorageService.getSavedLatitude();
    final savedLng = StorageService.getSavedLongitude();

    if (savedCity.isNotEmpty && savedLat != 0 && savedLng != 0) {
      _cityName = savedCity;
      _currentLat = savedLat;
      _currentLng = savedLng;
    }
  }

  Future<LocationResult> fetchUserLocation({MandiProvider? mandiProvider}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    final result = await LocationService.getCurrentLocation();
    
    _isGpsLocation = result.isGps;
    _currentLat = result.latitude;
    _currentLng = result.longitude;
    _cityName = result.cityName;
    _detectedState = result.state;
    _detectedDistrict = result.district;
    _detectedMandi = result.mandi;

    await StorageService.saveLocation(
      city: _cityName,
      lat: _currentLat,
      lng: _currentLng,
      state: _detectedState,
      district: _detectedDistrict,
      mandi: _detectedMandi,
    );

    if (mandiProvider != null) {
      mandiProvider.syncLocationContext(
        state: _detectedState,
        district: _detectedDistrict,
        market: _detectedMandi,
      );
    }

    try {
      _weatherData = await WeatherService.fetchWeather(
        latitude: _currentLat,
        longitude: _currentLng,
        locationName: _cityName,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return result;
  }

  Future<void> fetchWeather({
    double? latitude,
    double? longitude,
    String? city,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      if (latitude != null) _currentLat = latitude;
      if (longitude != null) _currentLng = longitude;
      if (city != null) _cityName = city;

      _weatherData = await WeatherService.fetchWeather(
        latitude: _currentLat,
        longitude: _currentLng,
        locationName: _cityName,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCity(CityLocation loc, {MandiProvider? mandiProvider}) {
    _isGpsLocation = false;
    _cityName = loc.name;
    _currentLat = loc.latitude;
    _currentLng = loc.longitude;
    _detectedState = loc.state;
    _detectedDistrict = loc.effectiveDistrict;
    
    StorageService.saveLocation(
      city: loc.name,
      lat: loc.latitude,
      lng: loc.longitude,
      state: loc.state,
      district: loc.effectiveDistrict,
      mandi: loc.mandi,
    );

    if (mandiProvider != null) {
      mandiProvider.syncLocationContext(
        state: loc.state,
        district: loc.effectiveDistrict,
        market: loc.mandi.isNotEmpty ? loc.mandi : null,
      );
    }

    fetchWeather(latitude: loc.latitude, longitude: loc.longitude, city: loc.name);
  }

  /// Get wind direction in clear Hindi
  String getWindDirectionHindi(int degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'उत्तर (N)';
    if (degrees >= 22.5 && degrees < 67.5) return 'उत्तर-पूर्व (NE)';
    if (degrees >= 67.5 && degrees < 112.5) return 'पूर्व (E)';
    if (degrees >= 112.5 && degrees < 157.5) return 'दक्षिण-पूर्व (SE)';
    if (degrees >= 157.5 && degrees < 202.5) return 'दक्षिण (S)';
    if (degrees >= 202.5 && degrees < 247.5) return 'दक्षिण-पश्चिम (SW)';
    if (degrees >= 247.5 && degrees < 292.5) return 'पश्चिम (W)';
    return 'उत्तर-पश्चिम (NW)';
  }

  /// Backward compatible helper for dashboard
  String getFarmingAdvisory() {
    final alerts = getActiveAlerts();
    if (alerts.isEmpty) return '✅ मौसम खेती के लिए अनुकूल है';
    return '${alerts.first.icon} ${alerts.first.description}';
  }

  /// Get Active High-Priority Alerts
  List<WeatherAlert> getActiveAlerts() {
    if (_weatherData == null) return [];

    final current = _weatherData!.current;
    final daily = _weatherData!.daily;
    final List<WeatherAlert> alerts = [];

    final rawRainProb = daily.isNotEmpty ? daily.first.precipitationProbability : 0;
    final todayPrecipSum = daily.isNotEmpty ? daily.first.precipitationSum : 0.0;

    // Strict cap: If actual rain volume is 0.0 mm, rain probability cannot artificially show 100%
    final todayRainProb = (todayPrecipSum < 1.0 && current.rain < 0.3 && current.precipitation < 0.3)
        ? (rawRainProb > 25 ? (current.cloudCover * 0.35).round() : rawRainProb)
        : rawRainProb;

    // 1. Rain & Weather Alerts
    if (current.rain > 0.3 || current.precipitation > 0.3) {
      alerts.add(WeatherAlert(
        title: 'बारिश जारी है (${current.precipitation.toStringAsFixed(1)} mm)',
        description: 'खेत में पानी निकासी का प्रबंध रखें और किसी भी प्रकार का छिड़काव तुरंत रोक दें।',
        icon: '🌧️',
        color: Colors.blue.shade700,
        severity: 'warning',
      ));
    } else if (todayPrecipSum >= 1.0 && todayRainProb >= 40) {
      alerts.add(WeatherAlert(
        title: 'आज वर्षा की संभावना ($todayRainProb% - ${todayPrecipSum.toStringAsFixed(1)} mm)',
        description: 'काटी गई फसल को सुरक्षित स्थान पर रखें और शाम तक छिड़काव से बचें।',
        icon: '🌧️',
        color: Colors.orange.shade800,
        severity: 'warning',
      ));
    } else if (current.cloudCover >= 70 && todayRainProb >= 35) {
      alerts.add(WeatherAlert(
        title: 'आंशिक बादल छाये हैं (हल्की $todayRainProb% संभावना)',
        description: 'मौसम पर नज़र रखें। फिलहाल हल्की धूप व बादलों की आवाजाही रहेगी।',
        icon: '⛅',
        color: Colors.amber.shade900,
        severity: 'info',
      ));
    } else {
      alerts.add(const WeatherAlert(
        title: 'मौसम पूरी तरह साफ़ व अनुकूल है',
        description: 'फसल की सिंचाई, कटाई, थ्रेशिंग व स्प्रे कार्य हेतु आज मौसम पूरी तरह अनुकूल है।',
        icon: '☀️',
        color: Colors.green,
        severity: 'info',
      ));
    }

    // 2. High Wind Alert
    if (current.windSpeed > 25) {
      alerts.add(WeatherAlert(
        title: 'तेज हवा चेतावनी (${current.windSpeed.toInt()} km/h)',
        description: 'तेज हवा के कारण फसलों के गिरने का खतरा है। दवा का छिड़काव बिल्कुल न करें।',
        icon: '💨',
        color: Colors.deepOrange,
        severity: 'danger',
      ));
    }

    // 3. Frost / Cold Alert
    final minTemp = daily.isNotEmpty ? daily.first.tempMin : current.temperature;
    if (minTemp <= 4) {
      alerts.add(WeatherAlert(
        title: 'शीतलहर व पाला चेतावनी (${minTemp.round()}°C न्यूनतम)',
        description: 'रात में पाला जमने का खतरा है। फसलों की सुरक्षा हेतु शाम को हल्की सिंचाई करें।',
        icon: '❄️',
        color: Colors.cyan.shade800,
        severity: 'danger',
      ));
    }

    // 4. Extreme Heat Alert
    final maxTemp = daily.isNotEmpty ? daily.first.tempMax : current.temperature;
    if (maxTemp >= 40) {
      alerts.add(WeatherAlert(
        title: 'भीषण गर्मी व लू चेतावनी (${maxTemp.round()}°C अधिकतम)',
        description: 'दोपहर में धूप से बचें, फसलों में नमी बनाए रखने हेतु समय पर सिंचाई करें।',
        icon: '🔥',
        color: Colors.red.shade700,
        severity: 'danger',
      ));
    }

    return alerts;
  }

  /// Spray window advice (Good / Moderate / Bad)
  Map<String, dynamic> getSprayWindowStatus() {
    if (_weatherData == null) {
      return {'status': 'अज्ञात', 'color': Colors.grey, 'reason': 'डेटा लोड हो रहा है'};
    }

    final current = _weatherData!.current;
    final daily = _weatherData!.daily;
    final rawRainProb = daily.isNotEmpty ? daily.first.precipitationProbability : 0;
    final precipSum = daily.isNotEmpty ? daily.first.precipitationSum : 0.0;
    final rainProb = (precipSum < 1.0 && current.rain < 0.3 && current.precipitation < 0.3)
        ? (rawRainProb > 25 ? (current.cloudCover * 0.35).round() : rawRainProb)
        : rawRainProb;
    final wind = current.windSpeed;

    if (current.rain > 0.3 || (precipSum >= 1.0 && rainProb > 40)) {
      return {
        'status': '🔴 अभी स्प्रे न करें (प्रतिकूल)',
        'color': Colors.red,
        'reason': 'बारिश की संभावना ($rainProb%) से दवा धुल जाएगी',
        'isGood': false,
      };
    }

    if (wind > 18) {
      return {
        'status': '🔴 स्प्रे न करें (तेज हवा)',
        'color': Colors.red,
        'reason': 'हवा तेज (${wind.toInt()} km/h) होने से दवा उड़ जाएगी',
        'isGood': false,
      };
    }

    if (wind > 12 || (rainProb > 25 && precipSum > 0.5)) {
      return {
        'status': '🟡 मध्यम अनुकूल (सावधानी रखें)',
        'color': Colors.orange,
        'reason': 'हल्की हवा (${wind.toInt()} km/h) है, नोजल पौधे के पास रखकर स्प्रे करें',
        'isGood': true,
      };
    }

    return {
      'status': '🟢 स्प्रे के लिए उत्तम समय',
      'color': Colors.green,
      'reason': 'हवा शांत (${wind.toInt()} km/h) और बारिश की संभावना केवल $rainProb% है',
      'isGood': true,
    };
  }

  /// Irrigation advice
  Map<String, dynamic> getIrrigationStatus() {
    if (_weatherData == null) {
      return {'status': 'अज्ञात', 'color': Colors.grey, 'reason': 'डेटा लोड हो रहा है'};
    }

    final daily = _weatherData!.daily;
    final nextPrecipSum = daily.take(2).fold(0.0, (max, d) => d.precipitationSum > max ? d.precipitationSum : max);
    final rainProbNext2Days = daily.take(2).fold(0, (max, d) => d.precipitationProbability > max ? d.precipitationProbability : max);

    if (nextPrecipSum >= 1.5 && rainProbNext2Days > 50) {
      return {
        'status': '⏸️ सिंचाई रोकें (Hold Irrigation)',
        'color': Colors.orange,
        'reason': 'अगले 48 घंटे में वर्षा (${nextPrecipSum.toStringAsFixed(1)} mm) की संभावना है',
      };
    }

    final current = _weatherData!.current;
    if (current.temperature > 38) {
      return {
        'status': '💧 शाम को सिंचाई करें',
        'color': Colors.blue,
        'reason': 'तापमान अधिक (${current.temperature.round()}°C) है, शाम को सिंचाई लाभदायक होगी',
      };
    }

    return {
      'status': '💧 सामान्य सिंचाई कर सकते हैं',
      'color': Colors.green,
      'reason': 'मौसम सामान्य है, फसल आवश्यकतानुसार सिंचाई करें',
    };
  }
}
