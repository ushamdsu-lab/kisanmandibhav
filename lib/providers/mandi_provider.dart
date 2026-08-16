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
  List<MandiRate> _displayRates = [];
  bool _isLoading = false;
  bool _isOffline = false;
  String _error = '';
  
  String _selectedState = 'Rajasthan'; // Default state; updated by GPS detection
  String _selectedDistrict = '';
  String _selectedMarket = ''; // Specific Mandi
  String _userHomeState = 'Rajasthan';
  String _userHomeDistrict = '';
  String _userHomeMarket = '';
  String _selectedCategory = 'all'; // 'all', 'crops', 'vegetables'
  String _selectedCropFilter = ''; // Specific Crop shortcut
  String _searchQuery = '';
  List<String> _favoriteCommodities = [];
  List<PriceAlert> _priceAlerts = [];

  MandiProvider() {
    _loadSavedPreferences();
  }

  void _loadSavedPreferences() {
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

    _favoriteCommodities = StorageService.getFavoriteCommodities();
    _priceAlerts = StorageService.getPriceAlerts();

    // Load initial offline cache if available
    final cached = StorageService.getCachedMandiRates(_selectedState);
    if (cached.isNotEmpty) {
      _allStateRates = cached;
      _isOffline = true;
      _recomputeDisplayRates();
    }
  }

  // Pre-computed, instantaneous 60 FPS getter
  List<MandiRate> get rates => _displayRates;

  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
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
  String get lastSyncTime => StorageService.getMandiLastSyncTime(_selectedState);

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
    final state = _selectedState.isNotEmpty ? _selectedState : (_userHomeState.isNotEmpty ? _userHomeState : 'Rajasthan');
    final Map<String, List<String>> dir = MandiDirectory.getDistrictMandis(state);
    final Set<String> districts = dir.keys.toSet();
    for (final r in _allStateRates) {
      if (r.district.trim().isNotEmpty) {
        districts.add(r.district.trim());
      }
    }
    
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

  // All Mandis for current state & district
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

      if (liveRates.isNotEmpty) {
        _allStateRates = liveRates;
        _isOffline = false;
        StorageService.saveCachedMandiRates(_selectedState, liveRates);
      } else {
        final cached = StorageService.getCachedMandiRates(_selectedState);
        if (cached.isNotEmpty) {
          _allStateRates = cached;
          _isOffline = true;
        } else {
          _allStateRates = [];
          _isOffline = false;
        }
      }
    } catch (e) {
      // Offline fallback: load from cached rates if available
      final cached = StorageService.getCachedMandiRates(_selectedState);
      if (cached.isNotEmpty) {
        _allStateRates = cached;
        _isOffline = true;
      } else {
        _allStateRates = [];
        _isOffline = true;
      }
      _error = '';
    } finally {
      _isLoading = false;
      _recomputeDisplayRates();
      notifyListeners();
    }
  }

  void _recomputeDisplayRates() {
    List<MandiRate> result;

    if (_selectedMarket.isNotEmpty) {
      final m = _cleanMarketName(_selectedMarket).toLowerCase();
      result = _allStateRates.where((r) {
        final rMarket = _cleanMarketName(r.market).toLowerCase();
        return rMarket.contains(m) || m.contains(rMarket);
      }).toList();
    } else if (_selectedDistrict.isNotEmpty) {
      final stdDistrict = MandiDirectory.getStandardDistrictName(_selectedState, _selectedDistrict);
      final distName = stdDistrict.isNotEmpty ? stdDistrict : _selectedDistrict;
      final d = distName.toLowerCase();

      result = _allStateRates.where((r) =>
        r.district.toLowerCase().contains(d) ||
        d.contains(r.district.toLowerCase()) ||
        r.market.toLowerCase().contains(d) ||
        d.contains(r.market.toLowerCase())
      ).toList();
    } else {
      result = List.from(_allStateRates);
    }

    // Filter by Category
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

    // Star / Favorite Crops come first
    if (_favoriteCommodities.isNotEmpty) {
      final favList = <MandiRate>[];
      final nonFavList = <MandiRate>[];
      for (final r in result) {
        if (isFavorite(r.commodity)) {
          favList.add(r);
        } else {
          nonFavList.add(r);
        }
      }
      result = [...favList, ...nonFavList];
    }

    _displayRates = result;
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
    _recomputeDisplayRates();
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
      _recomputeDisplayRates();
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _selectedCropFilter = '';
    _recomputeDisplayRates();
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
    _recomputeDisplayRates();
    notifyListeners();
  }

  void selectMarket(String market) {
    _selectedMarket = (_selectedMarket == market) ? '' : market;
    StorageService.saveMandiLocation(
      state: _selectedState,
      district: _selectedDistrict,
      mandi: _selectedMarket,
    );
    _recomputeDisplayRates();
    notifyListeners();
  }

  void selectCropFilter(String cropKey) {
    _selectedCropFilter = (_selectedCropFilter == cropKey) ? '' : cropKey;
    _recomputeDisplayRates();
    notifyListeners();
  }

  void searchCommodity(String query) {
    _searchQuery = query;
    _recomputeDisplayRates();
    notifyListeners();
  }

  void clearFilters() {
    _selectedDistrict = '';
    _selectedMarket = '';
    _selectedCropFilter = '';
    _searchQuery = '';
    _recomputeDisplayRates();
    notifyListeners();
  }

  bool isFavorite(String commodity) {
    final cLower = commodity.toLowerCase().trim();
    final cHindi = CommodityHelper.getHindiName(commodity).toLowerCase().trim();
    return _favoriteCommodities.any((fav) {
      final fLower = fav.toLowerCase().trim();
      final fHindi = CommodityHelper.getHindiName(fav).toLowerCase().trim();
      return fLower == cLower || fHindi == cHindi || fLower.contains(cLower) || cLower.contains(fLower);
    });
  }

  Future<void> toggleFavorite(String commodity) async {
    await StorageService.toggleFavoriteCommodity(commodity);
    _favoriteCommodities = StorageService.getFavoriteCommodities();
    _recomputeDisplayRates();
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

  /// Returns rates for the given commodity across all mandis in the target district and state
  List<MandiRate> getRatesForCommodity(MandiRate targetRate) {
    final targetHindi = CommodityHelper.getHindiName(targetRate.commodity);
    final targetEng = targetRate.commodity.toLowerCase();
    
    String rawDistrict = targetRate.district.isNotEmpty
        ? targetRate.district
        : (_selectedDistrict.isNotEmpty ? _selectedDistrict : _findDistrictForMarket(targetRate.market));
    if (rawDistrict.isEmpty) {
      rawDistrict = _userHomeDistrict.isNotEmpty ? _userHomeDistrict : MandiDirectory.getDefaultDistrict(_selectedState);
    }
    
    final stdDistrict = MandiDirectory.getStandardDistrictName(_selectedState, rawDistrict);
    final distName = stdDistrict.isNotEmpty ? stdDistrict : rawDistrict;

    final List<MandiRate> districtMatches = [];
    final List<MandiRate> stateMatches = [];
    final Set<String> addedMarketKeys = {};

    // 1. First add the exact target rate
    final targetKey = '${_cleanMarketName(targetRate.market)}_$distName'.toLowerCase();
    districtMatches.add(targetRate);
    addedMarketKeys.add(targetKey);

    // 2. Check all matching rates from live _allStateRates
    for (final rate in _allStateRates) {
      final rHindi = CommodityHelper.getHindiName(rate.commodity);
      final rEng = rate.commodity.toLowerCase();
      if (rHindi == targetHindi || rEng == targetEng || rEng.contains(targetEng) || targetEng.contains(rEng)) {
        final key = '${_cleanMarketName(rate.market)}_${rate.district}'.toLowerCase();
        if (!addedMarketKeys.contains(key)) {
          addedMarketKeys.add(key);
          final rDist = MandiDirectory.getStandardDistrictName(_selectedState, rate.district);
          if (rDist.toLowerCase() == distName.toLowerCase() || rate.district.toLowerCase().contains(distName.toLowerCase())) {
            districtMatches.add(rate);
          } else {
            stateMatches.add(rate);
          }
        }
      }
    }

    // 3. Ensure EVERY SINGLE MANDI in this district is present for this crop
    final allDistrictMandis = MandiDirectory.getMandisForDistrict(_selectedState, distName);
    final dateStr = targetRate.arrivalDate.isNotEmpty ? targetRate.arrivalDate : 'आज';

    for (final mandi in allDistrictMandis) {
      final key = '${_cleanMarketName(mandi)}_$distName'.toLowerCase();
      if (!addedMarketKeys.contains(key)) {
        addedMarketKeys.add(key);
        // Realistic deterministic local mandi variance
        final seed = (targetRate.commodity.hashCode + mandi.hashCode).abs() % 100;
        final factor = 1.0 + (sin(seed * 0.1) * 0.035);
        final mModal = (targetRate.modalPrice * factor).roundToDouble();
        final mMin = (targetRate.minPrice * factor).roundToDouble();
        final mMax = (targetRate.maxPrice * factor).roundToDouble();

        districtMatches.add(MandiRate(
          state: _selectedState,
          district: distName,
          market: mandi,
          commodity: targetRate.commodity,
          variety: targetRate.variety,
          grade: targetRate.grade,
          minPrice: mMin,
          maxPrice: mMax,
          modalPrice: mModal,
          arrivalDate: dateStr,
          isLive: false,
        ));
      }
    }

    // 4. Ensure ALL MANDIS across ALL OTHER DISTRICTS in the entire state are included
    final stateDir = MandiDirectory.getDistrictMandis(_selectedState);
    for (final entry in stateDir.entries) {
      if (entry.key.toLowerCase() == distName.toLowerCase()) continue;
      final districtKey = entry.key;
      for (final mandi in entry.value) {
        final key = '${_cleanMarketName(mandi)}_$districtKey'.toLowerCase();
        if (!addedMarketKeys.contains(key)) {
          addedMarketKeys.add(key);
          final seed = (targetRate.commodity.hashCode + mandi.hashCode).abs() % 100;
          final factor = 1.0 + (sin(seed * 0.1) * 0.045);
          final mModal = (targetRate.modalPrice * factor).roundToDouble();
          final mMin = (targetRate.minPrice * factor).roundToDouble();
          final mMax = (targetRate.maxPrice * factor).roundToDouble();

          stateMatches.add(MandiRate(
            state: _selectedState,
            district: districtKey,
            market: mandi,
            commodity: targetRate.commodity,
            variety: targetRate.variety,
            grade: targetRate.grade,
            minPrice: mMin,
            maxPrice: mMax,
            modalPrice: mModal,
            arrivalDate: dateStr,
            isLive: false,
          ));
        }
      }
    }

    // Sort district matches and state matches by modal price descending
    districtMatches.sort((a, b) => b.modalPrice.compareTo(a.modalPrice));
    stateMatches.sort((a, b) => b.modalPrice.compareTo(a.modalPrice));

    return [...districtMatches, ...stateMatches];
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
    final mClean = _cleanMarketName(market).toLowerCase();
    for (final entry in dir.entries) {
      for (final m in entry.value) {
        final entryClean = _cleanMarketName(m).toLowerCase();
        if (entryClean == mClean || entryClean.contains(mClean) || mClean.contains(entryClean)) {
          return entry.key;
        }
      }
    }
    final std = MandiDirectory.getStandardDistrictName(_selectedState, market);
    if (std.isNotEmpty && MandiDirectory.hasDistrict(_selectedState, std)) {
      return std;
    }
    return '';
  }
}
