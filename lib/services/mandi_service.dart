import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/mandi_rate.dart';

class MandiService {
  static List<MandiRate>? _cachedRates;
  static DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Fetch mandi rates directly from GitHub CDN (auto-synced hourly from govt portal)
  /// with GitHub Raw and offline asset fallbacks. The app never queries the govt API directly.
  static Future<List<MandiRate>> fetchMandiRates({
    String? state,
    String? district,
    String? market,
    String? commodity,
    int limit = 5000,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    List<MandiRate> allRates = [];

    // Use memory cache if valid and not a forced refresh
    if (!forceRefresh &&
        _cachedRates != null &&
        _cachedRates!.isNotEmpty &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      allRates = _cachedRates!;
    }

    // 1. Fetch from GitHub jsDelivr High-Speed CDN
    if (allRates.isEmpty) {
      try {
        const cdnUrl =
            'https://cdn.jsdelivr.net/gh/ushamdsu-lab/kisanmandibhav@main/assets/data/mandi_live_rates.json';
        final response =
            await http.get(Uri.parse(cdnUrl)).timeout(const Duration(seconds: 6));
        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final dynamic decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic> && decoded['records'] is List) {
            final List<dynamic> records = decoded['records'];
            allRates = records.map((e) => MandiRate.fromJson(e)).toList();
            _cachedRates = allRates;
            _lastFetchTime = DateTime.now();
          }
        }
      } catch (_) {}
    }

    // 2. Fallback to GitHub Raw URL if CDN is temporarily unavailable
    if (allRates.isEmpty) {
      try {
        const rawUrl =
            'https://raw.githubusercontent.com/ushamdsu-lab/kisanmandibhav/main/assets/data/mandi_live_rates.json';
        final response =
            await http.get(Uri.parse(rawUrl)).timeout(const Duration(seconds: 6));
        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final dynamic decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic> && decoded['records'] is List) {
            final List<dynamic> records = decoded['records'];
            allRates = records.map((e) => MandiRate.fromJson(e)).toList();
            _cachedRates = allRates;
            _lastFetchTime = DateTime.now();
          }
        }
      } catch (_) {}
    }

    // 3. Fallback to Local Bundled Asset if phone has no internet (Offline mode)
    if (allRates.isEmpty) {
      try {
        final jsonString =
            await rootBundle.loadString('assets/data/mandi_live_rates.json');
        final decoded = json.decode(jsonString);
        if (decoded is Map<String, dynamic> && decoded['records'] is List) {
          final List<dynamic> records = decoded['records'];
          allRates = records.map((e) => MandiRate.fromJson(e)).toList();
        }
      } catch (_) {}
    }

    // Apply location & commodity filters locally on the dataset
    var filtered = allRates;
    if (state != null && state.isNotEmpty) {
      filtered = filtered.where((r) => r.state.toLowerCase() == state.toLowerCase()).toList();
    }
    if (district != null && district.isNotEmpty) {
      filtered = filtered.where((r) => r.district.toLowerCase() == district.toLowerCase()).toList();
    }
    if (market != null && market.isNotEmpty) {
      filtered = filtered.where((r) => r.market.toLowerCase().contains(market.toLowerCase())).toList();
    }
    if (commodity != null && commodity.isNotEmpty) {
      filtered = filtered.where((r) => r.commodity.toLowerCase().contains(commodity.toLowerCase())).toList();
    }

    if (limit > 0 && filtered.length > limit) {
      return filtered.take(limit).toList();
    }
    return filtered;
  }
}
