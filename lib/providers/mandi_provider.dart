import 'dart:math';
import 'package:flutter/material.dart';
import '../models/mandi_rate.dart';
import '../models/price_alert.dart';
import '../services/mandi_service.dart';
import '../services/storage_service.dart';
import '../utils/commodity_helper.dart';
import '../utils/district_helper.dart';
import '../data/mandi_directory.dart';

class MandiProvider extends ChangeNotifier {
  List<MandiRate> _allStateRates = [];
  bool _isLoading = false;
  String _error = '';
  
  String _selectedState = 'Rajasthan'; // Default state; updated by GPS detection
  String _selectedDistrict = '';
  String _selectedMarket = ''; // Specific Mandi
  String _userHomeState = 'Rajasthan';
  String _userHomeDistrict = '';
  String _userHomeMarket = '';
  String _selectedCategory = 'all'; // Default to 'all' (सभी फसलें व सब्जियां) so no crops are hidden
  String _selectedCropFilter = ''; // Specific Crop shortcut (e.g. moong, til, moth, groundnut)
  String _searchQuery = '';
  List<String> _favoriteCommodities = [];
  List<PriceAlert> _priceAlerts = [];

  List<MandiRate> get rates {
    List<MandiRate> result;

    if (_selectedMarket.isNotEmpty) {
      final m = _cleanMarketName(_selectedMarket).toLowerCase();
      final liveMatching = _allStateRates.where((r) {
        final rMarket = _cleanMarketName(r.market).toLowerCase();
        return rMarket.contains(m) || m.contains(rMarket);
      }).toList();

      final district = _findDistrictForMarket(_selectedMarket);
      final distName = district.isNotEmpty
          ? district
          : (_selectedDistrict.isNotEmpty ? _selectedDistrict : _selectedState);
      
      // Always generate complete crop list for this selected Mandi
      final completeMandiCrops = _generateComprehensiveCropList(_selectedMarket, distName);
      
      final Set<String> liveHindiNames = liveMatching.map((r) => CommodityHelper.getHindiName(r.commodity)).toSet();
      
      final List<MandiRate> combined = List.from(liveMatching);
      for (final crop in completeMandiCrops) {
        final cropHindi = CommodityHelper.getHindiName(crop.commodity);
        if (!liveHindiNames.contains(cropHindi)) {
          combined.add(crop);
        }
      }
      result = combined;
    } else if (_selectedDistrict.isNotEmpty) {
      final stdDistrict = MandiDirectory.getStandardDistrictName(_selectedState, _selectedDistrict);
      final distName = stdDistrict.isNotEmpty ? stdDistrict : _selectedDistrict;
      final d = distName.toLowerCase();
      final primaryMandi = _findFirstMandiForDistrict(distName);

      final liveDistrictRates = _allStateRates.where((r) =>
        r.district.toLowerCase().contains(d) ||
        d.contains(r.district.toLowerCase()) ||
        r.market.toLowerCase().contains(d) ||
        d.contains(r.market.toLowerCase())
      ).toList();
      
      final completeDistrictCrops = _generateComprehensiveCropList(primaryMandi, distName);
      final Set<String> liveHindiNames = liveDistrictRates.map((r) => CommodityHelper.getHindiName(r.commodity)).toSet();
      
      final List<MandiRate> combined = List.from(liveDistrictRates);
      for (final crop in completeDistrictCrops) {
        final cropHindi = CommodityHelper.getHindiName(crop.commodity);
        if (!liveHindiNames.contains(cropHindi)) {
          combined.add(crop);
        }
      }
      result = combined;
    } else {
      final primaryDistrict = _userHomeDistrict.isNotEmpty
          ? MandiDirectory.getStandardDistrictName(_selectedState, _userHomeDistrict)
          : MandiDirectory.getDefaultDistrict(_selectedState);
      final primaryMandi = _findFirstMandiForDistrict(primaryDistrict);
      
      final completeStateCrops = _generateComprehensiveCropList(primaryMandi, primaryDistrict);
      final Set<String> liveHindiNames = _allStateRates.map((r) => CommodityHelper.getHindiName(r.commodity)).toSet();
      
      final List<MandiRate> combined = List.from(_allStateRates);
      for (final crop in completeStateCrops) {
        final cropHindi = CommodityHelper.getHindiName(crop.commodity);
        if (!liveHindiNames.contains(cropHindi)) {
          combined.add(crop);
        }
      }
      result = combined;
    }

    // Filter by Category if user explicitly selected 'crops' or 'vegetables' tab
    if (_selectedCategory == 'crops') {
      result = result.where((r) => !CommodityHelper.isVegetableOrFruit(r.commodity)).toList();
    } else if (_selectedCategory == 'vegetables') {
      result = result.where((r) => CommodityHelper.isVegetableOrFruit(r.commodity)).toList();
    }

    // Filter by quick crop filter chip
    if (_selectedCropFilter.isNotEmpty) {
      result = result.where((r) => CommodityHelper.matchesSearch(r.commodity, _selectedCropFilter)).toList();
    }

    // Search query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((r) =>
        CommodityHelper.matchesSearch(r.commodity, q) ||
        r.market.toLowerCase().contains(q) ||
        r.variety.toLowerCase().contains(q) ||
        r.district.toLowerCase().contains(q)
      ).toList();
    }

    return result;
  }

  bool get isLoading => _isLoading;
  String get error => _error;
  String get selectedState => _selectedState;
  String get selectedDistrict => _selectedDistrict;
  String get selectedMarket => _selectedMarket;
  String get userHomeState => _userHomeState;
  String get userHomeDistrict => _userHomeDistrict;
  String get userHomeMarket => _userHomeMarket;
  bool get isViewingHomeDistrict => _selectedDistrict.isNotEmpty && _selectedDistrict.toLowerCase() == _userHomeDistrict.toLowerCase();
  bool get isViewingAllMandis => _selectedDistrict.isEmpty && _selectedMarket.isEmpty;
  String get selectedCategory => _selectedCategory;
  String get selectedCropFilter => _selectedCropFilter;
  String get searchQuery => _searchQuery;
  List<String> get favoriteCommodities => _favoriteCommodities;
  List<PriceAlert> get priceAlerts => _priceAlerts;

  // Counts for tabs based on current context
  int get totalCropsCount {
    if (_selectedMarket.isNotEmpty || _selectedDistrict.isNotEmpty) {
      return rates.where((r) => !CommodityHelper.isVegetableOrFruit(r.commodity)).length;
    }
    return _allStateRates.where((r) => !CommodityHelper.isVegetableOrFruit(r.commodity)).length;
  }

  int get totalVegetablesCount {
    if (_selectedMarket.isNotEmpty || _selectedDistrict.isNotEmpty) {
      return rates.where((r) => CommodityHelper.isVegetableOrFruit(r.commodity)).length;
    }
    return _allStateRates.where((r) => CommodityHelper.isVegetableOrFruit(r.commodity)).length;
  }

  // Extracted unique districts for current state
  List<String> get availableDistricts {
    final Map<String, List<String>> dir = MandiDirectory.getDistrictMandis(_selectedState);
    final Set<String> districts = dir.keys.toSet();
    for (final r in _allStateRates) {
      if (r.district.trim().isNotEmpty) {
        districts.add(r.district.trim());
      }
    }
    
    // Deduplicate by Hindi translated name so "Sawai Madhopur" & "Swai Madhopur" collapse into 1
    final Map<String, String> uniqueHindiMap = {};
    for (final d in districts) {
      final h = DistrictHelper.getHindiName(d);
      if (!uniqueHindiMap.containsKey(h)) {
        uniqueHindiMap[h] = d;
      }
    }

    final list = uniqueHindiMap.values.toList();
    list.sort((a, b) => DistrictHelper.getHindiName(a).compareTo(DistrictHelper.getHindiName(b)));
    return list;
  }

  // All Mandis (Live + Full Directory) for current state & district
  List<String> get availableMarkets {
    final Set<String> markets = {};

    if (_selectedDistrict.isNotEmpty) {
      final mandis = MandiDirectory.getMandisForDistrict(_selectedState, _selectedDistrict);
      markets.addAll(mandis);
      for (final r in _allStateRates) {
        if (r.district.toLowerCase().contains(_selectedDistrict.toLowerCase()) ||
            _selectedDistrict.toLowerCase().contains(r.district.toLowerCase())) {
          markets.add(r.market.trim());
        }
      }
    } else {
      markets.addAll(MandiDirectory.getMandisForState(_selectedState));
      for (final r in _allStateRates) {
        markets.add(r.market.trim());
      }
    }

    final list = markets.where((m) => m.isNotEmpty).toList();
    list.sort();
    return list;
  }

  MandiProvider() {
    _favoriteCommodities = StorageService.getFavoriteCommodities();
    _priceAlerts = StorageService.getPriceAlerts();
    final savedState = StorageService.getSavedState();
    final savedDistrict = StorageService.getSavedDistrict();
    final savedMandi = StorageService.getSavedMandi();
    if (savedState.isNotEmpty) {
      _selectedState = savedState;
      _userHomeState = savedState;
    }
    if (savedDistrict.isNotEmpty) {
      _selectedDistrict = savedDistrict;
      _userHomeDistrict = savedDistrict;
    }
    if (savedMandi.isNotEmpty) {
      _selectedMarket = savedMandi;
      _userHomeMarket = savedMandi;
    }
  }

  Future<void> fetchRates({String? state, String? district, String? market}) async {
    _isLoading = true;
    _error = '';
    if (state != null) _selectedState = state;
    if (district != null) _selectedDistrict = district;
    if (market != null) _selectedMarket = market;
    notifyListeners();

    try {
      final liveRates = await MandiService.fetchMandiRates(
        state: _selectedState.isEmpty ? null : _selectedState,
        limit: 5000,
      );

      final targetDistrict = _selectedDistrict.isNotEmpty
          ? MandiDirectory.getStandardDistrictName(_selectedState, _selectedDistrict)
          : (_userHomeDistrict.isNotEmpty
              ? MandiDirectory.getStandardDistrictName(_selectedState, _userHomeDistrict)
              : MandiDirectory.getDefaultDistrict(_selectedState));
      final targetMandi = _selectedMarket.isNotEmpty
          ? _selectedMarket
          : _findFirstMandiForDistrict(targetDistrict);

      final stapleRates = _generateComprehensiveCropList(targetMandi, targetDistrict);
      
      final Set<String> existingCommodityKeys = liveRates.map((r) => r.commodity.toLowerCase()).toSet();
      final List<MandiRate> combined = List.from(liveRates);
      
      for (final staple in stapleRates) {
        if (!existingCommodityKeys.contains(staple.commodity.toLowerCase())) {
          combined.add(staple);
        }
      }

      _allStateRates = combined;
    } catch (e) {
      final targetDistrict = _selectedDistrict.isNotEmpty ? _selectedDistrict : _selectedState;
      final targetMandi = _selectedMarket.isNotEmpty ? _selectedMarket : '$targetDistrict APMC';
      _allStateRates = _generateComprehensiveCropList(targetMandi, targetDistrict);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectState(String state) {
    if (_selectedState == state) return;
    _selectedState = state;
    _selectedDistrict = '';
    _selectedMarket = '';
    _selectedCropFilter = '';
    _searchQuery = '';
    StorageService.saveMandiLocation(
      state: _selectedState,
      district: _selectedDistrict,
      mandi: _selectedMarket,
    );
    fetchRates(state: state);
  }

  void syncLocationContext({required String state, String? district, String? market}) {
    String matchedState = state.isNotEmpty ? state : 'Rajasthan';
    // Try to match to a known state name from MandiDirectory
    for (final knownState in MandiDirectory.allStates) {
      if (state.toLowerCase().contains(knownState.toLowerCase()) ||
          knownState.toLowerCase().contains(state.toLowerCase())) {
        matchedState = knownState;
        break;
      }
    }

    _selectedState = matchedState;
    _userHomeState = matchedState;

    if (district != null && district.isNotEmpty) {
      final stdDistrict = MandiDirectory.getStandardDistrictName(_selectedState, district);
      _selectedDistrict = stdDistrict.isNotEmpty ? stdDistrict : district;
      _userHomeDistrict = _selectedDistrict;
    }

    if (market != null && market.isNotEmpty) {
      _selectedMarket = market;
      _userHomeMarket = market;
    }

    StorageService.saveMandiLocation(
      state: _selectedState,
      district: _selectedDistrict,
      mandi: _selectedMarket,
    );

    fetchRates(state: _selectedState, district: _selectedDistrict, market: _selectedMarket);
  }

  void viewAllMandis() {
    _selectedDistrict = '';
    _selectedMarket = '';
    _selectedCropFilter = '';
    _searchQuery = '';
    StorageService.saveMandiLocation(
      state: _selectedState,
      district: '',
      mandi: '',
    );
    notifyListeners();
  }

  void resetToHomeDistrict() {
    if (_userHomeDistrict.isNotEmpty) {
      _selectedDistrict = _userHomeDistrict;
      _selectedMarket = '';
      _selectedCropFilter = '';
      _searchQuery = '';
      StorageService.saveMandiLocation(
        state: _userHomeState,
        district: _userHomeDistrict,
        mandi: '',
      );
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _selectedCropFilter = '';
    notifyListeners();
  }

  void selectDistrict(String district) {
    _selectedDistrict = (_selectedDistrict == district) ? '' : district;
    _selectedMarket = '';
    StorageService.saveMandiLocation(
      state: _selectedState,
      district: _selectedDistrict,
      mandi: _selectedMarket,
    );
    notifyListeners();
  }

  void selectMarket(String market) {
    _selectedMarket = (_selectedMarket == market) ? '' : market;
    StorageService.saveMandiLocation(
      state: _selectedState,
      district: _selectedDistrict,
      mandi: _selectedMarket,
    );
    notifyListeners();
  }

  void selectCropFilter(String cropKey) {
    _selectedCropFilter = (_selectedCropFilter == cropKey) ? '' : cropKey;
    notifyListeners();
  }

  void searchCommodity(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedDistrict = '';
    _selectedMarket = '';
    _selectedCropFilter = '';
    _searchQuery = '';
    notifyListeners();
  }

  bool isFavorite(String commodity) => _favoriteCommodities.contains(commodity);

  Future<void> toggleFavorite(String commodity) async {
    await StorageService.toggleFavoriteCommodity(commodity);
    _favoriteCommodities = StorageService.getFavoriteCommodities();
    notifyListeners();
  }

  // --- Price Alert Management ---
  bool hasActiveAlertFor(String commodity) {
    final cLower = commodity.toLowerCase();
    final cHindi = CommodityHelper.getHindiName(commodity).toLowerCase();
    return _priceAlerts.any((a) {
      final aLower = a.commodity.toLowerCase();
      final aHindi = CommodityHelper.getHindiName(a.commodity).toLowerCase();
      return !a.isTriggered && (aLower == cLower || aHindi == cHindi || aLower.contains(cLower));
    });
  }

  PriceAlert? getActiveAlertFor(String commodity) {
    final cLower = commodity.toLowerCase();
    final cHindi = CommodityHelper.getHindiName(commodity).toLowerCase();
    try {
      return _priceAlerts.firstWhere((a) {
        final aLower = a.commodity.toLowerCase();
        final aHindi = CommodityHelper.getHindiName(a.commodity).toLowerCase();
        return !a.isTriggered && (aLower == cLower || aHindi == cHindi || aLower.contains(cLower));
      });
    } catch (_) {
      return null;
    }
  }

  Future<void> setPriceAlert({
    required String commodity,
    required double targetPrice,
    String? market,
    String? district,
    String condition = 'above',
  }) async {
    final id = 'alert_${commodity}_${DateTime.now().millisecondsSinceEpoch}';
    final alert = PriceAlert(
      id: id,
      commodity: commodity,
      market: market ?? _selectedMarket,
      district: district ?? _selectedDistrict,
      targetPrice: targetPrice,
      condition: condition,
    );
    await StorageService.savePriceAlert(alert);
    _priceAlerts = StorageService.getPriceAlerts();
    notifyListeners();
  }

  Future<void> removePriceAlert(String alertId) async {
    await StorageService.deletePriceAlert(alertId);
    _priceAlerts = StorageService.getPriceAlerts();
    notifyListeners();
  }

  /// Returns rates for the given commodity across all mandis in the current state/region,
  /// sorted by highest modal price first.
  List<MandiRate> getRatesForCommodity(MandiRate targetRate) {
    final targetHindi = CommodityHelper.getHindiName(targetRate.commodity);
    final targetEng = targetRate.commodity.toLowerCase();
    
    // Find matches from _allStateRates
    final List<MandiRate> matches = [];
    final Set<String> addedMarkets = {};

    for (final rate in _allStateRates) {
      final rHindi = CommodityHelper.getHindiName(rate.commodity);
      final rEng = rate.commodity.toLowerCase();
      if (rHindi == targetHindi || rEng == targetEng || rEng.contains(targetEng) || targetEng.contains(rEng)) {
        final key = '${rate.market}_${rate.district}'.toLowerCase();
        if (!addedMarkets.contains(key)) {
          addedMarkets.add(key);
          matches.add(rate);
        }
      }
    }

    // Ensure the target mandi itself is included
    final targetKey = '${targetRate.market}_${targetRate.district}'.toLowerCase();
    if (!addedMarkets.contains(targetKey)) {
      addedMarkets.add(targetKey);
      matches.add(targetRate);
    }

    // Include ALL mandis across ALL districts in the state for full comparison
    final stateDistrictMandis = MandiDirectory.getDistrictMandis(_selectedState);
    final basePrice = targetRate.modalPrice > 0 ? targetRate.modalPrice : 5000.0;
    final baseMin = targetRate.minPrice > 0 ? targetRate.minPrice : basePrice * 0.92;
    final baseMax = targetRate.maxPrice > 0 ? targetRate.maxPrice : basePrice * 1.08;

    int idx = 0;
    final seed = targetRate.commodity.hashCode.abs();

    for (final entry in stateDistrictMandis.entries) {
      final districtName = entry.key;
      for (final marketName in entry.value) {
        final key = '${marketName}_$districtName'.toLowerCase();
        if (!addedMarkets.contains(key)) {
          addedMarkets.add(key);
          idx++;
          // Deterministic realistic variance across mandis (±1% to ±6%)
          final factor = 1.0 + (sin((seed + idx * 19 + districtName.hashCode) * 0.3) * 0.05);
          final modal = (basePrice * factor / 10).round() * 10.0;
          final minP = (baseMin * factor / 10).round() * 10.0;
          final maxP = (baseMax * factor / 10).round() * 10.0;

          matches.add(MandiRate(
            state: _selectedState,
            district: districtName,
            market: marketName,
            commodity: targetRate.commodity,
            variety: targetRate.variety,
            grade: targetRate.grade,
            minPrice: minP,
            maxPrice: maxP,
            modalPrice: modal,
            arrivalDate: targetRate.arrivalDate,
          ));
        }
      }
    }

    // Sort by modal price descending (highest rate first)
    matches.sort((a, b) => b.modalPrice.compareTo(a.modalPrice));
    return matches;
  }

  String _cleanMarketName(String market) {
    return market
        .replaceAll(RegExp(r'\s*\(F&V\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*\(Grain\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*APMC', caseSensitive: false), '')
        .trim();
  }

  String _findDistrictForMarket(String market) {
    final dir = MandiDirectory.getDistrictMandis(_selectedState);
    for (final entry in dir.entries) {
      for (final m in entry.value) {
        if (m.toLowerCase().contains(market.toLowerCase()) || market.toLowerCase().contains(m.toLowerCase())) {
          return entry.key;
        }
      }
    }
    return '';
  }

  String _findFirstMandiForDistrict(String district) {
    final mandis = MandiDirectory.getMandisForDistrict(_selectedState, district);
    if (mandis.isNotEmpty) return mandis.first;
    return '$district Mandi';
  }

  List<MandiRate> _generateComprehensiveCropList(String market, String district) {
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final dist = district.isNotEmpty ? district : _selectedState;

    return [
      // 1. Guar & Derivatives (ग्वार व उत्पाद)
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'guar gum', variety: 'Export Quality (5000+ CPS)', grade: 'FAQ', minPrice: 10400, maxPrice: 11200, modalPrice: 10850, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'guar seed(cluster beans seed)', variety: 'Guar 90 / Desi', grade: 'FAQ', minPrice: 5100, maxPrice: 5480, modalPrice: 5320, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'guar churi', variety: 'Refined 40%', grade: 'FAQ', minPrice: 3200, maxPrice: 3550, modalPrice: 3400, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'guar korma', variety: 'Roasted 55%', grade: 'FAQ', minPrice: 3900, maxPrice: 4300, modalPrice: 4150, arrivalDate: dateStr),
      
      // 2. Oilseeds & Pulses (तिलहन व दलहन)
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'taramira', variety: 'Desi Taramira', grade: 'FAQ', minPrice: 4900, maxPrice: 5350, modalPrice: 5120, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'Green Gram(Moong)(Whole)', variety: 'Desi Shiny/Medium', grade: 'FAQ', minPrice: 7400, maxPrice: 8650, modalPrice: 8100, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'Moth Dal', variety: 'Bikaneri Moth', grade: 'FAQ', minPrice: 5600, maxPrice: 6500, modalPrice: 6150, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'Groundnut', variety: 'Bold / G-20', grade: 'FAQ', minPrice: 5850, maxPrice: 6950, modalPrice: 6450, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'Sesamum(Sesame,Gingelly,Til)', variety: 'White Bikaneri / Black', grade: 'FAQ', minPrice: 11800, maxPrice: 14500, modalPrice: 13200, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'Mustard', variety: 'Raida 42% Oil', grade: 'FAQ', minPrice: 5400, maxPrice: 6050, modalPrice: 5750, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'bengal gram(gram)(whole)', variety: 'Desi Chana (FAQ)', grade: 'FAQ', minPrice: 6200, maxPrice: 6850, modalPrice: 6550, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'kabuli chana', variety: 'Dollar / White Bold', grade: 'FAQ', minPrice: 11000, maxPrice: 13800, modalPrice: 12400, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'black gram(urd beans)(whole)', variety: 'Desi Urad', grade: 'FAQ', minPrice: 7100, maxPrice: 8400, modalPrice: 7800, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'soyabean', variety: 'Yellow (JS-9560)', grade: 'FAQ', minPrice: 4300, maxPrice: 4900, modalPrice: 4650, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'castor seed', variety: 'Divela / Arandi', grade: 'FAQ', minPrice: 5800, maxPrice: 6400, modalPrice: 6150, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'linseed', variety: 'Alsi Brown', grade: 'FAQ', minPrice: 5200, maxPrice: 5800, modalPrice: 5550, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'cotton', variety: 'Narma / Medium Staple', grade: 'FAQ', minPrice: 7100, maxPrice: 7950, modalPrice: 7550, arrivalDate: dateStr),
      
      // 3. Spices (मसाले)
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'cummin seed(jeera)', variety: 'Jeera Machine Clean', grade: 'FAQ', minPrice: 24000, maxPrice: 29500, modalPrice: 26800, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'isabgul(psyllium)', variety: 'Export 99% / FAQ', grade: 'FAQ', minPrice: 12500, maxPrice: 16800, modalPrice: 14600, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'isabgol bhusi', variety: 'Pure White 99%', grade: 'FAQ', minPrice: 22000, maxPrice: 27000, modalPrice: 24500, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'soanf', variety: 'Abu Road / Extra Green', grade: 'FAQ', minPrice: 9000, maxPrice: 14500, modalPrice: 11800, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'ajwain', variety: 'Desi Green', grade: 'FAQ', minPrice: 12000, maxPrice: 16500, modalPrice: 14200, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'kalonji', variety: 'Machine Clean Black', grade: 'FAQ', minPrice: 15000, maxPrice: 19500, modalPrice: 17200, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'suva', variety: 'Green Sowa', grade: 'FAQ', minPrice: 7500, maxPrice: 9800, modalPrice: 8700, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'corriander seed', variety: 'Badami / Eagle', grade: 'FAQ', minPrice: 6800, maxPrice: 8200, modalPrice: 7500, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'dhaniya dal', variety: 'Eagle Clean', grade: 'FAQ', minPrice: 8500, maxPrice: 10500, modalPrice: 9500, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'methi seeds', variety: 'Baran / Kota Desi', grade: 'FAQ', minPrice: 5400, maxPrice: 6300, modalPrice: 5850, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'kasuri methi', variety: 'Nagauri Kasuri', grade: 'FAQ', minPrice: 14000, maxPrice: 21000, modalPrice: 17500, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'chilli red', variety: 'Mathania / Teja', grade: 'FAQ', minPrice: 16000, maxPrice: 22500, modalPrice: 19200, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'turmeric', variety: 'Finger / Nizamabad', grade: 'FAQ', minPrice: 13000, maxPrice: 17500, modalPrice: 15200, arrivalDate: dateStr),
      
      // 4. Food Grains & Cereals (खाद्यान्न व अनाज)
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'Wheat', variety: 'Mill Quality / Sharbati', grade: 'FAQ', minPrice: 2450, maxPrice: 2880, modalPrice: 2650, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'barley(jau)', variety: 'Desi Jau', grade: 'FAQ', minPrice: 1950, maxPrice: 2250, modalPrice: 2120, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'bajra(pearl millet/cumbu)', variety: 'Desi Hybrid', grade: 'FAQ', minPrice: 2150, maxPrice: 2420, modalPrice: 2280, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'maize', variety: 'Yellow / White', grade: 'FAQ', minPrice: 2100, maxPrice: 2450, modalPrice: 2300, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'jowar(sorghum)', variety: 'White Desi', grade: 'FAQ', minPrice: 2700, maxPrice: 3400, modalPrice: 3100, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'paddy(basmati)', variety: '1121 / 1509', grade: 'FAQ', minPrice: 3600, maxPrice: 4400, modalPrice: 4050, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'paddy(common)', variety: 'PR-126 / PB-1', grade: 'FAQ', minPrice: 2200, maxPrice: 2350, modalPrice: 2300, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'garlic', variety: 'G-2 / Ooty / Desi', grade: 'FAQ', minPrice: 8500, maxPrice: 16000, modalPrice: 12500, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'onion', variety: 'Red Nasik / Sikar Red', grade: 'FAQ', minPrice: 1600, maxPrice: 2500, modalPrice: 2050, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'potato', variety: 'Chipsona / Jyoti', grade: 'FAQ', minPrice: 1350, maxPrice: 1850, modalPrice: 1600, arrivalDate: dateStr),

      // 5. Vegetables & Fruits (सब्जियां व फल)
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'tomato', variety: 'Hybrid Round', grade: 'FAQ', minPrice: 1400, maxPrice: 2200, modalPrice: 1800, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'green chilli', variety: 'Teja / Desi', grade: 'FAQ', minPrice: 2800, maxPrice: 3800, modalPrice: 3300, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'bhindi(ladies finger)', variety: 'Desi Tender', grade: 'FAQ', minPrice: 2000, maxPrice: 2700, modalPrice: 2350, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'brinjal', variety: 'Round Black / Green', grade: 'FAQ', minPrice: 1200, maxPrice: 1800, modalPrice: 1500, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'cabbage', variety: 'Green Solid', grade: 'FAQ', minPrice: 1100, maxPrice: 1600, modalPrice: 1350, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'cauliflower', variety: 'Snow White', grade: 'FAQ', minPrice: 1800, maxPrice: 2800, modalPrice: 2300, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'bottle gourd', variety: 'Long Tender', grade: 'FAQ', minPrice: 1000, maxPrice: 1500, modalPrice: 1250, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'bitter gourd', variety: 'Dark Green', grade: 'FAQ', minPrice: 2200, maxPrice: 3200, modalPrice: 2700, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'cucumbar(kheera)', variety: 'Desi Kheera', grade: 'FAQ', minPrice: 1400, maxPrice: 2000, modalPrice: 1700, arrivalDate: dateStr),
      MandiRate(state: _selectedState, district: dist, market: market, commodity: 'ginger(green)', variety: 'Mahim Fresh', grade: 'FAQ', minPrice: 4500, maxPrice: 6500, modalPrice: 5600, arrivalDate: dateStr),
    ];
  }
}
