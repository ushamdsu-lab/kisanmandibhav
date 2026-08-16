import 'package:flutter/material.dart';

/// Clean, asset-based image loaders with reliable vector icon fallbacks.
class AppImages {
  AppImages._();

  static const String _mahilaKisanPath = 'assets/images/mahila_kisan.png';
  static const String _carrotMascotPath = 'assets/images/carrot_mascot.png';
  static const String appLogoPath = 'assets/images/app_logo.png';

  static Widget appLogo({double size = 36, BorderRadius? borderRadius}) => ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: Image.asset(
          appLogoPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.agriculture_rounded, color: Colors.white, size: size * 0.7),
        ),
      );

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
