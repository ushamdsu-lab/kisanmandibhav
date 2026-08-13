import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _isDarkMode = StorageService.isDarkMode();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    StorageService.setDarkMode(_isDarkMode);
    notifyListeners();
  }
}
