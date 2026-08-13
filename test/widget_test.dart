import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kisan_mitra/app.dart';
import 'package:kisan_mitra/providers/theme_provider.dart';
import 'package:kisan_mitra/providers/weather_provider.dart';
import 'package:kisan_mitra/providers/mandi_provider.dart';
import 'package:kisan_mitra/providers/kheti_provider.dart';
import 'package:kisan_mitra/providers/yojna_provider.dart';
import 'package:kisan_mitra/providers/notification_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kisan_mitra/services/storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  testWidgets('App renders correctly with navigation destinations', (WidgetTester tester) async {
    await tester.pumpWidget(
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

    await tester.pump(const Duration(seconds: 1));

    // Verify navigation bar items exist
    expect(find.text('होम'), findsWidgets);
    expect(find.text('मंडी'), findsOneWidget);
    expect(find.text('मौसम'), findsOneWidget);
    expect(find.text('खेती'), findsOneWidget);
    expect(find.text('योजना'), findsOneWidget);
  });
}
