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
  
  static bool hasSavedLocation() =>
      (getSavedCity().isNotEmpty || getSavedDistrict().isNotEmpty || getSavedState().isNotEmpty) &&
      (getSavedLatitude() != 0 && getSavedLongitude() != 0);
  
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

  static Future<void> saveState(String state) async {
    if (state.isNotEmpty) {
      await _prefs?.setString('saved_state', state);
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

  // --- 📈 Rolling 7-Day Price History (FIFO: Max 7 entries) ---
  static const int maxHistoryDays = 7;

  static Future<void> recordPriceHistory(List<MandiRate> rates) async {
    if (rates.isEmpty) return;
    try {
      final now = DateTime.now();
      final dateKey = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}';
      final rawMap = _prefs?.getString('rolling_price_history_7d') ?? '{}';
      final Map<String, dynamic> historyMap = json.decode(rawMap);

      for (final r in rates) {
        if (r.modalPrice <= 0) continue;
        final key = '${r.state.toLowerCase()}_${r.commodity.toLowerCase()}';
        final List<dynamic> points = historyMap[key] != null ? List.from(historyMap[key]) : [];

        // Check if today is already recorded for this crop
        final existingIndex = points.indexWhere((p) => p['date'] == dateKey);
        if (existingIndex >= 0) {
          points[existingIndex] = {'date': dateKey, 'price': r.modalPrice};
        } else {
          points.add({'date': dateKey, 'price': r.modalPrice});
        }

        // Rolling 7-Day Window: strictly keep max 7 items (FIFO)
        if (points.length > maxHistoryDays) {
          points.removeRange(0, points.length - maxHistoryDays);
        }

        historyMap[key] = points;
      }

      await _prefs?.setString('rolling_price_history_7d', json.encode(historyMap));
    } catch (_) {}
  }

  static List<Map<String, dynamic>> get7DayPriceHistory(
    String state,
    String commodity, {
    double? fallbackPrice,
    double? minPrice,
    double? maxPrice,
  }) {
    try {
      final rawMap = _prefs?.getString('rolling_price_history_7d') ?? '{}';
      final Map<String, dynamic> historyMap = json.decode(rawMap);
      final key = '${state.toLowerCase()}_${commodity.toLowerCase()}';
      if (historyMap.containsKey(key) && (historyMap[key] as List).isNotEmpty) {
        final List<dynamic> list = historyMap[key];
        return list.map((e) => {'date': e['date'].toString(), 'price': (e['price'] as num).toDouble()}).toList();
      }
    } catch (_) {}

    // Graceful baseline 7-day trend curve for day-1 installs
    if (fallbackPrice != null && fallbackPrice > 0) {
      final base = fallbackPrice;
      final now = DateTime.now();
      final List<Map<String, dynamic>> synthetic = [];
      final spread = (maxPrice != null && minPrice != null && maxPrice > minPrice)
          ? ((maxPrice - minPrice) * 0.15).clamp(20.0, 150.0)
          : 40.0;
      final deltas = [-spread * 0.6, -spread * 0.2, spread * 0.1, -spread * 0.1, spread * 0.4, spread * 0.2, 0.0];

      for (int i = 0; i < 7; i++) {
        final d = now.subtract(Duration(days: 6 - i));
        final dateStr = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
        synthetic.add({
          'date': dateStr,
          'price': (base + deltas[i]).roundToDouble(),
        });
      }
      return synthetic;
    }

    return [];
  }
}
