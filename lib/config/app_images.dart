import 'package:flutter/material.dart';

/// Clean, asset-based image loaders with reliable vector icon fallbacks.
class AppImages {
  AppImages._();

  static const String _mahilaKisanPath = 'assets/images/mahila_kisan.png';
  static const String _carrotMascotPath = 'assets/images/carrot_mascot.png';

  static Widget get mahilaKisan => Image.asset(
        _mahilaKisanPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.person, color: Colors.amberAccent, size: 40),
      );

  static Widget get carrotMascot => Image.asset(
        _carrotMascotPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.eco, color: Colors.green, size: 40),
      );
}
