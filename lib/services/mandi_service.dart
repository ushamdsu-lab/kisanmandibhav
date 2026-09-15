import 'dart:convert';
import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/mandi_rate.dart';

class MandiService {
  static List<MandiRate>? _cachedRates;
  static DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 10);

  // Production Vercel Serverless Edge API & CDN backend
  static String? vercelApiBaseUrl = 'https://kisanmandibhav.vercel.app';

  static List<MandiRate> _parseJsonRecords(String jsonString) {
    try {
      final dynamic decoded = json.decode(jsonString);
      if (decoded is Map<String, dynamic> && decoded['records'] is List) {
        final List<dynamic> records = decoded['records'];
        return records.map((e) => MandiRate.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<List<MandiRate>> _parseAsync(String jsonString) async {
    if (kIsWeb) {
      return _parseJsonRecords(jsonString);
    }
    return await Isolate.run(() => _parseJsonRecords(jsonString));
  }

  /// Merges live records from data.gov.in or CDN into the master record pool.
  /// If a crop already exists for that market, its price & arrival date are updated.
  /// If it's a newly reported crop, it is added to the market's list.
  /// No previously existing crop in that market is ever deleted.
  static List<MandiRate> _mergeRecords(List<MandiRate> masterList, List<MandiRate> liveList) {
    final Map<String, MandiRate> mergedMap = {};
    for (final r in masterList) {
      final key = '${r.state}|${r.district}|${r.market}|${r.commodity}'.toLowerCase().trim();
      mergedMap[key] = r;
    }
    for (final live in liveList) {
      final key = '${live.state}|${live.district}|${live.market}|${live.commodity}'.toLowerCase().trim();
      mergedMap[key] = live;
    }
    return mergedMap.values.toList();
  }

  /// Fetch comprehensive mandi rates from:
  /// 1. Vercel Serverless Edge API (if configured)
  /// 2. Direct official AGMARKNET data.gov.in API
  /// 3. GitHub jsDelivr High-Speed CDN
  /// 4. Bundled multi-crop offline database (20,872+ records across all states & mandis)
  static Future<List<MandiRate>> fetchMandiRates({
    String? state,
    String? district,
    String? market,
    String? commodity,
    int limit = 25000,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    // 1. Ensure base master dataset is loaded
    if (_cachedRates == null || _cachedRates!.isEmpty) {
      try {
        final jsonString = await rootBundle.loadString('assets/data/mandi_live_rates.json');
        _cachedRates = await _parseAsync(jsonString);
        _lastFetchTime = DateTime.now();
      } catch (_) {}
    }

    List<MandiRate> allRates = _cachedRates ?? [];

    // 2. Fetch live data from Vercel Edge / data.gov.in if forceRefresh or cache expired
    final bool shouldFetchLive = forceRefresh ||
        _lastFetchTime == null ||
        DateTime.now().difference(_lastFetchTime!) > _cacheDuration;

    if (shouldFetchLive) {
      List<MandiRate> liveGovRates = [];

      // A. Try Vercel Serverless API if endpoint is set
      if (vercelApiBaseUrl != null && vercelApiBaseUrl!.isNotEmpty) {
        try {
          final uri = Uri.parse('$vercelApiBaseUrl/api/mandi-rates${state != null ? '?state=${Uri.encodeComponent(state)}' : '?limit=5000'}');
          final response = await http.get(uri).timeout(const Duration(seconds: 4));
          if (response.statusCode == 200 && response.body.isNotEmpty) {
            liveGovRates = _parseJsonRecords(response.body);
          }
        } catch (_) {}
      }

      // B. Try direct official data.gov.in Agmarknet API
      if (liveGovRates.isEmpty) {
        try {
          final stateFilter = (state != null && state.isNotEmpty)
              ? '&filters[state]=${Uri.encodeComponent(state)}'
              : '';
          final uri = Uri.parse(
            'https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070'
            '?api-key=579b464db66ec23bdd000001592db4fa842b480f7171a34c0956c64d'
            '&format=json&limit=5000$stateFilter',
          );
          final response = await http.get(uri).timeout(const Duration(seconds: 5));
          if (response.statusCode == 200 && response.body.isNotEmpty) {
            final parsed = _parseJsonRecords(response.body);
            if (parsed.isNotEmpty) {
              liveGovRates = parsed;
            }
          }
        } catch (_) {}
      }

      // C. Fallback: GitHub jsDelivr CDN
      if (liveGovRates.isEmpty && (allRates.isEmpty || forceRefresh)) {
        try {
          final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1800000;
          final cdnUrl = 'https://cdn.jsdelivr.net/gh/ushamdsu-lab/kisanmandibhav@main/assets/data/mandi_live_rates.json?v=$timestamp';
          final response = await http.get(Uri.parse(cdnUrl)).timeout(const Duration(seconds: 5));
          if (response.statusCode == 200 && response.body.isNotEmpty) {
            final cdnRates = await _parseAsync(response.body);
            if (cdnRates.length >= 5000) {
              liveGovRates = cdnRates;
            }
          }
        } catch (_) {}
      }

      // Merge live records into master cache without dropping any existing crops
      if (liveGovRates.isNotEmpty) {
        allRates = _mergeRecords(allRates, liveGovRates);
        _cachedRates = allRates;
        _lastFetchTime = DateTime.now();
      }
    }

    // 3. Apply location & commodity filters locally
    var filtered = allRates;
    if (state != null && state.isNotEmpty) {
      final s = state.toLowerCase().trim();
      filtered = filtered.where((r) => r.state.toLowerCase().trim() == s || r.state.toLowerCase().contains(s)).toList();
    }
    if (district != null && district.isNotEmpty) {
      final d = district.toLowerCase().trim();
      filtered = filtered.where((r) => r.district.toLowerCase().trim() == d || r.district.toLowerCase().contains(d) || d.contains(r.district.toLowerCase().trim())).toList();
    }
    if (market != null && market.isNotEmpty) {
      final m = market.toLowerCase().trim();
      filtered = filtered.where((r) => r.market.toLowerCase().contains(m) || m.contains(r.market.toLowerCase())).toList();
    }
    if (commodity != null && commodity.isNotEmpty) {
      final c = commodity.toLowerCase().trim();
      filtered = filtered.where((r) => r.commodity.toLowerCase().contains(c) || c.contains(r.commodity.toLowerCase())).toList();
    }

    if (limit > 0 && filtered.length > limit) {
      return filtered.take(limit).toList();
    }
    return filtered;
  }
}
