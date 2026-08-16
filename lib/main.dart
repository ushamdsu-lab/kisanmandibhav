import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/storage_service.dart';
import 'services/ad_service.dart';
import 'providers/theme_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/mandi_provider.dart';
import 'providers/kheti_provider.dart';
import 'providers/yojna_provider.dart';
import 'providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage & services
  await StorageService.init();
  await AdService.init();

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => MandiProvider()),
        ChangeNotifierProvider(create: (_) => KhetiProvider()),
        ChangeNotifierProvider(create: (_) => YojnaProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const KisanMitraApp(),
    ),
  );
}
