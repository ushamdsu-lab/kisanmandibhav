import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../data/city_locations.dart';
import '../../providers/weather_provider.dart';
import '../../providers/mandi_provider.dart';
import '../../utils/district_helper.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/weather/windy_map_widget.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import '../../widgets/ads/inline_ad_card.dart';
import '../../widgets/ads/custom_sponsor_card.dart';
import '../../services/ad_service.dart';
import '../../services/tts_service.dart';
import '../../widgets/mandi/voice_bulletin_bar.dart';

class MausamScreen extends StatefulWidget {
  const MausamScreen({super.key});

  @override
  State<MausamScreen> createState() => _MausamScreenState();
}

class _MausamScreenState extends State<MausamScreen> {
  static const List<String> _hindiDays = ['सोमवार', 'मंगलवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार', 'रविवार'];
  static const List<String> _hindiMonths = ['', 'जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'];

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
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                        Text(
                          '📍 जिला या शहर चुनें',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  // --- Current GPS Location Tile ---
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.my_location_rounded, color: Colors.green),
                    ),
                    title: const Text('📍 वर्तमान GPS लोकेशन उपयोग करें', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.green)),
                    subtitle: const Text('ऑटोमेटिक मौसम व नजदीकी मंडी सेट करें', style: TextStyle(fontSize: 12)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final mandiProv = context.read<MandiProvider>();
                      final res = await provider.fetchUserLocation(mandiProvider: mandiProv);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res.isGps
                                ? '📍 लोकेशन (${res.cityName}) और ${DistrictHelper.getHindiName(res.district)} जिले के मंडी भाव सेट हो गए!'
                                : (res.errorMessage ?? 'लोकेशन प्राप्त नहीं हो सकी')),
                            backgroundColor: res.isGps ? Colors.green.shade700 : Colors.orange.shade800,
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        hintText: 'जिले का नाम खोजें (उदा: Bikaner, Jaipur, Kota, Indore)...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  searchCtrl.clear();
                                  setModalState(() {});
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: filteredCities.isEmpty
                        ? const Center(child: Text('कोई जिला नहीं मिला'))
                        : ListView.builder(
                            itemCount: filteredCities.length,
                            itemBuilder: (context, index) {
                              final city = filteredCities[index];
                              final isSelected = provider.cityName.toLowerCase().contains(city.name.toLowerCase()) ||
                                  city.name.toLowerCase().contains(provider.cityName.toLowerCase());

                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.mausamAccent.withValues(alpha: 0.15)
                                        : Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(city.icon, style: const TextStyle(fontSize: 18)),
                                ),
                                title: Text(
                                  city.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppColors.mausamAccent : null,
                                  ),
                                ),
                                subtitle: Text(
                                  city.state,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle_rounded, color: AppColors.mausamAccent)
                                    : null,
                                onTap: () {
                                  final mandiProv = context.read<MandiProvider>();
                                  provider.selectCity(city, mandiProvider: mandiProv);
                                  Navigator.pop(ctx);
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
    return Scaffold(
      bottomNavigationBar: const VoiceBulletinBar(),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            slivers: [
              // --- App Bar ---
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                iconTheme: const IconThemeData(color: Colors.white),
                actionsIconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    '🌦️ कृषि मौसम अपडेट',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 6,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.mausamGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.my_location_rounded, color: Colors.white),
                    tooltip: 'वर्तमान GPS लोकेशन लें',
                    onPressed: () async {
                      final mandiProv = context.read<MandiProvider>();
                      final res = await provider.fetchUserLocation(mandiProvider: mandiProv);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res.isGps
                                ? '📍 आपकी लोकेशन (${res.cityName}) और मंडी (${res.mandi}) सेट हो गई!'
                                : (res.errorMessage ?? 'लोकेशन प्राप्त नहीं हो सकी')),
                            backgroundColor: res.isGps ? Colors.green.shade700 : Colors.orange.shade800,
                          ),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    onPressed: () => provider.fetchWeather(),
                    tooltip: 'रिफ्रेश करें',
                  ),
                ],
              ),

              // --- Location Picker Header & Quick Chips ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location Bar Button
                      InkWell(
                        onTap: () => _showCityPicker(context, provider),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.mausamAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.mausamAccent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded, color: AppColors.mausamAccent, size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'वर्तमान चयनित जिला / स्थान (बदलने के लिए टैप करें):',
                                      style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color),
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            provider.cityName,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.mausamAccent),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (provider.isGpsLocation) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text('GPS', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.mausamAccent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'बदलें ▼',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Dynamic Quick City & Tehsil Chips based on currently selected district
                      Builder(
                        builder: (context) {
                          final currentDist = provider.detectedDistrict.isNotEmpty
                              ? provider.detectedDistrict
                              : (provider.cityName.contains('(')
                                  ? provider.cityName.split('(').last.replaceAll(')', '').trim()
                                  : provider.cityName.split(',').last.trim());
                          final quickCities = CityDatabase.getQuickChipsForLocation(
                            currentDistrict: currentDist,
                            currentState: provider.detectedState.isNotEmpty ? provider.detectedState : 'Rajasthan',
                          );

                          return SizedBox(
                            height: 40,
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
                                  child: FilterChip(
                                    avatar: Text(city.icon, style: const TextStyle(fontSize: 13)),
                                    label: Text(cityNameOnly, style: const TextStyle(fontSize: 12)),
                                    selected: isSelected,
                                    onSelected: (_) {
                                      final mandiProv = context.read<MandiProvider>();
                                      provider.selectCity(city, mandiProvider: mandiProv);
                                    },
                                    selectedColor: AppColors.mausamAccent.withValues(alpha: 0.2),
                                    checkmarkColor: AppColors.mausamAccent,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              if (provider.isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LoadingShimmer(itemCount: 4, height: 120),
                  ),
                )
              else if (provider.error.isNotEmpty)
                SliverFillRemaining(
                  child: AppErrorWidget(
                    message: provider.error,
                    onRetry: () => provider.fetchWeather(),
                  ),
                )
              else if (provider.weatherData != null) ...[
                // --- 1. Current Weather Hero Card ---
                SliverToBoxAdapter(
                  child: _buildCurrentWeatherHero(provider).animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.05, end: 0),
                ),

                // --- 2. Live Weather Alerts Banner ---
                SliverToBoxAdapter(
                  child: _buildAlertsBanner(provider).animate()
                      .fadeIn(delay: 150.ms, duration: 400.ms),
                ),

                // --- 3. Farmer Decision Center (Spray & Irrigation Guides) ---
                SliverToBoxAdapter(
                  child: _buildFarmerDecisionCenter(provider).animate()
                      .fadeIn(delay: 250.ms, duration: 400.ms),
                ),

                // --- 4. Live Windy Satellite Weather & Radar Map ---
                SliverToBoxAdapter(
                  child: WindyMapWidget(
                    latitude: provider.currentLat,
                    longitude: provider.currentLng,
                    locationName: provider.cityName,
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                ),

                // --- 5. 24-Hour Hourly Forecast Strip ---
                SliverToBoxAdapter(
                  child: _buildHourlyStrip(provider).animate()
                      .fadeIn(delay: 350.ms, duration: 400.ms),
                ),

                // --- 5. 7-Day Forecast Section ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: AppColors.mausamAccent, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              'अगले 7 दिन का पूर्वानुमान',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const Text(
                          'दैनिक तापमान व वर्षा %',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final forecast = provider.weatherData!.daily[index];
                      final card = _buildForecastCard(forecast, index);

                      if (index == 2) {
                        final showCustom = AdService.enableCustomSponsorAds && AdService.customAds.isNotEmpty;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            card,
                            if (showCustom)
                              CustomSponsorCard(ad: AdService.customAds.first)
                            else
                              InlineAdCard(enabled: AdService.enableMausamInlineCards),
                          ],
                        );
                      }

                      return card;
                    },
                    childCount: provider.weatherData!.daily.length,
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: BannerAdWidget(enabled: AdService.enableMausamBanner, showAdBadge: true),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 90)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentWeatherHero(WeatherProvider provider) {
    final weather = provider.weatherData!;
    final current = weather.current;
    final weatherInfo = AppConstants.weatherCodes[current.weatherCode] ?? {'label': 'सामान्य मौसम', 'icon': 'wb_sunny'};
    final windDirectionStr = provider.getWindDirectionHindi(current.windDirection);
    final rawCityName = provider.cityName;
    final cleanCityName = rawCityName.contains('(') 
        ? rawCityName.split('(').first.trim() 
        : rawCityName;

    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      gradientColors: AppColors.mausamGradient,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.my_location_rounded, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        cleanCityName,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (provider.isGpsLocation) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('GPS', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      weather.weatherEngineInfo,
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Big Temperature & Weather Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wb_sunny_rounded, size: 64, color: Colors.amberAccent),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${current.temperature.round()}°C',
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'महसूस: ${current.apparentTemperature.round()}°C',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Weather Condition Text
          Text(
            weatherInfo['label'] ?? 'साफ मौसम',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // High-Precision Weather Metrics Grid
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildHeroMetric(Icons.water_drop_rounded, '${current.humidity}%', 'नमी'),
                    Container(width: 1, height: 28, color: Colors.white30),
                    _buildHeroMetric(Icons.air_rounded, '${current.windSpeed.round()} km/h', 'हवा गति'),
                    Container(width: 1, height: 28, color: Colors.white30),
                    _buildHeroMetric(Icons.explore_rounded, windDirectionStr, 'हवा दिशा'),
                    Container(width: 1, height: 28, color: Colors.white30),
                    _buildHeroMetric(Icons.umbrella_rounded, '${current.precipitation.toStringAsFixed(1)} mm', 'वर्षा मात्रा'),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Colors.white24, height: 1),
                ),
                Row(
                  children: [
                    _buildHeroMetric(Icons.thermostat_rounded, '${current.apparentTemperature.round()}°C', 'महसूस'),
                    Container(width: 1, height: 28, color: Colors.white30),
                    _buildHeroMetric(Icons.wind_power_rounded, '${current.windGusts.round()} km/h', 'झोंके'),
                    Container(width: 1, height: 28, color: Colors.white30),
                    _buildHeroMetric(Icons.cloud_rounded, '${current.cloudCover}%', 'बादल'),
                    Container(width: 1, height: 28, color: Colors.white30),
                    _buildHeroMetric(
                      Icons.wb_twilight_rounded,
                      weather.daily.isNotEmpty && weather.daily.first.sunrise.isNotEmpty ? weather.daily.first.sunrise : '--:--',
                      'सूर्योदय',
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (current.usAqi > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.air_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'वायु गुणवत्ता (AQI): ${current.usAqi} • ${current.aqiLabel}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ECMWF #1 • PM2.5: ${current.pm25.round()}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          // 🎙️ "आज का मौसम सुनें" (Audio Weather Bulletin)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0D47A1),
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF0D47A1), size: 20),
              label: const Text(
                'आज का मौसम बुलेटिन सुनें (Audio)',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
              ),
              onPressed: () {
                TtsService().speakWeatherReport(
                  city: provider.cityName,
                  weather: provider.weatherData!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetric(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 9),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // --- Real-time Weather Alerts Banner ---
  Widget _buildAlertsBanner(WeatherProvider provider) {
    final alerts = provider.getActiveAlerts();
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: alerts.map((alert) {
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: alert.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: alert.color.withValues(alpha: 0.4), width: 1.2),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: alert.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
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

  // --- Farmer Decision Center (Spray & Irrigation Guide) ---
  Widget _buildFarmerDecisionCenter(WeatherProvider provider) {
    final spray = provider.getSprayWindowStatus();
    final irrigation = provider.getIrrigationStatus();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              '🚜 कृषि निर्णय केंद्र (Farmer Action Guide)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              // Spray Advice Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: (spray['color'] as Color).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.science_rounded, size: 16, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text('कीटनाशक स्प्रे', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        spray['status'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: spray['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        spray['reason'] as String,
                        style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Irrigation Advice Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: (irrigation['color'] as Color).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.water_rounded, size: 16, color: AppColors.mausamAccent),
                          SizedBox(width: 4),
                          Text('खेत में सिंचाई', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        irrigation['status'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: irrigation['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        irrigation['reason'] as String,
                        style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color),
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

  // --- Hourly Strip ---
  Widget _buildHourlyStrip(WeatherProvider provider) {
    final hourly = provider.weatherData!.hourly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 18, color: AppColors.mausamAccent),
              const SizedBox(width: 6),
              Text(
                '24 घंटे का घंटेवार तापमान व वर्षा अनुमान',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: hourly.length,
            itemBuilder: (context, index) {
              final h = hourly[index];
              final isNow = index == 0;
              final hourStr = isNow ? 'अभी' : DateFormat('h a').format(h.time);
              final isNight = h.time.hour < 6 || h.time.hour >= 19;
              final hasRain = h.precipitation > 0 || (h.weatherCode >= 51 && h.weatherCode <= 67) || (h.weatherCode >= 80 && h.weatherCode <= 99);

              return Container(
                width: 76,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: isNow
                      ? AppColors.mausamAccent.withValues(alpha: 0.16)
                      : Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isNow
                        ? AppColors.mausamAccent
                        : (hasRain ? Colors.blue.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.2)),
                    width: isNow ? 1.8 : 1.0,
                  ),
                  boxShadow: isNow
                      ? [
                          BoxShadow(
                            color: AppColors.mausamAccent.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
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
                        color: isNow ? AppColors.mausamAccent : null,
                      ),
                    ),
                    Icon(
                      hasRain
                          ? Icons.water_drop_rounded
                          : (isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded),
                      size: 20,
                      color: hasRain
                          ? AppColors.mausamAccent
                          : (isNight ? Colors.indigoAccent : Colors.amber),
                    ),
                    Text(
                      '${h.temperature.round()}°C',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: hasRain
                            ? AppColors.mausamAccent.withValues(alpha: 0.18)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.umbrella_rounded,
                            size: 9,
                            color: hasRain ? AppColors.mausamAccent : Colors.grey,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            hasRain
                                ? (h.precipitation > 0 ? '${h.precipitation.toStringAsFixed(1)}mm' : '${h.humidity}%')
                                : '0mm',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: hasRain ? AppColors.mausamAccent : Colors.grey,
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
    );
  }

  // --- 7-Day Forecast Card ---
  Widget _buildForecastCard(dynamic forecast, int index) {
    String dayStr;
    if (index == 0) {
      dayStr = 'आज';
    } else if (index == 1) {
      dayStr = 'कल';
    } else {
      final weekdayIndex = (forecast.date.weekday - 1).clamp(0, 6);
      final monthIndex = (forecast.date.month).clamp(1, 12);
      final dayName = _hindiDays[weekdayIndex];
      final monthName = _hindiMonths[monthIndex];
      dayStr = '$dayName, ${forecast.date.day} $monthName';
    }

    final weatherInfo = AppConstants.weatherCodes[forecast.weatherCode] ?? {'label': 'साफ मौसम', 'icon': 'wb_sunny'};

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.mausamAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                forecast.precipitationProbability > 40 ? Icons.water_drop_rounded : Icons.wb_sunny_rounded,
                color: forecast.precipitationProbability > 40 ? AppColors.mausamAccent : Colors.amber,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayStr,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  Text(
                    weatherInfo['label'] ?? 'साफ आसमान',
                    style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ],
              ),
            ),
            if (forecast.precipitationProbability > 0)
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop_rounded, color: Colors.blue, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      '${forecast.precipitationProbability}%',
                      style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${forecast.tempMax.round()}°C',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.priceDown),
                ),
                Text(
                  '${forecast.tempMin.round()}°C',
                  style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: ((index * 30).clamp(0, 300)).ms, duration: 250.ms);
  }
}
