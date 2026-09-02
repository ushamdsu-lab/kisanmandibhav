import '../models/scheme.dart';

class SchemeApiService {
  /// Fetch live schemes from remote updates if available
  static Future<List<Scheme>> fetchLiveSchemes() async {
    // Only genuine official schemes from assets/data/schemes.json are used.
    // Preventing mapping of mandi commodity rates into pseudo-schemes.
    return [];
  }
}
