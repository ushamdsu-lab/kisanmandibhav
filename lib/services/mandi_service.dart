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
      return records.map((e) {
        final r = MandiRate.fromJson(e);
        return MandiRate(
          state: r.state,
          district: r.district,
          market: r.market,
          commodity: r.commodity,
          variety: r.variety,
          grade: r.grade,
          minPrice: r.minPrice,
          maxPrice: r.maxPrice,
          modalPrice: r.modalPrice,
          arrivalDate: r.arrivalDate,
          isLive: true, // Verified from live API
        );
      }).toList();
    } on TimeoutException {
      throw Exception('सर्वर से संपर्क समय समाप्त (Timeout) हो गया। कृपया इंटरनेट जांचें।');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('मंडी डेटा लोड करने में समस्या: $e');
    }
  }
}
