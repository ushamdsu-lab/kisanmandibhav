import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/constants.dart';
import '../../data/city_locations.dart';
import '../../models/weather_data.dart';
import '../../providers/locale_provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/mandi_provider.dart';
import '../../utils/district_helper.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/language_toggle_button.dart';
import '../../widgets/weather/windy_map_widget.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import '../../widgets/ads/inline_ad_card.dart';
import '../../services/ad_service.dart';
import '../../services/tts_service.dart';
import '../../widgets/weather/smart_spray_advisory_widget.dart';

class MausamScreen extends StatefulWidget {
  const MausamScreen({super.key});

  @override
  State<MausamScreen> createState() => _MausamScreenState();
}

class _MausamScreenState extends State<MausamScreen> {
  static const List<String> _hindiDays = ['सोमवार', 'मंगलवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार', 'रविवार'];
  static const List<String> _hindiMonths = [
    '', 'जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून',
    'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'
  ];

  static String _formatTodayHindi() {
    final now = DateTime.now();
    final dayIndex = (now.weekday - 1).clamp(0, 6);
    final monthIndex = (now.month).clamp(1, 12);
    final dayName = _hindiDays[dayIndex];
    final monthName = _hindiMonths[monthIndex];
    return '${now.day} $monthName, $dayName';
  }

  static IconData _getWeatherIcon(int code, {bool isNight = false}) {
    if (code == 0 || code == 1) {
      return isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded;
    }
    if (code == 2) return Icons.wb_cloudy_rounded;
    if (code == 3) return Icons.cloud_rounded;
    if (code >= 45 && code <= 48) return Icons.foggy;
    if (code >= 51 && code <= 55) return Icons.grain_rounded;
    if (code >= 61 && code <= 65) return Icons.water_drop_rounded;
    if (code >= 71 && code <= 77) return Icons.ac_unit_rounded;
    if (code >= 80 && code <= 82) return Icons.shower_rounded;
    if (code >= 95) return Icons.thunderstorm_rounded;
    return Icons.wb_sunny_rounded;
  }

  static Color _getWeatherIconColor(int code) {
    if (code == 0 || code == 1) return const Color(0xFFFFB300);
    if (code == 2 || code == 3) return const Color(0xFFCFD8DC);
    if (code >= 45 && code <= 48) return const Color(0xFFB0BEC5);
    if (code >= 51 && code <= 65) return const Color(0xFF4FC3F7);
    if (code >= 71 && code <= 77) return const Color(0xFF80DEEA);
    if (code >= 80 && code <= 82) return const Color(0xFF29B6F6);
    if (code >= 95) return const Color(0xFFFFD54F);
    return const Color(0xFFFFB300);
  }

  /// Modern dynamic atmospheric gradient tailored to weather condition
  static List<Color> _getWeatherBackdrop(int code, {bool isNight = false}) {
    if (isNight) {
      return const [
        Color(0xFF0F172A),
        Color(0xFF1E1B4B),
        Color(0xFF0A0F1D),
      ];
    }
    if (code >= 95) {
      // Thunderstorm
      return const [
        Color(0xFF1E1B4B),
        Color(0xFF311042),
        Color(0xFF0F172A),
      ];
    }
    if (code >= 51 && code <= 82) {
      // Rain / Drizzle / Shower
      return const [
        Color(0xFF0F2B48),
        Color(0xFF134E5E),
        Color(0xFF091C2E),
      ];
    }
    if (code >= 45 && code <= 48) {
      // Fog / Mist
      return const [
        Color(0xFF2C3E50),
        Color(0xFF3F586D),
        Color(0xFF1E272E),
      ];
    }
    if (code == 2 || code == 3) {
      // Cloudy
      return const [
        Color(0xFF1A365D),
        Color(0xFF2A4365),
        Color(0xFF0F172A),
      ];
    }
    // Clear / Sunny Day
    return const [
      Color(0xFF0284C7),
      Color(0xFF0369A1),
      Color(0xFF0C4A6E),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WeatherProvider>();
      if (provider.weatherData == null && !provider.isLoading) {
        provider.fetchWeather();
      }
    });
  }

  void _showCityPicker(BuildContext context, WeatherProvider provider) {
    final searchCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = searchCtrl.text.toLowerCase();
            final filteredCities = query.isEmpty
                ? CityDatabase.popularCities
                : CityDatabase.popularCities.where((c) =>
                    c.name.toLowerCase().contains(query) ||
                    c.state.toLowerCase().contains(query)).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.78,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '📍 जिला या तहसील चुनें',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),

                  // GPS Live Tile
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: InkWell(
                      onTap: () async {
                        Navigator.pop(ctx);
                        final mandiProv = context.read<MandiProvider>();
                        final res = await provider.fetchUserLocation(mandiProvider: mandiProv);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(res.isGps
                                  ? '📍 लाइव लोकेशन: ${res.cityName} (${DistrictHelper.getHindiName(res.district)} मंडी सेट)'
                                  : (res.errorMessage ?? 'लोकेशन प्राप्त नहीं हो सकी')),
                              backgroundColor: res.isGps ? Colors.green.shade700 : Colors.orange.shade800,
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade700.withValues(alpha: 0.15),
                              const Color(0xFF059669).withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.shade500.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'वर्तमान GPS लोकेशन से मौसम लोड करें',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Colors.green),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'ऑटोमेटिक सटीक खेत मौसम व स्थानीय मंडी भाव',
                                    style: TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Colors.green),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Search Field
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        hintText: 'तहसील या शहर का नाम खोजें...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const Divider(height: 1),

                  // City List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: filteredCities.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, indent: 64),
                      itemBuilder: (context, index) {
                        final city = filteredCities[index];
                        final isSelected = provider.cityName.toLowerCase().contains(city.name.toLowerCase()) ||
                            city.name.toLowerCase().contains(provider.cityName.toLowerCase());

                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF0284C7).withValues(alpha: 0.15)
                                  : Colors.grey.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(city.icon, style: const TextStyle(fontSize: 20)),
                          ),
                          title: Text(
                            city.name,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? const Color(0xFF0284C7) : null,
                              fontSize: 14.5,
                            ),
                          ),
                          subtitle: Text('${city.state} • ${city.mandi}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0284C7))
                              : null,
                          onTap: () {
                            Navigator.pop(ctx);
                            final mandiProv = context.read<MandiProvider>();
                            provider.selectCity(city, mandiProvider: mandiProv);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProv = context.watch<LocaleProvider>();
    final isHi = localeProv.isHindi;

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, _) {
          final weather = provider.weatherData;
          final isNight = weather != null
              ? (weather.current.time.hour < 6 || weather.current.time.hour >= 19)
              : false;
          final weatherCode = weather?.current.weatherCode ?? 0;
          final bgGradient = _getWeatherBackdrop(weatherCode, isNight: isNight);

          return Stack(
            children: [
              // Dynamic Atmospheric Animated Background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: bgGradient,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // Ambient Light Orb (Soft Glowing Sun / Moon effect)
              Positioned(
                top: -50,
                right: -40,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        isNight
                            ? const Color(0xFF818CF8).withValues(alpha: 0.25)
                            : const Color(0xFFFBBF24).withValues(alpha: 0.28),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  color: const Color(0xFF0284C7),
                  backgroundColor: Colors.white,
                  onRefresh: () => provider.fetchWeather(),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Modern Glassmorphic Top Bar
                      SliverToBoxAdapter(
                        child: _buildModernTopBar(context, provider, isHi),
                      ),

                      // Location Selector & Quick Chips
                      SliverToBoxAdapter(
                        child: _buildLocationSelectorStrip(context, provider),
                      ),

                      if (provider.isLoading && weather == null)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: LoadingShimmer(itemCount: 4, height: 140),
                          ),
                        )
                      else if (provider.error.isNotEmpty && weather == null)
                        SliverFillRemaining(
                          child: Center(
                            child: AppErrorWidget(
                              message: provider.error,
                              onRetry: () => provider.fetchWeather(),
                            ),
                          ),
                        )
                      else if (weather != null) ...[
                        // 1. Showstopper Hero Weather Card
                        SliverToBoxAdapter(
                          child: _buildUltraModernHeroCard(context, provider, weather, isNight)
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: 0.04, end: 0),
                        ),

                        // 2. Real-time Weather Alert Warning (if any)
                        SliverToBoxAdapter(
                          child: _buildModernAlertsBanner(context, provider),
                        ),

                        // 3. 24-Hour Hourly Timeline
                        SliverToBoxAdapter(
                          child: _buildHourlyGlassTimeline(context, weather)
                              .animate()
                              .fadeIn(delay: 100.ms, duration: 400.ms),
                        ),

                        // 4. Farmer Decision Center 2.0 (Smart Agriculture Advisor)
                        SliverToBoxAdapter(
                          child: _buildFarmerDecisionCenter(context, provider)
                              .animate()
                              .fadeIn(delay: 150.ms, duration: 400.ms),
                        ),

                        // 4.1. Smart Spray Weather Advisory Card
                        const SliverToBoxAdapter(
                          child: SmartSprayAdvisoryWidget(),
                        ),

                        // 5. 2x2 High-Tech Agricultural Metric Grid
                        SliverToBoxAdapter(
                          child: _buildAgriculturalMetricsGrid(context, weather, provider)
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 400.ms),
                        ),

                        // 6. Next 7-Day Forecast with Apple Weather Style Temperature Bars
                        SliverToBoxAdapter(
                          child: _buildModern7DayForecastCard(context, weather)
                              .animate()
                              .fadeIn(delay: 250.ms, duration: 400.ms),
                        ),

                        // 7. Live Satellite Weather Radar Map
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: WindyMapWidget(
                              latitude: provider.currentLat,
                              longitude: provider.currentLng,
                              locationName: provider.cityName,
                            ),
                          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                        ),

                        // Ads Integration
                        if (AdService.enableMausamInlineCards)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: InlineAdCard(enabled: true),
                            ),
                          ),

                        if (AdService.enableMausamBanner)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: BannerAdWidget(enabled: true, showAdBadge: true),
                            ),
                          ),

                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- 1. Modern Top Bar ---
  Widget _buildModernTopBar(BuildContext context, WeatherProvider provider, bool isHi) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Color(0xFF10B981), blurRadius: 6, spreadRadius: 1),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isHi ? 'कृषि मौसम लाइव' : 'Agri Weather Live',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const Spacer(),
          const LanguageToggleButton(),
          const SizedBox(width: 4),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
            tooltip: isHi ? 'GPS लोकेशन लें' : 'Get GPS',
            onPressed: () async {
              final mandiProv = context.read<MandiProvider>();
              final res = await provider.fetchUserLocation(mandiProvider: mandiProv);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res.isGps
                        ? (isHi ? '📍 लाइव लोकेशन: ${res.cityName} सेट हो गई!' : '📍 Location: ${res.cityName} set!')
                        : (res.errorMessage ?? 'लोकेशन प्राप्त नहीं हो सकी')),
                    backgroundColor: res.isGps ? Colors.green.shade700 : Colors.orange.shade800,
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 4),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            tooltip: isHi ? 'ताज़ा करें' : 'Refresh',
            onPressed: () => provider.fetchWeather(),
          ),
        ],
      ),
    );
  }

  // --- 2. Location Selector & Quick Chips ---
  Widget _buildLocationSelectorStrip(BuildContext context, WeatherProvider provider) {
    final rawCityName = provider.cityName;
    final cleanCityName = rawCityName.contains('(')
        ? rawCityName.split('(').first.trim()
        : rawCityName;
    final subName = rawCityName.contains('(')
        ? rawCityName.substring(rawCityName.indexOf('(') + 1).replaceAll(')', '').trim()
        : provider.detectedState;

    final currentDist = provider.detectedDistrict.isNotEmpty
        ? provider.detectedDistrict
        : (provider.cityName.contains('(')
            ? provider.cityName.split('(').last.replaceAll(')', '').trim()
            : provider.cityName.split(',').last.trim());

    final quickCities = CityDatabase.getQuickChipsForLocation(
      currentDistrict: currentDist,
      currentState: provider.detectedState.isNotEmpty ? provider.detectedState : 'Rajasthan',
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Frosted Glass Location Selector Bar
          InkWell(
            onTap: () => _showCityPicker(context, provider),
            borderRadius: BorderRadius.circular(18),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    cleanCityName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (provider.isGpsLocation) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('GPS', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              subName.isNotEmpty ? '$subName • स्थान बदलने हेतु टैप करें' : 'स्थान बदलने हेतु टैप करें',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'बदलें',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Horizontal Quick Chips Strip
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: quickCities.length,
              itemBuilder: (context, index) {
                final city = quickCities[index];
                final cityNameOnly = city.name.split(' ').first;
                final isSelected = provider.cityName.toLowerCase().contains(cityNameOnly.toLowerCase()) ||
                    city.name.toLowerCase().contains(provider.cityName.toLowerCase());

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () {
                      final mandiProv = context.read<MandiProvider>();
                      provider.selectCity(city, mandiProvider: mandiProv);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.18),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(city.icon, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 5),
                          Text(
                            cityNameOnly,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              color: isSelected ? const Color(0xFF0369A1) : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. Ultra-Modern Weather Hero Card ---
  Widget _buildUltraModernHeroCard(
    BuildContext context,
    WeatherProvider provider,
    WeatherData weather,
    bool isNight,
  ) {
    final current = weather.current;
    final weatherInfo = AppConstants.weatherCodes[current.weatherCode] ?? {'label': 'सामान्य मौसम', 'icon': 'wb_sunny'};
    final todayForecast = weather.daily.isNotEmpty ? weather.daily.first : null;
    final minTemp = todayForecast?.tempMin.round() ?? (current.temperature - 5).round();
    final maxTemp = todayForecast?.tempMax.round() ?? (current.temperature + 5).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.28),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Model & Satellite Engine Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt_rounded, color: Color(0xFFFBBF24), size: 13),
                          const SizedBox(width: 3),
                          Text(
                            weather.weatherEngineInfo,
                            style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 10.5, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatTodayHindi(),
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Centerpiece: Temperature & 3D Icon with Glowing Aura
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Atmospheric Glow
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getWeatherIconColor(current.weatherCode).withValues(alpha: 0.4),
                                blurRadius: 36,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _getWeatherIcon(current.weatherCode, isNight: isNight),
                          size: 72,
                          color: _getWeatherIconColor(current.weatherCode),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${current.temperature.round()}',
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 0.95,
                                letterSpacing: -2,
                              ),
                            ),
                            const Text(
                              '°C',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF38BDF8),
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'महसूस ${current.apparentTemperature.round()}°C  •  ⬇ $minTemp° / ⬆ $maxTemp°',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Condition Label
                Text(
                  weatherInfo['label'] ?? 'साफ मौसम',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Modern 4-Pill Horizontal Strip
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      _buildMetricPill(Icons.water_drop_rounded, '${current.humidity}%', 'आर्द्रता', const Color(0xFF38BDF8)),
                      Container(width: 1, height: 26, color: Colors.white12),
                      _buildMetricPill(Icons.air_rounded, '${current.windSpeed.round()} km/h', 'पवन गति', const Color(0xFF34D399)),
                      Container(width: 1, height: 26, color: Colors.white12),
                      _buildMetricPill(Icons.umbrella_rounded, '${current.precipitation.toStringAsFixed(1)} mm', 'वर्षा', const Color(0xFF60A5FA)),
                      Container(width: 1, height: 26, color: Colors.white12),
                      _buildMetricPill(Icons.cloud_rounded, '${current.cloudCover}%', 'बादल', const Color(0xFFFBBF24)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 🎙️ "आज का मौसम बुलेटिन सुनें" (Audio Bulletin Button)
                InkWell(
                  onTap: () {
                    TtsService().speakWeatherReport(
                      city: provider.cityName,
                      weather: provider.weatherData!,
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.volume_up_rounded, color: Colors.white, size: 19),
                        SizedBox(width: 8),
                        Text(
                          'आज का कृषि मौसम बुलेटिन सुनें (Audio)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricPill(IconData icon, String value, String label, Color iconColor) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
              maxLines: 1,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 9.5),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. 24-Hour Hourly Forecast Timeline ---
  Widget _buildHourlyGlassTimeline(BuildContext context, WeatherData weather) {
    final hourly = weather.hourly;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 17, color: Color(0xFF38BDF8)),
                const SizedBox(width: 6),
                const Text(
                  '24 घंटे का घंटेवार पूर्वानुमान (24-Hour Timeline)',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 126,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: hourly.length,
              itemBuilder: (context, index) {
                final h = hourly[index];
                final isNow = index == 0;
                final hourStr = isNow ? 'अभी' : DateFormat('h a').format(h.time);
                final isNight = h.time.hour < 6 || h.time.hour >= 19;
                final hasRain = h.precipitation > 0 || (h.weatherCode >= 51 && h.weatherCode <= 67) || (h.weatherCode >= 80 && h.weatherCode <= 99);

                return Container(
                  width: 76,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isNow
                        ? const Color(0xFF0284C7).withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isNow
                          ? const Color(0xFF38BDF8)
                          : (hasRain ? Colors.blue.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.12)),
                      width: isNow ? 1.8 : 1.0,
                    ),
                    boxShadow: isNow
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hourStr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isNow ? FontWeight.w900 : FontWeight.w600,
                          color: isNow ? const Color(0xFF38BDF8) : Colors.white70,
                        ),
                      ),
                      Icon(
                        _getWeatherIcon(h.weatherCode, isNight: isNight),
                        size: 24,
                        color: _getWeatherIconColor(h.weatherCode),
                      ),
                      Text(
                        '${h.temperature.round()}°',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: hasRain
                              ? const Color(0xFF0284C7).withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.water_drop_rounded,
                              size: 10,
                              color: hasRain ? const Color(0xFF38BDF8) : Colors.white54,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              hasRain
                                  ? (h.precipitation > 0 ? '${h.precipitation.toStringAsFixed(1)}m' : '${h.humidity}%')
                                  : '${h.windSpeed.round()}k',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: hasRain ? const Color(0xFF38BDF8) : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. Farmer Decision Center 2.0 (High-Tech Smart Agriculture Advisor) ---
  Widget _buildFarmerDecisionCenter(BuildContext context, WeatherProvider provider) {
    final spray = provider.getSprayWindowStatus();
    final irrigation = provider.getIrrigationStatus();

    final isSpraySafe = (spray['status'] as String).contains('अनुकूल') || (spray['status'] as String).contains('उत्तम');
    final isIrrigationSafe = (irrigation['status'] as String).contains('सिंचाई') && !(irrigation['status'] as String).contains('रोकें');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.agriculture_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🚜 किसान निर्णय केंद्र (Smart Agri Advisor)',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Colors.white),
                    ),
                    Text(
                      'हवा गति, नमी व वर्षा पूर्वानुमान आधारित स्वचालित सलाह',
                      style: TextStyle(fontSize: 10, color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // Spray Advice Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSpraySafe
                        ? Colors.green.shade900.withValues(alpha: 0.3)
                        : Colors.amber.shade900.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSpraySafe ? Colors.green.shade400.withValues(alpha: 0.4) : Colors.amber.shade400.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isSpraySafe ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                            size: 16,
                            color: isSpraySafe ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                          ),
                          const SizedBox(width: 5),
                          const Expanded(
                            child: Text(
                              'दवा / स्प्रे सलाह',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        spray['status'] as String,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: isSpraySafe ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        spray['reason'] as String,
                        style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Irrigation Advice Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isIrrigationSafe
                        ? const Color(0xFF0284C7).withValues(alpha: 0.25)
                        : Colors.orange.shade900.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isIrrigationSafe ? const Color(0xFF38BDF8).withValues(alpha: 0.4) : Colors.orange.shade400.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isIrrigationSafe ? Icons.water_drop_rounded : Icons.thunderstorm_rounded,
                            size: 16,
                            color: isIrrigationSafe ? const Color(0xFF38BDF8) : const Color(0xFFFB923C),
                          ),
                          const SizedBox(width: 5),
                          const Expanded(
                            child: Text(
                              'खेत में सिंचाई',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        irrigation['status'] as String,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: isIrrigationSafe ? const Color(0xFF38BDF8) : const Color(0xFFFB923C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        irrigation['reason'] as String,
                        style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 6. 2x2 Agricultural Weather Metric Grid ---
  Widget _buildAgriculturalMetricsGrid(
    BuildContext context,
    WeatherData weather,
    WeatherProvider provider,
  ) {
    final current = weather.current;
    final firstDaily = weather.daily.isNotEmpty ? weather.daily.first : null;
    final windDirectionStr = provider.getWindDirectionHindi(current.windDirection);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.dashboard_customize_rounded, size: 16, color: Color(0xFF38BDF8)),
                SizedBox(width: 6),
                Text(
                  'कृषि मौसम पैरामीटर्स (Agri Metrics)',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              // Metric 1: Air Quality (AQI)
              Expanded(
                child: _buildGlassGridCard(
                  icon: Icons.air_rounded,
                  iconColor: const Color(0xFF34D399),
                  title: 'वायु गुणवत्ता (AQI)',
                  value: current.usAqi > 0 ? '${current.usAqi}' : '42',
                  subtitle: current.usAqi > 0 ? current.aqiLabel : '🟢 उत्तम (Good)',
                  extra: 'PM2.5: ${current.pm25.round()} µg/m³',
                ),
              ),
              const SizedBox(width: 10),

              // Metric 2: Wind & Gusts
              Expanded(
                child: _buildGlassGridCard(
                  icon: Icons.explore_rounded,
                  iconColor: const Color(0xFF60A5FA),
                  title: 'पवन व दिशा',
                  value: '${current.windSpeed.round()} km/h',
                  subtitle: windDirectionStr,
                  extra: 'झोंके: ${current.windGusts.round()} km/h',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Metric 3: Moisture & Humidity
              Expanded(
                child: _buildGlassGridCard(
                  icon: Icons.opacity_rounded,
                  iconColor: const Color(0xFF38BDF8),
                  title: 'आर्द्रता व ओस',
                  value: '${current.humidity}%',
                  subtitle: current.humidity > 75
                      ? 'अत्यधिक नमी (फफूंद खतरा)'
                      : (current.humidity < 30 ? 'शुष्क मौसम' : 'सामान्य आर्द्रता'),
                  extra: 'बादल: ${current.cloudCover}%',
                ),
              ),
              const SizedBox(width: 10),

              // Metric 4: Sun Cycle
              Expanded(
                child: _buildGlassGridCard(
                  icon: Icons.wb_twilight_rounded,
                  iconColor: const Color(0xFFFBBF24),
                  title: 'सूर्योदय व सूर्यास्त',
                  value: firstDaily?.sunrise.isNotEmpty == true ? firstDaily!.sunrise : '06:15 AM',
                  subtitle: 'सूर्यास्त: ${firstDaily?.sunset.isNotEmpty == true ? firstDaily!.sunset : "06:45 PM"}',
                  extra: 'UV इंडेक्स: ${firstDaily?.uvIndexMax.round() ?? 6} (मध्यम)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassGridCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required String extra,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 17),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10.5, fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            extra,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 9.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- 7. Modern 7-Day Forecast with Apple Weather Style Temperature Bars ---
  Widget _buildModern7DayForecastCard(BuildContext context, WeatherData weather) {
    final daily = weather.daily;
    if (daily.isEmpty) return const SizedBox.shrink();

    // Compute overall week min and max to scale the range bars
    double weekMin = double.infinity;
    double weekMax = double.negativeInfinity;
    for (final d in daily) {
      if (d.tempMin < weekMin) weekMin = d.tempMin;
      if (d.tempMax > weekMax) weekMax = d.tempMax;
    }
    if (weekMax == weekMin) weekMax = weekMin + 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 17, color: Color(0xFF38BDF8)),
              SizedBox(width: 6),
              Text(
                'अगले 7 दिन का मौसम व तापमान विस्तार',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...daily.asMap().entries.map((entry) {
            final index = entry.key;
            final forecast = entry.value;

            String dayStr;
            if (index == 0) {
              dayStr = 'आज';
            } else if (index == 1) {
              dayStr = 'कल';
            } else {
              final weekdayIndex = (forecast.date.weekday - 1).clamp(0, 6);
              dayStr = _hindiDays[weekdayIndex];
            }

            final rainProb = forecast.precipitationProbability;
            final weatherInfo = AppConstants.weatherCodes[forecast.weatherCode] ?? {'label': 'साफ'};

            // Calculate range bar fractions
            final minFraction = ((forecast.tempMin - weekMin) / (weekMax - weekMin)).clamp(0.0, 1.0);
            final maxFraction = ((forecast.tempMax - weekMin) / (weekMax - weekMin)).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  // Day Name
                  SizedBox(
                    width: 58,
                    child: Text(
                      dayStr,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: index == 0 ? FontWeight.w900 : FontWeight.w700,
                        color: index == 0 ? const Color(0xFF38BDF8) : Colors.white,
                      ),
                    ),
                  ),

                  // Weather Icon
                  Icon(
                    _getWeatherIcon(forecast.weatherCode),
                    size: 20,
                    color: _getWeatherIconColor(forecast.weatherCode),
                  ),
                  const SizedBox(width: 6),

                  // Rain % or Condition text
                  SizedBox(
                    width: 48,
                    child: rainProb > 0
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.water_drop_rounded, size: 10, color: Color(0xFF38BDF8)),
                              const SizedBox(width: 1),
                              Text(
                                '$rainProb%',
                                style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10.5, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : Text(
                            weatherInfo['label']!.split(' ').first,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  const SizedBox(width: 8),

                  // Min Temp
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${forecast.tempMin.round()}°',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Apple Weather style Temperature Range Bar
                  Expanded(
                    child: SizedBox(
                      height: 6,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final barWidth = constraints.maxWidth;
                          final leftMargin = barWidth * minFraction;
                          final width = ((barWidth * maxFraction) - leftMargin).clamp(10.0, barWidth);

                          return Stack(
                            children: [
                              // Background Track
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              // Active Temp Range Capsule
                              Positioned(
                                left: leftMargin.clamp(0.0, barWidth - 10),
                                width: width,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF38BDF8),
                                        Color(0xFFFBBF24),
                                        Color(0xFFF97316),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Max Temp
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${forecast.tempMax.round()}°',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- Real-time Weather Alerts Banner ---
  Widget _buildModernAlertsBanner(BuildContext context, WeatherProvider provider) {
    final alerts = provider.getActiveAlerts();
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: alerts.map((alert) {
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: alert.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: alert.color.withValues(alpha: 0.45), width: 1.2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: alert.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert.description,
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
