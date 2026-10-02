import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'data/crop_disease_database.dart';
import 'services/storage_service.dart';
import 'services/ad_service.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/mandi_provider.dart';
import 'providers/kheti_provider.dart';
import 'providers/yojna_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/farm_khata_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Crashlytics — catches all Flutter errors automatically
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Enable Analytics
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  // Initialize storage & services
  await StorageService.init();
  await AdService.init();

  // Load crop diseases database & sync from CDN in background
  await CropDiseaseDatabase.loadFromAsset();
  CropDiseaseDatabase.syncFromCdn();

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => MandiProvider()),
        ChangeNotifierProvider(create: (_) => KhetiProvider()),
        ChangeNotifierProvider(create: (_) => YojnaProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => FarmKhataProvider()),
      ],
      child: const KisanMitraApp(),
    ),
  );
}
