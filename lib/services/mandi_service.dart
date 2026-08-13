import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mandi_rate.dart';
import '../config/constants.dart';

class MandiService {
  /// Fetch mandi rates from Data.gov.in API
  static Future<List<MandiRate>> fetchMandiRates({
    String? state,
    String? district,
    String? market,
    String? commodity,
    int limit = 500,
    int offset = 0,
  }) async {
    if (AppConstants.mandiApiKey.isEmpty) {
      throw Exception('Mandi API key set nahi hai. Settings mein API key daalein.');
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

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('मंडी डेटा प्राप्त करने में त्रुटि: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final List<dynamic> records = data['records'] ?? [];

    return records.map((e) => MandiRate.fromJson(e)).toList();
  }
}
