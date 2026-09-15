import 'dart:io';
import 'dart:convert';
import 'package:kisan_mitra/data/mandi_directory.dart';
import 'package:kisan_mitra/models/mandi_rate.dart';

String _cleanMarketName(String market) {
  return market
      .replaceAll(RegExp(r'The Agricultural Produce Market Committee-?', caseSensitive: false), '')
      .replaceAll(RegExp(r'Agricultural Produce Market Committee-?', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*\(F&V\)', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*\(Grain\)', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*\(Sayajigunj\)', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*\(Jamalpur\)', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*\(Veg\.?market\s*[^)]*\)', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*\(Veg\.?Sub Yard\)', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*APMC', caseSensitive: false), '')
      .trim();
}

void main() {
  final file = File('assets/data/mandi_live_rates.json');
  final dynamic json = jsonDecode(file.readAsStringSync());
  final List records = json['records'];
  final List<MandiRate> allRates = records.map((e) => MandiRate.fromJson(e)).toList();

  final testStates = ['Gujarat', 'Rajasthan', 'Madhya Pradesh', 'Uttar Pradesh', 'Maharashtra', 'Punjab', 'Haryana'];

  print('=== VALIDATING DISTRICTS & MANDIS ACROSS STATES ===');
  for (final state in testStates) {
    final stateRates = allRates.where((r) => r.state.toLowerCase() == state.toLowerCase()).toList();
    final dirDistricts = MandiDirectory.getDistrictMandis(state);
    
    print('\n🏛️ State: $state (${stateRates.length} total bhav records)');
    print('   Total Districts in Directory: ${dirDistricts.length}');
    
    for (final distEntry in dirDistricts.entries.take(4)) {
      final district = distEntry.key;
      final expectedMandis = distEntry.value;
      
      final dClean = district.toLowerCase();
      final distRates = stateRates.where((r) {
        final rDist = r.district.toLowerCase();
        return rDist == dClean || rDist.contains(dClean) || dClean.contains(rDist);
      }).toList();

      print('   👉 District: $district (${expectedMandis.length} mandis: ${expectedMandis.join(", ")})');
      print('      District total crops in dataset: ${distRates.length}');
      
      for (final market in expectedMandis.take(3)) {
        final m = _cleanMarketName(market).toLowerCase();
        final marketRates = stateRates.where((r) {
          final rMarket = _cleanMarketName(r.market).toLowerCase();
          return rMarket == m || rMarket.contains(m) || m.contains(rMarket);
        }).toList();
        print('         🏪 Mandi: $market -> ${marketRates.length} crops found (${marketRates.map((r) => r.commodity).take(4).join(", ")}...)');
      }
    }
  }
}
