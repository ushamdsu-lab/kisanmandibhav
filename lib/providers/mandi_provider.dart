import 'dart:async';
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
  Timer? _autoSyncTimer;
  
  String _selectedState = 'Rajasthan'; // Default state; updated by GPS detection
  String _selectedDistrict = '';
  String _selectedMarket = ''; // Specific Mandi
  String _userHomeState = 'Rajasthan';
  String _userHomeDistrict = '';
  String _userHomeMarket = '';
  String _selectedCategory = 'all'; // 'all' (default, shows all crops of the mandi), 'crops', 'vegetables'
  String _selectedCropFilter = ''; // Specific Crop shortcut
  String _searchQuery = '';
  List<String> _favoriteCommodities = [];
  List<PriceAlert> _priceAlerts = [];

  MandiProvider() {
    _loadSavedPreferences();
    _startAutoSyncTimer();
  }

  void _startAutoSyncTimer() {
    _autoSyncTimer?.cancel();
    // Industry standard: Auto-sync fresh mandi rates every 30 minutes while active
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      if (!_isLoading) {
        fetchRates(state: _selectedState);
      }
    });
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    super.dispose();
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
      _userHomeDistrict = savedDistrict;
    } else {
      _userHomeDistrict = MandiDirectory.getDefaultDistrict(_selectedState);
    }
    if (savedMandi.isNotEmpty) {
      _userHomeMarket = savedMandi;
    }
    // Always start with all mandis of the state (no auto filter)
    _selectedDistrict = '';
    _selectedMarket = '';
    _selectedCropFilter = '';
    _searchQuery = '';

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
  bool get isBrowsingOtherLocation =>
      _userHomeState.isNotEmpty &&
      (_selectedState.toLowerCase() != _userHomeState.toLowerCase() ||
       (_userHomeDistrict.isNotEmpty && _selectedDistrict.isNotEmpty && _selectedDistrict.toLowerCase() != _userHomeDistrict.toLowerCase()));
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

  // 100% Dynamic: Only districts that have ACTUAL rate data from API
  List<String> get availableDistricts {
    final Set<String> districts = {};

    for (final r in _allStateRates) {
      if (r.district.trim().isNotEmpty) {
        final std = MandiDirectory.getStandardDistrictName(_selectedState, r.district.trim());
        districts.add(std.isNotEmpty ? std : r.district.trim());
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

  // 100% Dynamic: Only markets that have ACTUAL rate data from API
  List<String> get availableMarkets {
    final Set<String> markets = {};

    if (_selectedDistrict.isNotEmpty) {
      final stdDistrict = MandiDirectory.getStandardDistrictName(_selectedState, _selectedDistrict);
      final targetDist = (stdDistrict.isNotEmpty ? stdDistrict : _selectedDistrict).toLowerCase();

      for (final r in _allStateRates) {
        final rDist = MandiDirectory.getStandardDistrictName(_selectedState, r.district).toLowerCase();
        final rawDist = r.district.trim().toLowerCase();
        if (rDist == targetDist || rawDist == targetDist || rDist.contains(targetDist) || targetDist.contains(rDist)) {
          if (r.market.trim().isNotEmpty) {
            markets.add(r.market.trim());
          }
        }
      }
    } else {
      for (final r in _allStateRates) {
        if (r.market.trim().isNotEmpty) {
          markets.add(r.market.trim());
        }
      }
    }

    final list = markets.where((m) => m.isNotEmpty).toList();
    list.sort();
    return list;
  }

  List<MandiRate> getRatesForDistrict(String district) {
    if (district.isEmpty) return _allStateRates;
    final stdDistrict = MandiDirectory.getStandardDistrictName(_selectedState, district);
    final d = (stdDistrict.isNotEmpty ? stdDistrict : district).toLowerCase().trim();

    final districtMandis = (MandiDirectory.getDistrictMandis(_selectedState)[stdDistrict] ?? [])
        .map((m) => _cleanMarketName(m).toLowerCase().trim())
        .toSet();

    final matched = _allStateRates.where((r) {
      final rDist = r.district.toLowerCase().trim();
      final rMarket = _cleanMarketName(r.market).toLowerCase().trim();
      if (rDist == d || rDist.contains(d) || d.contains(rDist) || rMarket.contains(d) || d.contains(rMarket)) {
        return true;
      }
      return districtMandis.any((dm) => dm.isNotEmpty && (rMarket.contains(dm) || dm.contains(rMarket)));
    }).toList();

    return matched;
  }

  List<String> getMarketsForDistrict(String district) {
    if (district.isEmpty) return availableMarkets;
    final stdDistrict = MandiDirectory.getStandardDistrictName(_selectedState, district);
    final targetDist = (stdDistrict.isNotEmpty ? stdDistrict : district).toLowerCase().trim();

    final Set<String> markets = {};

    for (final r in _allStateRates) {
      final rDist = MandiDirectory.getStandardDistrictName(_selectedState, r.district).toLowerCase().trim();
      final rawDist = r.district.trim().toLowerCase();
      if (rDist == targetDist || rawDist == targetDist || rDist.contains(targetDist) || targetDist.contains(rDist)) {
        if (r.market.trim().isNotEmpty) {
          markets.add(r.market.trim());
        }
      }
    }

    final list = markets.where((m) => m.isNotEmpty).toList();
    list.sort();
    return list;
  }

  /// Accurate count: uses SAME matching logic as _recomputeDisplayRates
  int getRatesCountForMarket(String market) {
    final m = _cleanMarketName(market).toLowerCase();
    final mRaw = market.toLowerCase();
    return _allStateRates.where((r) {
      final rMarket = _cleanMarketName(r.market).toLowerCase();
      final rRaw = r.market.toLowerCase();
      return rMarket == m ||
          rMarket.contains(m) ||
          m.contains(rMarket) ||
          rRaw.contains(m) ||
          m.contains(rRaw) ||
          rRaw.contains(mRaw) ||
          mRaw.contains(rRaw);
    }).length;
  }

  List<String> getSampleCropsForMarket(String market) {
    final m = _cleanMarketName(market).toLowerCase();
    final matching = _allStateRates
        .where((r) {
          final rMarket = _cleanMarketName(r.market).toLowerCase();
          return rMarket == m ||
              rMarket.contains(m) ||
              m.contains(rMarket) ||
              r.market.toLowerCase().contains(m) ||
              m.contains(r.market.toLowerCase());
        })
        .map((r) => CommodityHelper.getHindiName(r.commodity))
        .toSet()
        .take(5)
        .toList();
    if (matching.isNotEmpty) return matching;

    final distName = _selectedDistrict.isNotEmpty
        ? MandiDirectory.getStandardDistrictName(_selectedState, _selectedDistrict)
        : _findDistrictForMarket(market);
    final d = (distName.isNotEmpty ? distName : _selectedDistrict).toLowerCase();
    final distMatching = _allStateRates
        .where((r) => d.isNotEmpty && (r.district.toLowerCase().contains(d) || d.contains(r.district.toLowerCase())))
        .map((r) => CommodityHelper.getHindiName(r.commodity))
        .toSet()
        .take(5)
        .toList();
    if (distMatching.isNotEmpty) return distMatching;

    return ['गेहूं', 'कपास', 'सरसों', 'जीरा', 'चना'];
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
        limit: 25000,
      );

      if (liveRates.isNotEmpty) {
        _allStateRates = liveRates;
        _isOffline = false;
        StorageService.saveCachedMandiRates(_selectedState, liveRates);
        StorageService.recordPriceHistory(liveRates);
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

  List<MandiRate> get locationBaseRates {
    if (_selectedMarket.isNotEmpty) {
      final m = _cleanMarketName(_selectedMarket).toLowerCase();
      final mRaw = _selectedMarket.toLowerCase();
      var result = _allStateRates.where((r) {
        final rMarket = _cleanMarketName(r.market).toLowerCase();
        final rRaw = r.market.toLowerCase();
        return rMarket == m ||
            rMarket.contains(m) ||
            m.contains(rMarket) ||
            rRaw.contains(m) ||
            m.contains(rRaw) ||
            rRaw.contains(mRaw) ||
            mRaw.contains(rRaw);
      }).toList();

      // If market match returned 0, fall back to district-level rates so user isn't stuck on empty screen
      if (result.isEmpty && _selectedDistrict.isNotEmpty) {
        final stdDistrict = MandiDirectory.getStandardDistrictName(_selectedState, _selectedDistrict);
        final distName = stdDistrict.isNotEmpty ? stdDistrict : _selectedDistrict;
        final d = distName.toLowerCase();
        result = _allStateRates.where((r) {
          final rDist = r.district.toLowerCase();
          return rDist == d || rDist.contains(d) || d.contains(rDist);
        }).toList();
      }
      return result;
    } else if (_selectedDistrict.isNotEmpty) {
      final stdDistrict = MandiDirectory.getStandardDistrictName(_selectedState, _selectedDistrict);
      final distName = stdDistrict.isNotEmpty ? stdDistrict : _selectedDistrict;
      final d = distName.toLowerCase();

      final districtMandis = (MandiDirectory.getDistrictMandis(_selectedState)[stdDistrict] ?? [])
          .map((m) => _cleanMarketName(m).toLowerCase())
          .toSet();

      return _allStateRates.where((r) {
        final rDist = r.district.toLowerCase();
        final rMarket = _cleanMarketName(r.market).toLowerCase();
        // Strict district match: exact or standardized only
        if (rDist == d || rDist.contains(d) || d.contains(rDist)) {
          return true;
        }
        // Also include rates from known district mandis
        return districtMandis.any((dm) => dm.isNotEmpty && (rMarket == dm || rMarket.contains(dm) || dm.contains(rMarket)));
      }).toList();
    } else {
      return List.from(_allStateRates);
    }
  }

  /// Dynamic list of crops that ACTUALLY exist in the currently selected Mandi/District
  List<Map<String, String>> get availableCropsInCurrentView {
    final base = locationBaseRates;
    if (base.isEmpty) return [];

    Iterable<MandiRate> filtered = base;
    if (_selectedCategory == 'crops') {
      final cropsOnly = base.where((r) => !CommodityHelper.isVegetableOrFruit(r.commodity)).toList();
      if (cropsOnly.isNotEmpty) filtered = cropsOnly;
    } else if (_selectedCategory == 'vegetables') {
      filtered = base.where((r) => CommodityHelper.isVegetableOrFruit(r.commodity));
    }

    final seen = <String>{};
    final list = <Map<String, String>>[];

    for (final r in filtered) {
      final comm = r.commodity.trim();
      if (comm.isEmpty) continue;

      final hindiName = CommodityHelper.getHindiName(comm);
      final dedupeKey = hindiName.toLowerCase().trim();

      if (!seen.contains(dedupeKey)) {
        seen.add(dedupeKey);
        final englishName = CommodityHelper.getEnglishName(comm);
        list.add({
          'key': comm,
          'name': hindiName,
          'english': englishName.isNotEmpty ? englishName : comm,
        });
      }
    }

    return list;
  }

  void _recomputeDisplayRates() {
    List<MandiRate> result = locationBaseRates;

    // Filter by Category
    if (_selectedCategory == 'crops') {
      final cropsOnly = result.where((r) => !CommodityHelper.isVegetableOrFruit(r.commodity)).toList();
      result = cropsOnly.isNotEmpty ? cropsOnly : result;
    } else if (_selectedCategory == 'vegetables') {
      result = result.where((r) => CommodityHelper.isVegetableOrFruit(r.commodity)).toList();
    } else {
      // Default / 'all': Strict sorting - Main agricultural crops at the TOP, vegetables/fruits at the BOTTOM!
      final mainCrops = <MandiRate>[];
      final vegFruits = <MandiRate>[];
      for (final r in result) {
        if (CommodityHelper.isVegetableOrFruit(r.commodity)) {
          vegFruits.add(r);
        } else {
          mainCrops.add(r);
        }
      }
      result = [...mainCrops, ...vegFruits];
    }

    // Filter by quick crop filter chip
    if (_selectedCropFilter.isNotEmpty) {
      final targetFilter = _selectedCropFilter.toLowerCase().trim();
      final targetHindi = CommodityHelper.getHindiName(_selectedCropFilter).toLowerCase().trim();
      result = result.where((r) {
        final rComm = r.commodity.toLowerCase().trim();
        final rHindi = CommodityHelper.getHindiName(r.commodity).toLowerCase().trim();
        return rComm == targetFilter ||
            rHindi == targetFilter ||
            rHindi == targetHindi ||
            CommodityHelper.matchesSearch(r.commodity, _selectedCropFilter);
      }).toList();
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

  void syncLocationContext({required String state, String? district, String? market, String? mandi}) {
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
      _userHomeDistrict = stdDistrict.isNotEmpty ? stdDistrict : district;
      _selectedDistrict = _userHomeDistrict;
    }

    _selectedMarket = (mandi != null && mandi.isNotEmpty) ? mandi : (market ?? '');
    _userHomeMarket = _selectedMarket;

    StorageService.saveMandiLocation(
      state: _selectedState,
      district: _selectedDistrict,
      mandi: _selectedMarket,
    );

    fetchRates(
      state: _selectedState,
      district: _selectedDistrict.isNotEmpty ? _selectedDistrict : null,
      market: _selectedMarket.isNotEmpty ? _selectedMarket : null,
    );
  }

  void setUserHomeDistrict(String district) {
    final stdDistrict = MandiDirectory.getStandardDistrictName(_selectedState, district);
    _userHomeDistrict = stdDistrict.isNotEmpty ? stdDistrict : district;
    _selectedDistrict = _userHomeDistrict;
    _recomputeDisplayRates();
    notifyListeners();
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
    _selectedState = _userHomeState.isNotEmpty ? _userHomeState : 'Rajasthan';
    _selectedDistrict = _userHomeDistrict.isNotEmpty ? _userHomeDistrict : MandiDirectory.getDefaultDistrict(_selectedState);
    _selectedMarket = '';
    _selectedCropFilter = '';
    _searchQuery = '';
    StorageService.saveMandiLocation(
      state: _selectedState,
      district: _selectedDistrict,
      mandi: '',
    );
    fetchRates(
      state: _selectedState,
      district: _selectedDistrict,
    );
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _selectedCropFilter = '';
    _recomputeDisplayRates();
    notifyListeners();
  }

  void selectDistrict(String district) {
    _selectedDistrict = district;
    _selectedMarket = '';
    _selectedCropFilter = '';
    _searchQuery = '';
    StorageService.saveMandiLocation(
      state: _selectedState,
      district: _selectedDistrict,
      mandi: '',
    );
    _recomputeDisplayRates();
    notifyListeners();
  }

  void selectMarket(String market) {
    _selectedMarket = (_selectedMarket == market) ? '' : market;
    _selectedCropFilter = '';
    _searchQuery = '';
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

  /// Clears only the crop chip filter and search text, keeping chosen District & Mandi intact
  void clearCropAndSearchFilter() {
    _selectedCropFilter = '';
    _searchQuery = '';
    _recomputeDisplayRates();
    notifyListeners();
  }

  void clearFilters() {
    _selectedDistrict = '';
    _selectedMarket = '';
    _selectedCropFilter = '';
    _searchQuery = '';
    if (_allStateRates.isEmpty) {
      _selectedState = _userHomeState.isNotEmpty ? _userHomeState : 'Rajasthan';
      fetchRates(state: _selectedState);
      return;
    }
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
    final mClean = _cleanMarketName(market).toLowerCase();
    for (final r in _allStateRates) {
      final rMarket = _cleanMarketName(r.market).toLowerCase();
      if ((rMarket == mClean || rMarket.contains(mClean) || mClean.contains(rMarket)) && r.district.trim().isNotEmpty) {
        return r.district.trim();
      }
    }
    final dir = MandiDirectory.getDistrictMandis(_selectedState);
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
