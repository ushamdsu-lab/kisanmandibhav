import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/mandi_rate.dart';
import '../config/constants.dart';

class MandiService {
  /// Fetch mandi rates from Data.gov.in API with timeout & error handling
  static Future<List<MandiRate>> fetchMandiRates({
    String? state,
    String? district,
    String? market,
    String? commodity,
    int limit = 500,
    int offset = 0,
  }) async {
    if (AppConstants.mandiApiKey.isEmpty) {
      throw Exception('मंडी API Key उपलब्ध नहीं है। कृपया सेटिंग्स जांचें।');
    }

    // Build query params
    final Map<String, String> params = {
      'api-key': AppConstants.mandiApiKey,
      'format': 'json',
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    // Add filters in Data.gov.in format
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

      if (response.statusCode != 200) {
        throw Exception('सरकारी सर्वर रिस्पांस त्रुटि (${response.statusCode})');
      }

      if (response.body.isEmpty) {
        return [];
      }

      final dynamic decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return [];
      }

      final List<dynamic> records = decoded['records'] ?? [];
      return records.map((e) => MandiRate.fromJson(e)).toList();
    } catch (_) {
      // Fallback to Hourly jsDelivr CDN Snapshot if direct API fails or times out
      try {
        const cdnUrl = 'https://cdn.jsdelivr.net/gh/ushamdsu-lab/kisanmandibhav@main/assets/data/mandi_live_rates.json';
        final cdnResponse = await http.get(Uri.parse(cdnUrl)).timeout(const Duration(seconds: 4));
        if (cdnResponse.statusCode == 200) {
          final cdnDecoded = json.decode(cdnResponse.body);
          if (cdnDecoded is Map<String, dynamic> && cdnDecoded['records'] != null) {
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
            if (filtered.isNotEmpty) {
              return filtered.take(limit).toList();
            }
          }
        }
      } catch (_) {}

      return [];
    }
  }
}
