import 'package:flutter/material.dart';
import '../models/crop.dart';
import '../models/fertilizer.dart';
import '../services/data_service.dart';

class KhetiProvider extends ChangeNotifier {
  List<Crop> _crops = [];
  List<Fertilizer> _fertilizers = [];
  bool _isLoading = false;
  String _error = '';
  String _selectedSeason = 'all';

  List<Crop> get crops {
    if (_selectedSeason == 'all') return _crops;
    return _crops.where((c) => c.season == _selectedSeason).toList();
  }

  List<Crop> get allCrops => _crops;
  List<Fertilizer> get fertilizers => _fertilizers;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get selectedSeason => _selectedSeason;

  Crop? getCropById(String id) {
    try {
      return _crops.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Fertilizer> getFertilizersForCrop(String cropId) {
    return _fertilizers.where((f) => f.crops.contains(cropId)).toList();
  }

  Future<void> loadData() async {
    if (_crops.isNotEmpty) return; // Already loaded
    
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _crops = await DataService.loadCrops();
      _fertilizers = await DataService.loadFertilizers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSeasonFilter(String season) {
    _selectedSeason = season;
    notifyListeners();
  }
}
