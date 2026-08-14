import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/price_alert.dart';
import '../models/mandi_rate.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme
  static bool isDarkMode() => _prefs?.getBool('dark_mode') ?? false;
  static Future<void> setDarkMode(bool value) async =>
      await _prefs?.setBool('dark_mode', value);

  // Favorite Commodities
  static List<String> getFavoriteCommodities() =>
      _prefs?.getStringList('fav_commodities') ?? [];
  
  static Future<void> toggleFavoriteCommodity(String commodity) async {
    final list = getFavoriteCommodities();
    if (list.contains(commodity)) {
      list.remove(commodity);
    } else {
      list.add(commodity);
    }
    await _prefs?.setStringList('fav_commodities', list);
  }

  // Bookmarked Schemes
  static List<String> getBookmarkedSchemes() =>
      _prefs?.getStringList('bookmarked_schemes') ?? [];

  static Future<void> toggleBookmarkScheme(String schemeId) async {
    final list = getBookmarkedSchemes();
    if (list.contains(schemeId)) {
      list.remove(schemeId);
    } else {
      list.add(schemeId);
    }
    await _prefs?.setStringList('bookmarked_schemes', list);
  }

  // Location
  static String getSavedCity() => _prefs?.getString('city') ?? '';
  static double getSavedLatitude() => _prefs?.getDouble('latitude') ?? 0;
  static double getSavedLongitude() => _prefs?.getDouble('longitude') ?? 0;
  static String getSavedState() => _prefs?.getString('saved_state') ?? '';
  static String getSavedDistrict() => _prefs?.getString('saved_district') ?? '';
  static String getSavedMandi() => _prefs?.getString('saved_mandi') ?? '';
  
  static Future<void> saveLocation({
    required String city,
    required double lat,
    required double lng,
    String? state,
    String? district,
    String? mandi,
  }) async {
    await _prefs?.setString('city', city);
    await _prefs?.setDouble('latitude', lat);
    await _prefs?.setDouble('longitude', lng);
    if (state != null && state.isNotEmpty) {
      await _prefs?.setString('saved_state', state);
    }
    if (district != null) {
      await _prefs?.setString('saved_district', district);
    }
    if (mandi != null) {
      await _prefs?.setString('saved_mandi', mandi);
    }
  }

  static Future<void> saveMandiLocation({
    required String state,
    String? district,
    String? mandi,
  }) async {
    if (state.isNotEmpty) {
      await _prefs?.setString('saved_state', state);
    }
    if (district != null) {
      await _prefs?.setString('saved_district', district);
    }
    if (mandi != null) {
      await _prefs?.setString('saved_mandi', mandi);
    }
  }

  // Mandi API Key
  static String getMandiApiKey() => _prefs?.getString('mandi_api_key') ?? '';
  static Future<void> setMandiApiKey(String key) async =>
      await _prefs?.setString('mandi_api_key', key);

  // Price Alerts
  static List<PriceAlert> getPriceAlerts() {
    final str = _prefs?.getString('price_alerts') ?? '';
    return PriceAlert.decodeList(str);
  }

  static Future<void> savePriceAlert(PriceAlert alert) async {
    final alerts = getPriceAlerts();
    alerts.removeWhere((a) => a.id == alert.id);
    alerts.insert(0, alert);
    await _prefs?.setString('price_alerts', PriceAlert.encodeList(alerts));
  }

  static Future<void> deletePriceAlert(String alertId) async {
    final alerts = getPriceAlerts();
    alerts.removeWhere((a) => a.id == alertId);
    await _prefs?.setString('price_alerts', PriceAlert.encodeList(alerts));
  }

  static Future<void> updatePriceAlerts(List<PriceAlert> alerts) async {
    await _prefs?.setString('price_alerts', PriceAlert.encodeList(alerts));
  }

  // --- 🗄️ Offline Cache for Mandi Rates ---
  static Future<void> saveCachedMandiRates(String state, List<MandiRate> rates) async {
    if (rates.isEmpty) return;
    try {
      final jsonList = rates.map((r) => r.toJson()).toList();
      await _prefs?.setString('cache_mandi_${state.toLowerCase()}', json.encode(jsonList));
      await _prefs?.setString('cache_mandi_time_${state.toLowerCase()}', DateTime.now().toIso8601String());
    } catch (_) {}
  }

  static List<MandiRate> getCachedMandiRates(String state) {
    try {
      final raw = _prefs?.getString('cache_mandi_${state.toLowerCase()}');
      if (raw == null || raw.isEmpty) return [];
      final List<dynamic> decoded = json.decode(raw);
      return decoded.map((e) => MandiRate.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static String getMandiLastSyncTime(String state) {
    try {
      final timeStr = _prefs?.getString('cache_mandi_time_${state.toLowerCase()}');
      if (timeStr == null) return '';
      final dt = DateTime.tryParse(timeStr);
      if (dt == null) return '';
      return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
