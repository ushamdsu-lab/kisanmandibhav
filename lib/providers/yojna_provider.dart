import 'package:flutter/material.dart';
import '../models/scheme.dart';
import '../models/helpline.dart';
import '../services/data_service.dart';
import '../services/scheme_api_service.dart';
import '../services/storage_service.dart';

class YojnaProvider extends ChangeNotifier {
  List<Scheme> _schemes = [];
  List<Helpline> _helplines = [];
  bool _isLoading = false;
  String _error = '';
  
  String _selectedGovtType = 'all'; // Default to 'all' (सभी 25+ योजनाएं)
  String _selectedStateFilter = 'all'; // Default to 'all' (सभी राज्य)
  String _selectedCategory = 'all';
  String _searchQuery = '';
  List<String> _bookmarkedIds = [];

  List<Scheme> get schemes {
    var list = _schemes;

    // Filter by Government Type & State
    if (_selectedGovtType == 'central') {
      list = list.where((s) => s.governmentType == 'central').toList();
    } else if (_selectedGovtType == 'state') {
      if (_selectedStateFilter != 'all') {
        list = list.where((s) => s.governmentType == 'central' || s.stateName.toLowerCase() == _selectedStateFilter.toLowerCase()).toList();
      } else {
        list = list.where((s) => s.governmentType == 'state').toList();
      }
    } else if (_selectedGovtType == 'all') {
      if (_selectedStateFilter != 'all') {
        list = list.where((s) => s.governmentType == 'central' || s.stateName.toLowerCase() == _selectedStateFilter.toLowerCase()).toList();
      }
    }

    // Filter by Category
    if (_selectedCategory != 'all') {
      list = list.where((s) => s.category == _selectedCategory).toList();
    }

    // Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((s) =>
        s.name.toLowerCase().contains(q) ||
        s.nameEn.toLowerCase().contains(q) ||
        s.description.toLowerCase().contains(q) ||
        s.category.toLowerCase().contains(q) ||
        s.stateName.toLowerCase().contains(q)
      ).toList();
    }

    return list;
  }

  List<Scheme> get allSchemes => _schemes;
  List<Helpline> get helplines => _helplines;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get selectedGovtType => _selectedGovtType;
  String get selectedStateFilter => _selectedStateFilter;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<String> get bookmarkedIds => _bookmarkedIds;

  // Counts for tabs
  int get centralCount => _schemes.where((s) => s.governmentType == 'central').length;
  int get stateCount => _schemes.where((s) => s.governmentType == 'state').length;
  int get totalCount => _schemes.length;

  List<String> get categories {
    final cats = _schemes.map((s) => s.category).toSet().toList();
    cats.insert(0, 'all');
    return cats;
  }

  Scheme? getSchemeById(String id) {
    try {
      return _schemes.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  bool isBookmarked(String schemeId) => _bookmarkedIds.contains(schemeId);

  Future<void> loadData() async {
    // Reload freshly from asset JSON & Live API
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final localSchemes = await DataService.loadSchemes();
      final liveSchemes = await SchemeApiService.fetchLiveSchemes();
      _schemes = [...localSchemes, ...liveSchemes];
      _helplines = await DataService.loadHelplines();
      _bookmarkedIds = StorageService.getBookmarkedSchemes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectGovtType(String govtType) {
    if (_selectedGovtType == govtType) return;
    _selectedGovtType = govtType;
    notifyListeners();
  }

  void selectStateFilter(String state) {
    if (_selectedStateFilter == state) return;
    _selectedStateFilter = state;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void searchSchemes(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedGovtType = 'all';
    _selectedStateFilter = 'all';
    _selectedCategory = 'all';
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> toggleBookmark(String schemeId) async {
    await StorageService.toggleBookmarkScheme(schemeId);
    _bookmarkedIds = StorageService.getBookmarkedSchemes();
    notifyListeners();
  }
}
