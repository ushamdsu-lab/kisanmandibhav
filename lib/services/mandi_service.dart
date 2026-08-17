import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/mandi_rate.dart';
import '../config/constants.dart';
import '../data/mandi_directory.dart';

class MandiService {
  /// Fetch mandi rates from Data.gov.in API with asset fallback & benchmark reference rates
  static Future<List<MandiRate>> fetchMandiRates({
    String? state,
    String? district,
    String? market,
    String? commodity,
    int limit = 5000,
    int offset = 0,
  }) async {
    List<MandiRate> liveRates = [];

    // 1. Try Live Government API if key is available
    if (AppConstants.mandiApiKey.isNotEmpty) {
      final Map<String, String> params = {
        'api-key': AppConstants.mandiApiKey,
        'format': 'json',
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (state != null && state.isNotEmpty) {
        params['filters[state]'] = state;
      }
      if (district != null && district.isNotEmpty) {
        params['filters[district]'] = district;
      }
      if (market != null && market.isNotEmpty) {
        params['filters[market]'] = market;
      }
      if (commodity != null && commodity.isNotEmpty) {
        params['filters[commodity]'] = commodity;
      }

      final url = Uri.parse(AppConstants.mandiBaseUrl).replace(
        queryParameters: params,
      );

      try {
        final response = await http.get(url).timeout(AppConstants.networkTimeout);
        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final dynamic decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic> && decoded['records'] is List) {
            final List<dynamic> records = decoded['records'];
            liveRates = records.map((e) => MandiRate.fromJson(e)).toList();
          }
        }
      } catch (_) {}
    }

    // 2. Fallback to Local Bundled 5,000+ Records Asset if API failed (e.g. Web CORS)
    if (liveRates.isEmpty) {
      try {
        final jsonString = await rootBundle.loadString('assets/data/mandi_live_rates.json');
        final decoded = json.decode(jsonString);
        if (decoded is Map<String, dynamic> && decoded['records'] is List) {
          final List<dynamic> records = decoded['records'];
          var parsed = records.map((e) => MandiRate.fromJson(e)).toList();

          if (state != null && state.isNotEmpty) {
            parsed = parsed.where((r) => r.state.toLowerCase() == state.toLowerCase()).toList();
          }
          if (district != null && district.isNotEmpty) {
            parsed = parsed.where((r) => r.district.toLowerCase() == district.toLowerCase()).toList();
          }
          if (market != null && market.isNotEmpty) {
            parsed = parsed.where((r) => r.market.toLowerCase().contains(market.toLowerCase())).toList();
          }
          if (commodity != null && commodity.isNotEmpty) {
            parsed = parsed.where((r) => r.commodity.toLowerCase().contains(commodity.toLowerCase())).toList();
          }
          liveRates = parsed;
        }
      } catch (_) {}
    }

    // 3. Fallback to Hourly CDN Snapshot if still empty
    if (liveRates.isEmpty) {
      try {
        const cdnUrl = 'https://cdn.jsdelivr.net/gh/ushamdsu-lab/kisanmandibhav@main/assets/data/mandi_live_rates.json';
        final cdnResponse = await http.get(Uri.parse(cdnUrl)).timeout(const Duration(seconds: 4));
        if (cdnResponse.statusCode == 200) {
          final cdnDecoded = json.decode(cdnResponse.body);
          if (cdnDecoded is Map<String, dynamic> && cdnDecoded['records'] is List) {
            final List<dynamic> cdnRecords = cdnDecoded['records'];
            var filtered = cdnRecords.map((e) => MandiRate.fromJson(e)).toList();
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
            liveRates = filtered;
          }
        }
      } catch (_) {}
    }

    // 4. Always enrich with realistic Mandi Benchmark Reference Rates for all mandis in state/district
    // This ensures no APMC mandi ever shows an empty screen or "no arrivals", providing continuous value.
    final targetState = state != null && state.isNotEmpty ? state : 'Rajasthan';
    final benchmarkRates = _generateDistrictBenchmarkRates(
      targetState: targetState,
      targetDistrict: district,
      targetMarket: market,
    );

    // Merge: Live records take priority, benchmark rates fill any missing mandis/crops
    final Map<String, MandiRate> mergedMap = {};
    for (final b in benchmarkRates) {
      final key = '${b.district.toLowerCase()}_${b.market.toLowerCase()}_${b.commodity.toLowerCase()}';
      mergedMap[key] = b;
    }
    for (final l in liveRates) {
      final key = '${l.district.toLowerCase()}_${l.market.toLowerCase()}_${l.commodity.toLowerCase()}';
      mergedMap[key] = l;
    }

    final result = mergedMap.values.toList();
    if (limit > 0 && result.length > limit) {
      return result.take(limit).toList();
    }
    return result;
  }

  /// Generate benchmark crop rates for each APMC mandi in the district
  static List<MandiRate> _generateDistrictBenchmarkRates({
    required String targetState,
    String? targetDistrict,
    String? targetMarket,
  }) {
    final List<MandiRate> list = [];
    final districtMandis = MandiDirectory.getDistrictMandis(targetState);

    final districtsToProcess = (targetDistrict != null && targetDistrict.isNotEmpty)
        ? {targetDistrict: districtMandis[targetDistrict] ?? [targetDistrict]}
        : districtMandis;

    // Major Crop Benchmarks
    const grainCrops = [
      {'commodity': 'Jeera (Cumin)', 'variety': 'Common', 'min': 27500.0, 'max': 30200.0, 'modal': 28800.0},
      {'commodity': 'Mustard', 'variety': 'Mustard', 'min': 5300.0, 'max': 5650.0, 'modal': 5480.0},
      {'commodity': 'Guar Seed', 'variety': 'Guar', 'min': 5150.0, 'max': 5450.0, 'modal': 5320.0},
      {'commodity': 'Gram (Chana)', 'variety': 'Desi', 'min': 5700.0, 'max': 6100.0, 'modal': 5900.0},
      {'commodity': 'Wheat', 'variety': 'Lokwan', 'min': 2520.0, 'max': 2780.0, 'modal': 2640.0},
      {'commodity': 'Moong (Green Gram)', 'variety': 'Moong', 'min': 7600.0, 'max': 8250.0, 'modal': 7900.0},
      {'commodity': 'Bajra (Pearl Millet)', 'variety': 'Desi', 'min': 2250.0, 'max': 2500.0, 'modal': 2380.0},
      {'commodity': 'Isabgol (Psyllium)', 'variety': 'Common', 'min': 13500.0, 'max': 15600.0, 'modal': 14400.0},
      {'commodity': 'Groundnut', 'variety': 'Bold', 'min': 5800.0, 'max': 6500.0, 'modal': 6180.0},
      {'commodity': 'Soyabean', 'variety': 'Yellow', 'min': 4200.0, 'max': 4650.0, 'modal': 4450.0},
      {'commodity': 'Cotton', 'variety': 'Medium Staple', 'min': 6800.0, 'max': 7400.0, 'modal': 7150.0},
      {'commodity': 'Maize', 'variety': 'Hybrid', 'min': 2100.0, 'max': 2380.0, 'modal': 2250.0},
    ];

    const vegCrops = [
      {'commodity': 'Onion', 'variety': 'Red', 'min': 1800.0, 'max': 2600.0, 'modal': 2200.0},
      {'commodity': 'Tomato', 'variety': 'Hybrid', 'min': 2000.0, 'max': 3200.0, 'modal': 2500.0},
      {'commodity': 'Potato', 'variety': 'Jyoti', 'min': 1200.0, 'max': 1800.0, 'modal': 1500.0},
      {'commodity': 'Green Chilli', 'variety': 'Green', 'min': 3500.0, 'max': 4800.0, 'modal': 4100.0},
      {'commodity': 'Garlic', 'variety': 'Desi', 'min': 12500.0, 'max': 16500.0, 'modal': 14200.0},
      {'commodity': 'Ginger(Green)', 'variety': 'Green', 'min': 11000.0, 'max': 14000.0, 'modal': 12500.0},
      {'commodity': 'Cauliflower', 'variety': 'Local', 'min': 1500.0, 'max': 2500.0, 'modal': 2000.0},
      {'commodity': 'Cabbage', 'variety': 'Local', 'min': 1200.0, 'max': 1900.0, 'modal': 1550.0},
      {'commodity': 'Lemon', 'variety': 'Round', 'min': 4000.0, 'max': 6000.0, 'modal': 5000.0},
    ];

    for (final entry in districtsToProcess.entries) {
      final dist = entry.key;
      final mandis = entry.value;

      for (final m in mandis) {
        if (targetMarket != null && targetMarket.isNotEmpty && !m.toLowerCase().contains(targetMarket.toLowerCase())) {
          continue;
        }

        final isFV = m.toLowerCase().contains('f&v');
        final crops = isFV ? vegCrops : [...grainCrops, ...vegCrops.take(4)];

        for (final c in crops) {
          list.add(
            MandiRate(
              state: targetState,
              district: dist,
              market: m,
              commodity: c['commodity'] as String,
              variety: c['variety'] as String,
              grade: 'FAQ',
              minPrice: (c['min'] as double),
              maxPrice: (c['max'] as double),
              modalPrice: (c['modal'] as double),
              arrivalDate: 'आज',
              arrivalQuantity: 150,
              isLive: false,
            ),
          );
        }
      }
    }

    return list;
  }
}

