import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/scheme.dart';

class SchemeApiService {
  static const String _apiEndpoint = 'https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070';
  
  static Future<List<Scheme>> fetchLiveSchemes() async {
    try {
      final response = await http.get(Uri.parse(_apiEndpoint)).timeout(
        const Duration(seconds: 4),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['records'] != null) {
          final List<dynamic> records = data['records'];
          return records.map((r) => _mapApiRecordToScheme(r)).toList();
        }
      }
    } catch (_) {
      // Fallback
    }
    return [];
  }

  static Scheme _mapApiRecordToScheme(Map<String, dynamic> r) {
    final state = r['state'] ?? 'Rajasthan';
    final name = r['commodity'] ?? r['scheme_name'] ?? 'कृषि प्रोत्साहन योजना';
    return Scheme(
      id: 'live_${r.hashCode}',
      name: name,
      nameEn: name,
      governmentType: state == 'All India' ? 'central' : 'state',
      stateName: state,
      badgeText: state == 'All India' || state.isEmpty ? '🏛️ केंद्र सरकार' : '🌾 $state सरकार',
      category: 'कृषि सब्सिडी',
      categoryEn: 'Subsidy',
      icon: 'agriculture',
      description: '${r['market'] ?? name} में किसानों के लिए सरकारी प्रोत्साहन व डीबीटी सहायता।',
      eligibility: ['$state का मूल निवासी कृषक', 'खेती योग्य भूमि स्वामी'],
      benefits: ['सरकारी डीबीटी सब्सिडी', 'सीधा बैंक खाते में भुगतान'],
      howToApply: 'कृषि विभाग या राज्य किसान पोर्टल से ऑनलाइन आवेदन करें',
      website: 'https://agricoop.nic.in',
      documents: ['आधार कार्ड', 'जमीन खतौनी', 'जनाधार/समग्र आईडी'],
    );
  }
}
